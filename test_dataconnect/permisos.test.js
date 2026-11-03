import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { after, before, describe, test } from 'node:test';

import { deleteApp, initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  getAuth,
  signOut,
} from 'firebase/auth';
import {
  connectDataConnectEmulator,
  executeMutation,
  executeQuery,
  getDataConnect,
  mutationRef,
  queryRef,
} from 'firebase/data-connect';

const CONECTOR = {
  connector: 'agilu',
  service: 'agilu-a232a-service',
  location: 'us-east4',
};
// SQL Connect regresa los UUID sin guiones; así se comparan directo.
const CAFETERIA = 'c0000000000040008000000000000001';
const BARRA = 'c0000000000040008000000000000002';
const MOLLETES = 'b0000000000040008000000000000002';
const HORCHATA = 'b0000000000040008000000000000004';
const CAFE_NO_DISPONIBLE = 'b0000000000040008000000000000005';
const CAPUCHINO = 'b0000000000040008000000000000006';

const sinGuiones = (uuid) => uuid.replaceAll('-', '');
const enUnaHora = () => new Date(Date.now() + 60 * 60 * 1000).toISOString();

async function alumno(nombre) {
  const app = initializeApp({ projectId: 'demo-agilu', apiKey: 'demo' }, nombre);
  const auth = getAuth(app);
  connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
  const dc = getDataConnect(app, CONECTOR);
  connectDataConnectEmulator(dc, '127.0.0.1', 9399);
  await createUserWithEmailAndPassword(auth, `${nombre}@utng.edu.mx`, '123456');
  return {
    app,
    auth,
    query: (op, vars) => executeQuery(queryRef(dc, op, vars)),
    mutation: (op, vars) => executeMutation(mutationRef(dc, op, vars)),
  };
}

const pedido = (cambios = {}) => ({
  id: randomUUID(),
  cafeteriaId: CAFETERIA,
  recogerA: enUnaHora(),
  notas: 'Sin cebolla',
  items: [
    { productoId: MOLLETES, cantidad: 2 },
    { productoId: HORCHATA, cantidad: 1 },
  ],
  ...cambios,
});

let ana;
let beto;
let pedidoDeAna;

const ADMIN_URL =
  'http://127.0.0.1:9399/v1/projects/demo-agilu/locations/us-east4/' +
  'services/agilu-a232a-service:executeGraphql';

async function comoAdmin(archivo, operationName, variables = {}) {
  const res = await fetch(ADMIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      query: readFileSync(new URL(archivo, import.meta.url), 'utf8'),
      operationName,
      variables,
    }),
  });
  const cuerpo = await res.json();
  assert.ok(res.ok && !cuerpo.errors?.length, JSON.stringify(cuerpo));
  return cuerpo.data;
}

// Equivalente mínimo de getDataConnect() del Admin SDK para el emulador.
const adminDataConnect = {
  executeGraphql: async (query, { variables } = {}) => {
    const res = await fetch(ADMIN_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables }),
    });
    const cuerpo = await res.json();
    assert.ok(res.ok && !cuerpo.errors?.length, JSON.stringify(cuerpo));
    return cuerpo;
  },
};

const sembrarCatalogo = () =>
  comoAdmin('../dataconnect/seed_data.gql', 'SembrarCatalogo');

before(async () => {
  await sembrarCatalogo();
  ana = await alumno('ana');
  beto = await alumno('beto');
  await ana.mutation('CrearPerfil', { nombre: 'Ana' });
  await beto.mutation('CrearPerfil', { nombre: 'Beto' });
});

after(async () => {
  for (const a of [ana, beto]) {
    await signOut(a.auth);
    await deleteApp(a.app);
  }
});

describe('perfil', () => {
  test('cada alumno ve solo su propio perfil', async () => {
    const { data } = await ana.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.nombre, 'Ana');
    assert.equal(data.autenticacion.correoElectronico, 'ana@utng.edu.mx');
  });

  test('no se puede crear un segundo perfil para la misma cuenta', async () => {
    await assert.rejects(ana.mutation('CrearPerfil', { nombre: 'Otra Ana' }));
  });
});

describe('menú', () => {
  test('un alumno con sesión ve el menú completo', async () => {
    const { data } = await ana.query('ListarMenu');
    assert.equal(data.productos.length, 6);
    const cafe = data.productos.find((p) => p.id === CAFE_NO_DISPONIBLE);
    assert.equal(cafe.disponible, false);
  });

  test('sin sesión no se puede ver el menú', async () => {
    const anonimo = initializeApp({ projectId: 'demo-agilu', apiKey: 'demo' }, 'anonimo');
    const dc = getDataConnect(anonimo, CONECTOR);
    connectDataConnectEmulator(dc, '127.0.0.1', 9399);
    await assert.rejects(executeQuery(queryRef(dc, 'ListarMenu')));
    await deleteApp(anonimo);
  });
});

describe('crear pedido', () => {
  test('un alumno crea su pedido y el servidor calcula total y folio', async () => {
    const vars = pedido();
    const { data } = await ana.mutation('CrearPedido', vars);
    assert.equal(data._execute, 2);

    const res = await ana.query('MiPedido', { id: vars.id });
    const [p] = res.data.pedidos;
    assert.equal(p.montoTotal, 2 * 40 + 20);
    assert.equal(p.estado, 'pendiente');
    assert.ok(Number.isInteger(p.folio) && p.folio > 0);
    assert.equal(p.id, sinGuiones(vars.id));
    pedidoDeAna = { id: p.id, folio: p.folio };
  });

  test('el folio avanza de uno en uno', async () => {
    const vars = pedido();
    await beto.mutation('CrearPedido', vars);
    const res = await beto.query('MiPedido', { id: vars.id });
    assert.equal(res.data.pedidos[0].folio, pedidoDeAna.folio + 1);
  });

  test('no se acepta un producto no disponible', async () => {
    const { data } = await ana.mutation(
      'CrearPedido',
      pedido({ items: [{ productoId: CAFE_NO_DISPONIBLE, cantidad: 1 }] }),
    );
    assert.equal(data._execute, 0);
  });

  test('no se mezclan productos de otra cafetería', async () => {
    const { data } = await ana.mutation(
      'CrearPedido',
      pedido({ items: [{ productoId: MOLLETES, cantidad: 1 }, { productoId: CAPUCHINO, cantidad: 1 }] }),
    );
    assert.equal(data._execute, 0);
  });

  test('no se aceptan pedidos vacíos ni cantidades inválidas', async () => {
    const vacio = await ana.mutation('CrearPedido', pedido({ items: [] }));
    assert.equal(vacio.data._execute, 0);
    const cero = await ana.mutation(
      'CrearPedido',
      pedido({ items: [{ productoId: MOLLETES, cantidad: 0 }] }),
    );
    assert.equal(cero.data._execute, 0);
  });

  test('no se acepta una hora de recogida en el pasado', async () => {
    const { data } = await ana.mutation(
      'CrearPedido',
      pedido({ recogerA: new Date(Date.now() - 60000).toISOString() }),
    );
    assert.equal(data._execute, 0);
  });

  test('un pedido rechazado no consume folio', async () => {
    const vars = pedido();
    await ana.mutation('CrearPedido', vars);
    const res = await ana.query('MiPedido', { id: vars.id });
    assert.equal(res.data.pedidos[0].folio, pedidoDeAna.folio + 2);
  });

  test('sin perfil no se puede crear pedido', async () => {
    const carla = await alumno('carla');
    const { data } = await carla.mutation('CrearPedido', pedido());
    assert.equal(data._execute, 0);
    await signOut(carla.auth);
    await deleteApp(carla.app);
  });

  test('el precio enviado por el cliente se ignora', async () => {
    const vars = pedido({ items: [{ productoId: MOLLETES, cantidad: 1, precio: 0.01 }] });
    await ana.mutation('CrearPedido', vars);
    const res = await ana.query('MiPedido', { id: vars.id });
    assert.equal(res.data.pedidos[0].montoTotal, 40);
  });
});

describe('leer pedidos', () => {
  test('otro alumno no puede leer el pedido ajeno', async () => {
    const res = await beto.query('MiPedido', { id: pedidoDeAna.id });
    assert.equal(res.data.pedidos.length, 0);
  });

  test('MisPedidos solo regresa los del alumno', async () => {
    const res = await beto.query('MisPedidos');
    assert.equal(res.data.pedidos.length, 1);
    assert.ok(res.data.pedidos.every((p) => p.id !== pedidoDeAna.id));
  });

  test('el detalle guarda el precio del momento', async () => {
    const res = await ana.query('MisPedidos');
    const p = res.data.pedidos.find((x) => x.id === pedidoDeAna.id);
    const molletes = p.detallePedidos_on_pedido.find((d) => d.producto.nombre === 'Molletes');
    assert.equal(molletes.cantidad, 2);
    assert.equal(molletes.precioEnElMomento, 40);
  });
});

describe('roles', () => {
  test('un alumno nuevo no tiene rol', async () => {
    const { data } = await beto.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.rol, null);
  });

  test('el administrador asigna el rol de encargado con su cafetería', async () => {
    await comoAdmin('../dataconnect/agilu/mutations.gql', 'AsignarRol', {
      correo: 'beto@utng.edu.mx', rol: 'encargado', cafeteriaId: CAFETERIA,
    });
    const { data } = await beto.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.rol.nombre, 'encargado');
    assert.equal(data.autenticacion.usuario.cafeteria.id, CAFETERIA);
  });

  test('un alumno no puede asignarse un rol', async () => {
    await assert.rejects(
      ana.mutation('AsignarRol', { correo: 'ana@utng.edu.mx', rol: 'encargado' }),
    );
  });
});

describe('estaciones (HU-18)', () => {
  let nueva;

  test('el encargado ve las estaciones de su cafetería en orden', async () => {
    const { data } = await beto.query('MisEstaciones');
    assert.deepEqual(data.puestos.map((p) => p.nombre), ['Guisados', 'Tiendita']);
  });

  test('un alumno no ve estaciones para administrar', async () => {
    const { data } = await ana.query('MisEstaciones');
    assert.equal(data.puestos.length, 0);
  });

  test('el encargado crea una estación en su cafetería', async () => {
    const { data } = await beto.mutation('CrearEstacion', { nombre: 'Tacos', orden: 0 });
    nueva = data.puesto_insert.id;
    const res = await beto.query('MisEstaciones');
    assert.equal(res.data.puestos[0].nombre, 'Tacos');
  });

  test('un alumno no puede crear estaciones', async () => {
    await assert.rejects(ana.mutation('CrearEstacion', { nombre: 'Falsa', orden: 1 }));
  });

  test('el encargado renombra y desactiva una estación', async () => {
    await beto.mutation('EditarEstacion', {
      id: nueva, nombre: 'Tacos al pastor', orden: 3, activo: false,
    });
    const { data } = await beto.query('MisEstaciones');
    const t = data.puestos.find((p) => p.id === nueva);
    assert.equal(t.nombre, 'Tacos al pastor');
    assert.equal(t.activo, false);
  });

  test('no se puede editar la estación de otra cafetería', async () => {
    await assert.rejects(beto.mutation('EditarEstacion', {
      id: 'a0000000000040008000000000000002', nombre: 'X', orden: 1, activo: false,
    }));
  });

  test('una estación con productos no se puede eliminar', async () => {
    await assert.rejects(beto.mutation('EliminarEstacion', {
      id: 'a0000000000040008000000000000001',
    }));
  });

  test('una estación vacía sí se elimina', async () => {
    await beto.mutation('EliminarEstacion', { id: nueva });
    const { data } = await beto.query('MisEstaciones');
    assert.ok(data.puestos.every((p) => p.id !== nueva));
  });

  test('los productos de una estación desactivada salen del menú', async () => {
    await beto.mutation('EditarEstacion', {
      id: 'a0000000000040008000000000000003', nombre: 'Tiendita', orden: 2, activo: false,
    });
    const { data } = await ana.query('ListarMenu');
    assert.ok(data.productos.every((p) => p.nombre !== 'Agua de horchata'));
    await beto.mutation('EditarEstacion', {
      id: 'a0000000000040008000000000000003', nombre: 'Tiendita', orden: 2, activo: true,
    });
  });
});

describe('lista de productos del encargado (HU-14)', () => {
  test('el encargado ve solo los productos de su cafetería', async () => {
    const { data } = await beto.query('MisProductos');
    const nombres = data.productos.map((p) => p.nombre);
    assert.ok(nombres.length >= 5);
    assert.ok(!nombres.includes('Capuchino'));
    assert.ok(data.productos.every((p) => p.puesto.cafeteria.id === CAFETERIA));
  });

  test('incluye los no disponibles para poder reactivarlos', async () => {
    const { data } = await beto.query('MisProductos');
    const cafe = data.productos.find((p) => p.nombre === 'Café americano');
    assert.equal(cafe.disponible, false);
  });

  test('un alumno no ve la lista de administración', async () => {
    const { data } = await ana.query('MisProductos');
    assert.equal(data.productos.length, 0);
  });
});

describe('crear producto (HU-13)', () => {
  const GUISADOS = 'a0000000000040008000000000000001';
  const nuevo = (cambios = {}) => ({
    nombre: 'Enchiladas', descripcion: 'Rojas', precio: 45,
    puestoId: GUISADOS, disponible: true, ...cambios,
  });

  test('el encargado crea un producto y aparece en el menú', async () => {
    await beto.mutation('CrearMiProducto', nuevo());
    const { data } = await ana.query('ListarMenu');
    const p = data.productos.find((x) => x.nombre === 'Enchiladas');
    assert.equal(p.precio, 45);
    assert.equal(p.puesto.cafeteria.id, CAFETERIA);
  });

  test('el servidor rechaza nombre vacío y precio no positivo', async () => {
    await assert.rejects(beto.mutation('CrearMiProducto', nuevo({ nombre: '   ' })), /nombre es obligatorio/);
    await assert.rejects(beto.mutation('CrearMiProducto', nuevo({ precio: 0 })), /mayor a 0/);
    await assert.rejects(beto.mutation('CrearMiProducto', nuevo({ precio: -5 })), /mayor a 0/);
  });

  test('no se puede crear en la estación de otra cafetería', async () => {
    await assert.rejects(
      beto.mutation('CrearMiProducto', nuevo({ puestoId: 'a0000000000040008000000000000002' })),
      /no es de tu cafetería/,
    );
  });

  test('un alumno no puede crear productos', async () => {
    await assert.rejects(ana.mutation('CrearMiProducto', nuevo()), /no es de tu cafetería/);
  });
});

describe('editar producto (HU-15)', () => {
  const MOLLETES_ID = MOLLETES;
  const TIENDITA = 'a0000000000040008000000000000003';
  const cambio = (c = {}) => ({
    id: MOLLETES_ID, nombre: 'Molletes', descripcion: 'Con frijoles',
    precio: 42, puestoId: 'a0000000000040008000000000000001', disponible: true, ...c,
  });

  test('el encargado cambia precio, descripción y sección', async () => {
    await beto.mutation('EditarMiProducto', cambio({ puestoId: TIENDITA }));
    const { data } = await beto.query('MisProductos');
    const m = data.productos.find((p) => p.id === MOLLETES_ID);
    assert.equal(m.precio, 42);
    assert.equal(m.descripcion, 'Con frijoles');
    assert.equal(m.puesto.id, TIENDITA);
  });

  test('los pedidos anteriores conservan el precio con que se compraron', async () => {
    const res = await ana.query('MisPedidos');
    const p = res.data.pedidos.find((x) => x.id === pedidoDeAna.id);
    const d = p.detallePedidos_on_pedido.find((x) => x.producto.nombre === 'Molletes');
    assert.equal(d.precioEnElMomento, 40);
  });

  test('no se puede mover el producto a otra cafetería', async () => {
    await assert.rejects(
      beto.mutation('EditarMiProducto', cambio({ puestoId: 'a0000000000040008000000000000002' })),
      /no es de tu cafetería/,
    );
  });

  test('no se puede editar un producto de otra cafetería', async () => {
    await assert.rejects(
      beto.mutation('EditarMiProducto', cambio({ id: CAPUCHINO })),
      /no es de tu cafetería/,
    );
  });

  test('un alumno no puede editar productos', async () => {
    await assert.rejects(ana.mutation('EditarMiProducto', cambio()), /no es de tu cafetería/);
  });

  test('el servidor valida precio al editar', async () => {
    await assert.rejects(beto.mutation('EditarMiProducto', cambio({ precio: 0 })), /mayor a 0/);
  });
});

describe('disponibilidad (HU-16)', () => {
  const TORTA = 'b0000000000040008000000000000003';
  const CHILAQUILES = 'b0000000000040008000000000000001';

  test('el encargado marca un producto agotado y sale gris del carrito', async () => {
    await beto.mutation('EstablecerDisponibilidad', { id: TORTA, disponible: false });
    const { data } = await ana.query('ListarMenu');
    assert.equal(data.productos.find((p) => p.id === TORTA).disponible, false);
    const r = await ana.mutation('CrearPedido', pedido({ items: [{ productoId: TORTA, cantidad: 1 }] }));
    assert.equal(r.data._execute, 0);
    await beto.mutation('EstablecerDisponibilidad', { id: TORTA, disponible: true });
  });

  test('no se puede cambiar la disponibilidad de otra cafetería', async () => {
    await assert.rejects(
      beto.mutation('EstablecerDisponibilidad', { id: CAPUCHINO, disponible: false }),
      /no es de tu cafetería/,
    );
  });

  test('un alumno no puede cambiar la disponibilidad', async () => {
    await assert.rejects(
      ana.mutation('EstablecerDisponibilidad', { id: TORTA, disponible: false }),
      /no es de tu cafetería/,
    );
  });

  // El emulador de Functions aún no ejecuta disparadores de SQL Connect, así
  // que se llama al manejador con el mismo evento que enviaría el servicio.
  test('al agotarse, la función cancela solo los pedidos pendientes que lo incluyen', async () => {
    const { cancelarSiQuedoAgotado } = createRequire(import.meta.url)('../functions/cancelaciones.js');
    const conProducto = pedido({ items: [{ productoId: CHILAQUILES, cantidad: 1 }] });
    const sinProducto = pedido({ items: [{ productoId: HORCHATA, cantidad: 1 }] });
    await ana.mutation('CrearPedido', conProducto);
    await ana.mutation('CrearPedido', sinProducto);

    const variables = { id: CHILAQUILES, disponible: false };
    await beto.mutation('EstablecerDisponibilidad', variables);
    const evento = { data: { payload: { variables, data: {}, errors: [] } } };
    const cancelados = await cancelarSiQuedoAgotado(evento, adminDataConnect);
    assert.ok(cancelados >= 1);

    const res = await ana.query('MiPedido', { id: conProducto.id });
    assert.equal(res.data.pedidos[0].estado, 'cancelado');
    const otro = await ana.query('MiPedido', { id: sinProducto.id });
    assert.equal(otro.data.pedidos[0].estado, 'pendiente');
    await beto.mutation('EstablecerDisponibilidad', { id: CHILAQUILES, disponible: true });
  });

  test('volver a marcarlo disponible no cancela nada', async () => {
    const { cancelarSiQuedoAgotado } = createRequire(import.meta.url)('../functions/cancelaciones.js');
    const evento = {
      data: { payload: { variables: { id: CHILAQUILES, disponible: true }, errors: [] } },
    };
    assert.equal(await cancelarSiQuedoAgotado(evento, adminDataConnect), 0);
  });
});

describe('eliminar producto (HU-17)', () => {
  const ENCHILADAS = async () => {
    const { data } = await beto.query('MisProductos');
    return data.productos.find((p) => p.nombre === 'Enchiladas').id;
  };

  test('el producto eliminado sale del menú y de la lista del encargado', async () => {
    const id = await ENCHILADAS();
    const vars = pedido({ items: [{ productoId: id, cantidad: 1 }] });
    await ana.mutation('CrearPedido', vars);

    await beto.mutation('EliminarMiProducto', { id });
    const menu = await ana.query('ListarMenu');
    assert.ok(menu.data.productos.every((p) => p.id !== id));
    const lista = await beto.query('MisProductos');
    assert.ok(lista.data.productos.every((p) => p.id !== id));

    const r = await ana.mutation('CrearPedido', pedido({ items: [{ productoId: id, cantidad: 1 }] }));
    assert.equal(r.data._execute, 0);

    const mios = await ana.query('MisPedidos');
    const anterior = mios.data.pedidos.find((p) => p.id === vars.id.replaceAll('-', ''));
    const d = anterior.detallePedidos_on_pedido[0];
    assert.equal(d.producto.nombre, 'Enchiladas');
    assert.equal(d.precioEnElMomento, 45);
  });

  test('no se puede eliminar un producto de otra cafetería', async () => {
    await assert.rejects(beto.mutation('EliminarMiProducto', { id: CAPUCHINO }), /no es de tu cafetería/);
  });

  test('un alumno no puede eliminar productos', async () => {
    await assert.rejects(ana.mutation('EliminarMiProducto', { id: MOLLETES }), /no es de tu cafetería/);
  });

  test('una estación cuyos productos se eliminaron ya se puede eliminar', async () => {
    const { data } = await beto.mutation('CrearEstacion', { nombre: 'Temporal', orden: 9 });
    const estacion = data.puesto_insert.id;
    await beto.mutation('CrearMiProducto', {
      nombre: 'Elote', precio: 25, puestoId: estacion, disponible: true,
    });
    await assert.rejects(beto.mutation('EliminarEstacion', { id: estacion }));
    const lista = await beto.query('MisProductos');
    const elote = lista.data.productos.find((p) => p.nombre === 'Elote').id;
    await beto.mutation('EliminarMiProducto', { id: elote });
    await beto.mutation('EliminarEstacion', { id: estacion });
  });
});

describe('catálogo', () => {
  test('un alumno no puede crear productos ni puestos', async () => {
    await assert.rejects(
      ana.mutation('CrearPuesto', { nombre: 'Falso', cafeteriaId: CAFETERIA }),
    );
    await assert.rejects(
      ana.mutation('CrearProducto', {
        nombre: 'Gratis', precio: 0, cantidadEnStock: 1, categoria: 'X',
        puestoId: 'a0000000000040008000000000000002',
      }),
    );
  });
});
