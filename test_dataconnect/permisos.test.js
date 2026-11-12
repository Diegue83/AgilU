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
// Las pruebas configuran la cafetería en UTC, abierta todo el día, sin
// anticipación y con franjas de 1 minuto; "pronto" es el siguiente minuto exacto.
const pronto = (minutos = 5) => {
  const t = new Date(Date.now() + minutos * 60 * 1000);
  t.setUTCSeconds(0, 0);
  return t.toISOString();
};
const enUnaHora = () => pronto(5);

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

// HU-08: deja un pedido pagado (comprobante en revisión y aprobado por el
// encargado) para las pruebas que necesitan pedidos ya en cocina.
async function pagado(vars) {
  await adminDataConnect.executeGraphql(
    'mutation R($id: UUID!) { pedido_update(id: $id, data: { estado: "pago_en_revision" }) }',
    { variables: { id: vars.id } },
  );
  const r = await beto.mutation('ValidarPago', { id: vars.id, aprobado: true });
  assert.equal(r.data._execute, 1);
}

const sembrarCatalogo = () =>
  comoAdmin('../dataconnect/seed_data.gql', 'SembrarCatalogo');

const CONFIG_PRUEBAS = `
  mutation ConfigurarPruebas($id: UUID!) {
    cafeteria_update(id: $id, data: {
      zonaHoraria: "UTC", aperturaMinutos: 0, cierreMinutos: 1439,
      anticipacionMinutos: 0, intervaloMinutos: 1, capacidadPorFranja: 100
    })
  }
`;

before(async () => {
  await sembrarCatalogo();
  await adminDataConnect.executeGraphql(CONFIG_PRUEBAS, { variables: { id: 'c0000000-0000-4000-8000-000000000001' } });
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
    assert.equal(p.estado, 'por_pagar');
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
  test('toda cuenta nueva queda como alumno', async () => {
    const { data } = await beto.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.rol.nombre, 'alumno');
  });

  test('el registro guarda el teléfono y el servidor valida los datos', async () => {
    const fer = await alumno('fer');
    await assert.rejects(fer.mutation('CrearPerfil', { nombre: 'F' }));
    await assert.rejects(fer.mutation('CrearPerfil', { nombre: 'Fer Ruiz', telefono: '12-34' }));
    await fer.mutation('CrearPerfil', { nombre: 'Fer Ruiz', telefono: '4181234567' });
    const { data } = await fer.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.numeroDeTelefono, '4181234567');
    assert.equal(data.autenticacion.usuario.rol.nombre, 'alumno');
    await signOut(fer.auth);
    await deleteApp(fer.app);
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
    assert.equal(otro.data.pedidos[0].estado, 'por_pagar');
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

describe('foto del producto (HU-20)', () => {
  const { subirFoto } = createRequire(import.meta.url)('../functions/fotos.js');
  const JPG = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 1, 2, 3, 4]).toString('base64');
  const archivos = new Map();
  const bucket = {
    name: 'demo-agilu.appspot.com',
    file: (ruta) => ({ save: async (datos, opciones) => archivos.set(ruta, { datos, opciones }) }),
  };
  const deps = { dataConnect: adminDataConnect, bucket };
  const uidDe = (alumno) => alumno.auth.currentUser.uid;

  test('el encargado sube la foto y el menú muestra su URL', async () => {
    const { url } = await subirFoto(
      { uid: uidDe(beto), productoId: MOLLETES, imagenBase64: JPG, tipo: 'image/jpeg' }, deps,
    );
    const ruta = `productos/${CAFETERIA}/${MOLLETES}.jpg`;
    assert.ok(archivos.has(ruta));
    assert.equal(archivos.get(ruta).opciones.contentType, 'image/jpeg');
    assert.match(url, /^https:\/\/firebasestorage\.googleapis\.com\/.+token=/);
    const { data } = await ana.query('ListarMenu');
    assert.equal(data.productos.find((p) => p.id === MOLLETES).urlDeImagen, url);
  });

  test('un alumno no puede cambiar la foto', async () => {
    await assert.rejects(
      subirFoto({ uid: uidDe(ana), productoId: MOLLETES, imagenBase64: JPG, tipo: 'image/jpeg' }, deps),
      /no es de tu cafetería/,
    );
  });

  test('no se puede cambiar la foto de un producto de otra cafetería', async () => {
    await assert.rejects(
      subirFoto({ uid: uidDe(beto), productoId: CAPUCHINO, imagenBase64: JPG, tipo: 'image/jpeg' }, deps),
      /no es de tu cafetería/,
    );
  });

  test('sin sesión se rechaza', async () => {
    await assert.rejects(
      subirFoto({ uid: undefined, productoId: MOLLETES, imagenBase64: JPG, tipo: 'image/jpeg' }, deps),
      /Inicia sesión/,
    );
  });

  test('se rechazan archivos que no son imagen, tipos no permitidos y fotos grandes', async () => {
    const base = { uid: uidDe(beto), productoId: MOLLETES };
    const texto = Buffer.from('<script>alert(1)</script>').toString('base64');
    await assert.rejects(subirFoto({ ...base, imagenBase64: texto, tipo: 'image/jpeg' }, deps), /no es una imagen válida/);
    await assert.rejects(subirFoto({ ...base, imagenBase64: JPG, tipo: 'image/gif' }, deps), /JPG o PNG/);
    const grande = Buffer.alloc(1024 * 1024 + 1, 0xff).toString('base64');
    await assert.rejects(subirFoto({ ...base, imagenBase64: grande, tipo: 'image/jpeg' }, deps), /más de 1 MB/);
    await assert.rejects(subirFoto({ ...base, productoId: "1' OR 1=1", imagenBase64: JPG, tipo: 'image/jpeg' }, deps), /Producto inválido/);
  });
});

describe('menú del día (HU-19)', () => {
  test('el alumno ve las cafeterías activas con su horario', async () => {
    const { data } = await ana.query('ListarCafeterias');
    const central = data.cafeterias.find((c) => c.id === CAFETERIA);
    for (const campo of ['aperturaMinutos', 'cierreMinutos', 'anticipacionMinutos',
      'intervaloMinutos', 'capacidadPorFranja']) {
      assert.equal(typeof central[campo], 'number', campo);
    }
    assert.equal(central.nombre, 'Cafetería central');
  });

  test('sin sesión no se ven las cafeterías', async () => {
    const anonimo = initializeApp({ projectId: 'demo-agilu', apiKey: 'demo' }, 'anonimo-hu19');
    const dc = getDataConnect(anonimo, CONECTOR);
    connectDataConnectEmulator(dc, '127.0.0.1', 9399);
    await assert.rejects(executeQuery(queryRef(dc, 'ListarCafeterias')));
    await deleteApp(anonimo);
  });
});

describe('ofertas (HU-21)', () => {
  const TORTA = 'b0000000000040008000000000000003';
  const manana = () => new Date(Date.now() + 24 * 3600 * 1000).toISOString();

  test('el encargado publica una oferta y el pedido cobra el precio promocional', async () => {
    await beto.mutation('PublicarOferta', {
      id: TORTA, precioOferta: 35, hasta: manana(), esEspecialidad: true,
    });
    const { data } = await ana.query('ListarMenu');
    const torta = data.productos.find((p) => p.id === TORTA);
    assert.equal(torta.precioOferta, 35);
    assert.equal(torta.esEspecialidad, true);

    const vars = pedido({ items: [{ productoId: TORTA, cantidad: 2 }] });
    await ana.mutation('CrearPedido', vars);
    const res = await ana.query('MiPedido', { id: vars.id });
    assert.equal(res.data.pedidos[0].montoTotal, 70);
  });

  test('una oferta vencida ya no se cobra', async () => {
    await comoAdmin('../dataconnect/agilu/mutations.gql', 'QuitarOferta', { id: TORTA }).catch(() => {});
    await adminDataConnect.executeGraphql(
      'mutation V($id: UUID!, $h: Timestamp!) { producto_update(id: $id, data: { precioOferta: 10, ofertaHasta: $h }) }',
      { variables: { id: TORTA, h: new Date(Date.now() - 60000).toISOString() } },
    );
    const vars = pedido({ items: [{ productoId: TORTA, cantidad: 1 }] });
    await ana.mutation('CrearPedido', vars);
    const res = await ana.query('MiPedido', { id: vars.id });
    assert.equal(res.data.pedidos[0].montoTotal, 50);
  });

  test('el servidor valida precio y fecha de la oferta', async () => {
    await assert.rejects(beto.mutation('PublicarOferta', {
      id: TORTA, precioOferta: 60, hasta: manana(), esEspecialidad: false,
    }), /menos que el precio normal/);
    await assert.rejects(beto.mutation('PublicarOferta', {
      id: TORTA, precioOferta: 30, hasta: new Date(Date.now() - 1000).toISOString(), esEspecialidad: false,
    }), /ya pasó/);
    await assert.rejects(beto.mutation('PublicarOferta', {
      id: TORTA, precioOferta: 0, hasta: manana(), esEspecialidad: false,
    }), /mayor a 0/);
  });

  test('solo el encargado de esa cafetería publica o quita ofertas', async () => {
    await assert.rejects(ana.mutation('PublicarOferta', {
      id: TORTA, precioOferta: 30, hasta: manana(), esEspecialidad: false,
    }), /no es de tu cafetería/);
    await assert.rejects(beto.mutation('PublicarOferta', {
      id: CAPUCHINO, precioOferta: 30, hasta: manana(), esEspecialidad: false,
    }), /no es de tu cafetería/);
    await assert.rejects(ana.mutation('QuitarOferta', { id: TORTA }), /no es de tu cafetería/);
    await beto.mutation('QuitarOferta', { id: TORTA });
    const { data } = await ana.query('ListarMenu');
    assert.equal(data.productos.find((p) => p.id === TORTA).precioOferta, null);
  });
});

describe('pedido programado (HU-10)', () => {
  const minutoUTC = (iso) => { const d = new Date(iso); return d.getUTCHours() * 60 + d.getUTCMinutes(); };
  const configurar = (c) => adminDataConnect.executeGraphql(
    `mutation C($id: UUID!, $a: Int!, $ci: Int!, $an: Int!, $i: Int!, $cap: Int!) {
       cafeteria_update(id: $id, data: { aperturaMinutos: $a, cierreMinutos: $ci,
         anticipacionMinutos: $an, intervaloMinutos: $i, capacidadPorFranja: $cap })
     }`,
    { variables: { id: CAFETERIA, a: 0, ci: 1439, an: 0, i: 1, cap: 100, ...c } },
  );
  const restaurar = () => configurar({});
  const intentar = async (vars) => {
    const r = await ana.mutation('CrearPedido', vars);
    if (r.data._execute > 0) return null;
    const d = await ana.query('DiagnosticarPedido', {
      cafeteriaId: vars.cafeteriaId, recogerA: vars.recogerA, items: vars.items,
    });
    return d.data.diagnostico.motivo;
  };

  test('respeta la anticipación mínima configurada', async () => {
    await configurar({ an: 60 });
    assert.equal(await intentar(pedido({ recogerA: pronto(10) })),
      'Los pedidos requieren 60 minutos de anticipación. Elige otra hora.');
    await restaurar();
  });

  test('rechaza horas fuera del horario de la cafetería', async () => {
    const m = minutoUTC(pronto(30));
    await configurar({ a: 0, ci: Math.max(m - 20, 1) });
    assert.equal(await intentar(pedido({ recogerA: pronto(30) })),
      'La hora elegida está fuera del horario de la cafetería.');
    await restaurar();
  });

  test('solo acepta horas alineadas a las franjas', async () => {
    await configurar({ i: 15 });
    const t = new Date(pronto(10));
    const m = t.getUTCHours() * 60 + t.getUTCMinutes();
    if (m % 15 === 0) t.setUTCMinutes(t.getUTCMinutes() + 1);
    assert.notEqual(await intentar(pedido({ recogerA: t.toISOString() })), null);
    await restaurar();
  });

  test('una franja llena ya no acepta pedidos y la ocupación lo refleja', async () => {
    await configurar({ cap: 1 });
    const hora = pronto(20);
    assert.equal(await intentar(pedido({ recogerA: hora })), null);
    assert.equal(await intentar(pedido({ recogerA: hora })), 'Esa hora ya se llenó. Elige otra.');
    const { data } = await beto.query('OcupacionFranjas', { cafeteriaId: CAFETERIA });
    const f = data.franjas.find((x) => new Date(x.recogerA).getTime() === new Date(hora).getTime());
    assert.equal(f.pedidos, 1);
    assert.ok(Object.keys(f).every((k) => ['recogerA', 'pedidos'].includes(k)));
    await restaurar();
  });

  test('el diagnóstico explica productos no disponibles', async () => {
    const vars = pedido({ items: [{ productoId: CAFE_NO_DISPONIBLE, cantidad: 1 }] });
    assert.equal(await intentar(vars), 'Algún producto ya no está disponible. Revisa tu carrito.');
  });

  test('el encargado ajusta su cafetería y el servidor valida los valores', async () => {
    await beto.mutation('EditarMiCafeteria', {
      aperturaMinutos: 420, cierreMinutos: 1260, anticipacionMinutos: 30,
      intervaloMinutos: 10, capacidadPorFranja: 15, permitirInmediatos: false,
    });
    const { data } = await beto.query('MiCafeteria');
    assert.equal(data.autenticacion.usuario.cafeteria.capacidadPorFranja, 15);
    await assert.rejects(beto.mutation('EditarMiCafeteria', {
      aperturaMinutos: 900, cierreMinutos: 600, anticipacionMinutos: 30,
      intervaloMinutos: 10, capacidadPorFranja: 15, permitirInmediatos: false,
    }), /horario no es válido/);
    await assert.rejects(beto.mutation('EditarMiCafeteria', {
      aperturaMinutos: 420, cierreMinutos: 1260, anticipacionMinutos: 30,
      intervaloMinutos: 10, capacidadPorFranja: 0, permitirInmediatos: false,
    }), /capacidad/);
    await assert.rejects(ana.mutation('EditarMiCafeteria', {
      aperturaMinutos: 420, cierreMinutos: 1260, anticipacionMinutos: 0,
      intervaloMinutos: 10, capacidadPorFranja: 15, permitirInmediatos: false,
    }), /Solo el encargado/);
    await restaurar();
  });
});

describe('anticipación mínima (HU-07)', () => {
  const HORCHATA_ID = HORCHATA;
  const configurar = (an, inmediatos) => adminDataConnect.executeGraphql(
    `mutation C($id: UUID!, $an: Int!, $inm: Boolean!) {
       cafeteria_update(id: $id, data: { anticipacionMinutos: $an, permitirInmediatos: $inm })
     }`,
    { variables: { id: CAFETERIA, an, inm: inmediatos } },
  );
  const marcarInmediato = (id, valor) => adminDataConnect.executeGraphql(
    'mutation M($id: UUID!, $v: Boolean!) { producto_update(id: $id, data: { preparacionInmediata: $v }) }',
    { variables: { id, v: valor } },
  );

  test('sin la opción habilitada, ni las bebidas se aceptan antes de la anticipación', async () => {
    await configurar(60, false);
    await marcarInmediato(HORCHATA_ID, true);
    const r = await ana.mutation('CrearPedido', pedido({ recogerA: pronto(10), items: [{ productoId: HORCHATA_ID, cantidad: 1 }] }));
    assert.equal(r.data._execute, 0);
  });

  test('con la opción habilitada, un pedido solo de inmediatos se acepta sin anticipación', async () => {
    await configurar(60, true);
    const r = await ana.mutation('CrearPedido', pedido({ recogerA: pronto(10), items: [{ productoId: HORCHATA_ID, cantidad: 1 }] }));
    assert.equal(r.data._execute, 1);
  });

  test('si el pedido mezcla un platillo, vuelve a pedir la anticipación', async () => {
    const r = await ana.mutation('CrearPedido', pedido({
      recogerA: pronto(10),
      items: [{ productoId: HORCHATA_ID, cantidad: 1 }, { productoId: MOLLETES, cantidad: 1 }],
    }));
    assert.equal(r.data._execute, 0);
    const d = await ana.query('DiagnosticarPedido', {
      cafeteriaId: CAFETERIA, recogerA: pronto(10),
      items: [{ productoId: HORCHATA_ID, cantidad: 1 }, { productoId: MOLLETES, cantidad: 1 }],
    });
    assert.equal(d.data.diagnostico.motivo, 'Los pedidos requieren 60 minutos de anticipación. Elige otra hora.');
    await configurar(0, false);
    await marcarInmediato(HORCHATA_ID, false);
  });
});

describe('panel operativo (HU-06)', () => {
  const hoy = () => {
    const d = new Date();
    const desde = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
    return { desde: desde.toISOString(), hasta: new Date(desde.getTime() + 864e5).toISOString() };
  };
  let id;

  test('el encargado ve los pedidos de hoy de su cafetería en orden de recogida', async () => {
    const vars = pedido({ recogerA: pronto(3) });
    await ana.mutation('CrearPedido', vars);
    await pagado(vars);
    id = sinGuiones(vars.id);
    const { data } = await beto.query('PanelPedidos', hoy());
    assert.ok(data.pedidos.length > 0);
    assert.ok(data.pedidos.some((p) => p.id === id));
    assert.ok(data.pedidos.every((p) => ['pendiente', 'preparando', 'listo'].includes(p.estado)));
    const horas = data.pedidos.map((p) => new Date(p.recogerA).getTime());
    assert.deepEqual(horas, [...horas].sort((a, b) => a - b));
    const p = data.pedidos.find((x) => x.id === id);
    assert.equal(p.usuario.nombre, 'Ana');
  });

  test('un alumno no ve el panel', async () => {
    const { data } = await ana.query('PanelPedidos', hoy());
    assert.equal(data.pedidos.length, 0);
  });

  test('el pedido avanza un paso a la vez', async () => {
    const saltar = await beto.mutation('AvanzarPedido', { id, estado: 'listo' });
    assert.equal(saltar.data._execute, 0);
    const a = await beto.mutation('AvanzarPedido', { id, estado: 'preparando' });
    assert.equal(a.data._execute, 1);
    const repetir = await beto.mutation('AvanzarPedido', { id, estado: 'preparando' });
    assert.equal(repetir.data._execute, 0);
    const b = await beto.mutation('AvanzarPedido', { id, estado: 'listo' });
    assert.equal(b.data._execute, 1);
    const res = await ana.query('MiPedido', { id });
    assert.equal(res.data.pedidos[0].estado, 'listo');
  });

  test('no se aceptan otros estados ni pedidos ajenos', async () => {
    await assert.rejects(beto.mutation('AvanzarPedido', { id, estado: 'entregado' }));
    await assert.rejects(beto.mutation('AvanzarPedido', { id, estado: 'cancelado' }));
    const otro = pedido({ recogerA: pronto(4) });
    await ana.mutation('CrearPedido', otro);
    const r = await ana.mutation('AvanzarPedido', { id: otro.id, estado: 'preparando' });
    assert.equal(r.data._execute, 0);
  });
});

describe('pago anticipado (HU-08)', () => {
  const { subirComprobante } = createRequire(import.meta.url)('../functions/comprobantes.js');
  const JPG = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 9, 9]).toString('base64');
  const guardados = new Map();
  const bucket = {
    name: 'demo-agilu.appspot.com',
    file: (ruta) => ({ save: async (d) => guardados.set(ruta, d) }),
  };
  const deps = { dataConnect: adminDataConnect, bucket };
  const uidDe = (a) => a.auth.currentUser.uid;
  let vars;

  test('el pedido nace por pagar con su referencia y no entra al panel', async () => {
    vars = pedido({ recogerA: pronto(6) });
    await ana.mutation('CrearPedido', vars);
    const { data } = await ana.query('MiPedido', { id: vars.id });
    const p = data.pedidos[0];
    assert.equal(p.estado, 'por_pagar');
    assert.equal(p.referenciaPago, `AGU-${String(p.folio).padStart(5, '0')}`);
    assert.equal(p.cafeteria.clabe, '000000000000000000');
    const hoy = new Date(); hoy.setUTCHours(0, 0, 0, 0);
    const panel = await beto.query('PanelPedidos', {
      desde: hoy.toISOString(), hasta: new Date(hoy.getTime() + 864e5).toISOString(),
    });
    assert.ok(panel.data.pedidos.every((x) => x.id !== sinGuiones(vars.id)));
  });

  test('otro alumno no puede subir el comprobante de un pedido ajeno', async () => {
    await assert.rejects(
      subirComprobante({ uid: uidDe(beto), pedidoId: vars.id, imagenBase64: JPG, tipo: 'image/jpeg' }, deps),
      /no es tuyo/,
    );
  });

  test('el alumno sube su comprobante y el pedido queda en revisión', async () => {
    await subirComprobante({ uid: uidDe(ana), pedidoId: vars.id, imagenBase64: JPG, tipo: 'image/jpeg' }, deps);
    assert.ok([...guardados.keys()].some((k) => k.startsWith(`comprobantes/${CAFETERIA}/`)));
    const { data } = await ana.query('MiPedido', { id: vars.id });
    assert.equal(data.pedidos[0].estado, 'pago_en_revision');
    await assert.rejects(
      subirComprobante({ uid: uidDe(ana), pedidoId: vars.id, imagenBase64: JPG, tipo: 'image/jpeg' }, deps),
      /ya no espera comprobante/,
    );
  });

  test('el encargado ve los pagos por validar; un alumno no', async () => {
    const enc = await beto.query('PagosPorValidar');
    assert.ok(enc.data.pagos === undefined);
    assert.ok(enc.data.pedidos.some((p) => p.id === sinGuiones(vars.id)));
    const alu = await ana.query('PagosPorValidar');
    assert.equal(alu.data.pedidos.length, 0);
  });

  test('rechazar pide motivo y regresa el pedido a por pagar', async () => {
    await assert.rejects(beto.mutation('ValidarPago', { id: vars.id, aprobado: false }));
    await assert.rejects(beto.mutation('ValidarPago', { id: vars.id, aprobado: false, motivo: '   ' }));
    const r = await beto.mutation('ValidarPago', {
      id: vars.id, aprobado: false, motivo: 'La referencia no coincide',
    });
    assert.equal(r.data._execute, 1);
    const { data } = await ana.query('MiPedido', { id: vars.id });
    assert.equal(data.pedidos[0].estado, 'por_pagar');
    assert.equal(data.pedidos[0].motivoRechazoPago, 'La referencia no coincide');
  });

  test('un alumno no puede aprobar pagos', async () => {
    await subirComprobante({ uid: uidDe(ana), pedidoId: vars.id, imagenBase64: JPG, tipo: 'image/jpeg' }, deps);
    const r = await ana.mutation('ValidarPago', { id: vars.id, aprobado: true });
    assert.equal(r.data._execute, 0);
  });

  test('al aprobar, el pedido queda pagado y entra a cocina', async () => {
    const r = await beto.mutation('ValidarPago', { id: vars.id, aprobado: true });
    assert.equal(r.data._execute, 1);
    const { data } = await ana.query('MiPedido', { id: vars.id });
    assert.equal(data.pedidos[0].estado, 'pendiente');
    assert.ok(data.pedidos[0].pagadoEn);
    assert.equal(data.pedidos[0].motivoRechazoPago, null);
    const otra = await beto.mutation('ValidarPago', { id: vars.id, aprobado: true });
    assert.equal(otra.data._execute, 0);
  });
});

describe('entrega con código (HU-09)', () => {
  let vars;
  let codigo;

  test('al aprobar el pago se genera un PIN de 4 dígitos que solo ve el alumno', async () => {
    vars = pedido({ recogerA: pronto(7) });
    await ana.mutation('CrearPedido', vars);
    await pagado(vars);
    const { data } = await ana.query('MiPedido', { id: vars.id });
    codigo = data.pedidos[0].codigoEntrega;
    assert.match(codigo, /^\d{4}$/);
    const hoy = new Date(); hoy.setUTCHours(0, 0, 0, 0);
    const panel = await beto.query('PanelPedidos', {
      desde: hoy.toISOString(), hasta: new Date(hoy.getTime() + 864e5).toISOString(),
    });
    const enPanel = panel.data.pedidos.find((p) => p.id === sinGuiones(vars.id));
    assert.equal(enPanel.codigoEntrega, undefined);
  });

  test('no se entrega un pedido que todavía no está listo', async () => {
    const { data } = await beto.mutation('EntregarPedido', { id: vars.id, codigo });
    assert.equal(data.resultado, null);
  });

  test('un código equivocado suma intento y no entrega', async () => {
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'preparando' });
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'listo' });
    const malo = codigo === '0000' ? '1111' : '0000';
    const { data } = await beto.mutation('EntregarPedido', { id: vars.id, codigo: malo });
    assert.equal(data.resultado.estado, 'listo');
    assert.equal(data.resultado.intentos, 1);
  });

  test('un alumno no puede entregar pedidos aunque sepa el código', async () => {
    const { data } = await ana.mutation('EntregarPedido', { id: vars.id, codigo });
    assert.equal(data.resultado, null);
  });

  test('con el código correcto queda entregado y no se puede volver a usar', async () => {
    const { data } = await beto.mutation('EntregarPedido', { id: vars.id, codigo });
    assert.equal(data.resultado.estado, 'entregado');
    const otra = await beto.mutation('EntregarPedido', { id: vars.id, codigo });
    assert.equal(otra.data.resultado, null);
    const mio = await ana.query('MiPedido', { id: vars.id });
    assert.equal(mio.data.pedidos[0].estado, 'entregado');
    assert.ok(mio.data.pedidos[0].entregadoEn);
  });

  test('tras 5 códigos equivocados el pedido se bloquea', async () => {
    const otro = pedido({ recogerA: pronto(8) });
    await ana.mutation('CrearPedido', otro);
    await pagado(otro);
    await beto.mutation('AvanzarPedido', { id: otro.id, estado: 'preparando' });
    await beto.mutation('AvanzarPedido', { id: otro.id, estado: 'listo' });
    const bueno = (await ana.query('MiPedido', { id: otro.id })).data.pedidos[0].codigoEntrega;
    const malo = bueno === '0000' ? '1111' : '0000';
    for (let i = 0; i < 5; i++) {
      await beto.mutation('EntregarPedido', { id: otro.id, codigo: malo });
    }
    const { data } = await beto.mutation('EntregarPedido', { id: otro.id, codigo: bueno });
    assert.equal(data.resultado, null);
  });
});

describe('sistema de confianza (HU-23)', () => {
  const { cerrarDia } = createRequire(import.meta.url)('../functions/cierre.js');
  let dani;

  const listoYVencido = async (alumno) => {
    const vars = pedido({ recogerA: pronto(2) });
    await alumno.mutation('CrearPedido', vars);
    await pagado(vars);
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'preparando' });
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'listo' });
    await adminDataConnect.executeGraphql(
      'mutation V($id: UUID!, $t: Timestamp!) { pedido_update(id: $id, data: { recogerA: $t }) }',
      { variables: { id: vars.id, t: new Date(Date.now() - 3600e3).toISOString() } },
    );
    return vars;
  };

  before(async () => {
    dani = await alumno('dani');
    await dani.mutation('CrearPerfil', { nombre: 'Dani' });
  });

  after(async () => {
    await signOut(dani.auth);
    await deleteApp(dani.app);
  });

  test('el encargado marca un pedido listo y vencido como no recogido', async () => {
    const vars = await listoYVencido(dani);
    const r = await beto.mutation('MarcarNoRecogido', { id: vars.id });
    assert.equal(r.data._execute, 1);
    const { data } = await dani.query('MiConfianza');
    assert.equal(data.confianza.noRecogidos, 1);
  });

  test('no se puede marcar un pedido que todavía no llega a su hora', async () => {
    const vars = pedido({ recogerA: pronto(30) });
    await dani.mutation('CrearPedido', vars);
    await pagado(vars);
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'preparando' });
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'listo' });
    const r = await beto.mutation('MarcarNoRecogido', { id: vars.id });
    assert.equal(r.data._execute, 0);
  });

  test('un alumno no puede marcar pedidos', async () => {
    const vars = await listoYVencido(dani);
    const r = await dani.mutation('MarcarNoRecogido', { id: vars.id });
    assert.equal(r.data._execute, 0);
  });

  test('el cierre del día marca lo no recogido y cancela lo que nunca se pagó', async () => {
    const sinPagar = pedido({ recogerA: pronto(2) });
    await dani.mutation('CrearPedido', sinPagar);
    await adminDataConnect.executeGraphql(
      'mutation V($id: UUID!, $t: Timestamp!) { pedido_update(id: $id, data: { recogerA: $t }) }',
      { variables: { id: sinPagar.id, t: new Date(Date.now() - 3600e3).toISOString() } },
    );
    const r = await cerrarDia(adminDataConnect);
    assert.ok(r.noRecogidos >= 1);
    assert.ok(r.sinPagar >= 1);
    const { data } = await dani.query('MiPedido', { id: sinPagar.id });
    assert.equal(data.pedidos[0].estado, 'cancelado');
    const c = await dani.query('MiConfianza');
    assert.equal(c.data.confianza.noRecogidos, 2);
  });

  test('con 3 pedidos sin recoger ya no puede pedir y el diagnóstico lo explica', async () => {
    const vars = await listoYVencido(dani);
    await beto.mutation('MarcarNoRecogido', { id: vars.id });
    const nuevo = pedido({ recogerA: pronto(5) });
    const r = await dani.mutation('CrearPedido', nuevo);
    assert.equal(r.data._execute, 0);
    const d = await dani.query('DiagnosticarPedido', {
      cafeteriaId: CAFETERIA, recogerA: nuevo.recogerA, items: nuevo.items,
    });
    assert.match(d.data.diagnostico.motivo, /3 pedidos sin recoger/);
  });

  test('a los demás alumnos no les afecta', async () => {
    const r = await ana.mutation('CrearPedido', pedido({ recogerA: pronto(5) }));
    assert.equal(r.data._execute, 2);
  });
});

describe('aviso de pedido listo (HU-05)', () => {
  const { avisarPedidoListo } = createRequire(import.meta.url)('../functions/avisos.js');
  const TOKEN_ANA = 'token-de-prueba-ana-'.padEnd(40, 'x');
  const enviados = [];
  const messaging = {
    sendEachForMulticast: async (m) => {
      enviados.push(m);
      return {
        successCount: m.tokens.filter((t) => !t.startsWith('viejo')).length,
        responses: m.tokens.map((t) => (t.startsWith('viejo')
          ? { success: false, error: { code: 'messaging/registration-token-not-registered' } }
          : { success: true })),
      };
    },
  };

  test('el alumno registra su dispositivo; tokens o plataformas raros se rechazan', async () => {
    await ana.mutation('RegistrarDispositivo', { token: TOKEN_ANA, plataforma: 'android' });
    await assert.rejects(ana.mutation('RegistrarDispositivo', { token: 'corto', plataforma: 'android' }), /Token inválido/);
    await assert.rejects(ana.mutation('RegistrarDispositivo', { token: TOKEN_ANA, plataforma: 'nevera' }));
  });

  test('al marcar listo se avisa al dueño del pedido y se guarda la notificación', async () => {
    const vars = pedido({ recogerA: pronto(9) });
    await ana.mutation('CrearPedido', vars);
    await pagado(vars);
    await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'preparando' });
    const r = await beto.mutation('AvanzarPedido', { id: vars.id, estado: 'listo' });

    await adminDataConnect.executeGraphql(
      'mutation T($u: UUID!) { dispositivoToken_upsert(data: { token: "viejo-token-invalido-000000000000", plataforma: "android", usuario: { id: $u } }) }',
      { variables: { u: (await ana.query('MiPerfil')).data.autenticacion.usuario.id } },
    );
    const evento = { data: { payload: { variables: { id: vars.id, estado: 'listo' }, data: r.data, errors: [] } } };
    const n = await avisarPedidoListo(evento, { dataConnect: adminDataConnect, messaging });
    assert.equal(n, 1);
    const ultimo = enviados.at(-1);
    assert.ok(ultimo.tokens.includes(TOKEN_ANA));
    assert.match(ultimo.notification.body, /AGU-\d{5}/);

    const { data } = await ana.query('MisNotificaciones');
    assert.equal(data.notificacions[0].titulo, 'Tu pedido está listo');
    const otros = await beto.query('MisNotificaciones');
    assert.equal(otros.data.notificacions.length, 0);
  });

  test('los tokens inválidos se borran después del envío', async () => {
    const res = await adminDataConnect.executeGraphql(
      'query { dispositivoTokens(where: { token: { startsWith: "viejo" } }) { token } }',
    );
    assert.equal(res.data.dispositivoTokens.length, 0);
  });

  test('pasar a preparando no avisa', async () => {
    const antes = enviados.length;
    const evento = { data: { payload: { variables: { id: CAFETERIA, estado: 'preparando' }, data: { _execute: 1 }, errors: [] } } };
    assert.equal(await avisarPedidoListo(evento, { dataConnect: adminDataConnect, messaging }), 0);
    assert.equal(enviados.length, antes);
  });

  test('al cerrar sesión se olvida el dispositivo', async () => {
    await ana.mutation('OlvidarDispositivo', { token: TOKEN_ANA });
    const res = await adminDataConnect.executeGraphql(
      'query T($t: String!) { dispositivoToken(key: { token: $t }) { token } }', { variables: { t: TOKEN_ANA } },
    );
    assert.equal(res.data.dispositivoToken, null);
  });
});

describe('reporte para la beneficiaria (HU-11)', () => {
  let elena;
  const periodo = () => ({
    desde: new Date(Date.now() - 2 * 864e5).toISOString(),
    hasta: new Date(Date.now() + 864e5).toISOString(),
  });

  before(async () => {
    elena = await alumno('elena');
    await elena.mutation('CrearPerfil', { nombre: 'Elena' });
    await comoAdmin('../dataconnect/agilu/mutations.gql', 'AsignarRol', {
      correo: 'elena@utng.edu.mx', rol: 'beneficiaria',
    });
  });

  after(async () => {
    await signOut(elena.auth);
    await deleteApp(elena.app);
  });

  test('la beneficiaria ve pedidos, ingresos y no recogidos por cafetería', async () => {
    const { data } = await elena.query('ReporteBeneficiaria', periodo());
    const central = data.filas.find((f) => sinGuiones(f.cafeteriaId) === CAFETERIA);
    assert.ok(central.pedidos > 0);
    assert.ok(central.entregados >= 1);
    assert.ok(central.noRecogidos >= 2);
    assert.ok(central.cancelados >= 1);
    assert.ok(central.ingresos > 0);
    assert.ok(central.montoNoRecogido > 0);
    const barra = data.filas.find((f) => sinGuiones(f.cafeteriaId) === BARRA);
    assert.equal(barra.pedidos, 0);
    assert.ok(data.filas.every((f) => Object.keys(f).every((k) => !/usuario|correo|nombre$/i.test(k))));
  });

  test('un periodo sin pedidos regresa ceros', async () => {
    const { data } = await elena.query('ReporteBeneficiaria', {
      desde: '2020-01-01T00:00:00Z', hasta: '2020-01-02T00:00:00Z',
    });
    assert.ok(data.filas.every((f) => f.pedidos === 0 && f.ingresos === 0));
  });

  test('alumnos y encargados no ven el reporte', async () => {
    const a = await ana.query('ReporteBeneficiaria', periodo());
    assert.equal(a.data.filas.length, 0);
    const b = await beto.query('ReporteBeneficiaria', periodo());
    assert.equal(b.data.filas.length, 0);
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

describe('administrador y personal', () => {
  let admin;
  let luis;
  let eva;
  let pedidoListo;

  before(async () => {
    admin = await alumno('admin');
    luis = await alumno('luis');
    eva = await alumno('eva');
    await admin.mutation('CrearPerfil', { nombre: 'Admin' });
    await luis.mutation('CrearPerfil', { nombre: 'Luis' });
    await eva.mutation('CrearPerfil', { nombre: 'Eva' });
    // El primer administrador se nombra desde la consola.
    await comoAdmin('../dataconnect/agilu/mutations.gql', 'AsignarRol', {
      correo: 'admin@utng.edu.mx', rol: 'admin',
    });
    pedidoListo = pedido();
    await ana.mutation('CrearPedido', pedidoListo);
    await pagado(pedidoListo);
  });

  after(async () => {
    for (const a of [admin, luis, eva]) {
      await signOut(a.auth);
      await deleteApp(a.app);
    }
  });

  test('solo el administrador ve cafeterías y personal', async () => {
    const a = await admin.query('CafeteriasAdmin');
    assert.ok(a.data.cafeterias.some((c) => sinGuiones(c.id) === CAFETERIA));
    const p = await admin.query('PersonalAdmin');
    assert.ok(p.data.personal.some((m) => m.correo === 'beto@utng.edu.mx' && m.rol === 'encargado'));
    for (const u of [ana, beto]) {
      assert.equal((await u.query('CafeteriasAdmin')).data.cafeterias.length, 0);
      assert.equal((await u.query('PersonalAdmin')).data.personal.length, 0);
    }
  });

  test('el administrador crea y desactiva una cafetería; nadie más puede', async () => {
    const r = await admin.mutation('CrearCafeteriaAdmin', { nombre: 'Kiosco', ubicacion: 'Gimnasio' });
    const id = r.data.cafeteria_insert.id;
    await admin.mutation('EditarCafeteriaAdmin', { id, nombre: 'Kiosco', ubicacion: 'Gimnasio', activa: false });
    const { data } = await admin.query('CafeteriasAdmin');
    assert.equal(data.cafeterias.find((c) => sinGuiones(c.id) === sinGuiones(id)).activa, false);
    await assert.rejects(admin.mutation('CrearCafeteriaAdmin', { nombre: '   ' }));
    await assert.rejects(ana.mutation('CrearCafeteriaAdmin', { nombre: 'Pirata' }));
    await assert.rejects(beto.mutation('EditarCafeteriaAdmin', { id, nombre: 'X', activa: true }));
  });

  test('el administrador asigna roles; encargado y empleado exigen cafetería activa', async () => {
    const sinCafeteria = await admin.mutation('AsignarRolAdmin', { correo: 'luis@utng.edu.mx', rol: 'empleado' });
    assert.equal(sinCafeteria.data.resultado, null);
    const ok = await admin.mutation('AsignarRolAdmin', {
      correo: 'LUIS@utng.edu.mx', rol: 'empleado', cafeteriaId: CAFETERIA,
    });
    assert.ok(ok.data.resultado);
    const { data } = await luis.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.rol.nombre, 'empleado');
    assert.equal(data.autenticacion.usuario.cafeteria.id, CAFETERIA);
    await assert.rejects(admin.mutation('AsignarRolAdmin', { correo: 'luis@utng.edu.mx', rol: 'superusuario' }));
  });

  test('el administrador no puede cambiar su propio rol y los demás no asignan roles', async () => {
    const r = await admin.mutation('AsignarRolAdmin', { correo: 'admin@utng.edu.mx', rol: 'alumno' });
    assert.equal(r.data.resultado, null);
    const a = await ana.mutation('AsignarRolAdmin', { correo: 'ana@utng.edu.mx', rol: 'admin' });
    assert.equal(a.data.resultado, null);
    const b = await beto.mutation('AsignarRolAdmin', { correo: 'eva@utng.edu.mx', rol: 'encargado', cafeteriaId: CAFETERIA });
    assert.equal(b.data.resultado, null);
    assert.equal((await eva.query('MiPerfil')).data.autenticacion.usuario.rol.nombre, 'alumno');
  });

  test('el empleado atiende pedidos pero no pagos, menú ni ajustes', async () => {
    const { data } = await luis.query('PanelPedidos', {
      desde: new Date(Date.now() - 864e5).toISOString(),
      hasta: new Date(Date.now() + 864e5).toISOString(),
    });
    assert.ok(data.pedidos.some((p) => p.id === sinGuiones(pedidoListo.id)));
    const r = await luis.mutation('AvanzarPedido', { id: pedidoListo.id, estado: 'preparando' });
    assert.equal(r.data._execute, 1);

    assert.equal((await luis.query('PagosPorValidar')).data.pedidos.length, 0);
    await assert.rejects(luis.mutation('CrearEstacion', { nombre: 'Falsa', orden: 9 }));
    await assert.rejects(luis.mutation('EditarMiCafeteria', {
      aperturaMinutos: 0, cierreMinutos: 1439, anticipacionMinutos: 0,
      intervaloMinutos: 15, capacidadPorFranja: 10, permitirInmediatos: false,
    }));
    assert.equal((await luis.query('MiPersonal')).data.personal.length, 0);
  });

  test('el encargado da de alta y quita empleados de su cafetería', async () => {
    const alta = await beto.mutation('AgregarEmpleado', { correo: 'eva@utng.edu.mx' });
    assert.ok(alta.data.resultado);
    const { data } = await beto.query('MiPersonal');
    const correos = data.personal.map((m) => m.correo);
    assert.deepEqual(correos.sort(), ['beto@utng.edu.mx', 'eva@utng.edu.mx', 'luis@utng.edu.mx']);

    const baja = await beto.mutation('QuitarEmpleado', { usuarioId: alta.data.resultado.usuarioId });
    assert.ok(baja.data.resultado);
    assert.equal((await eva.query('MiPerfil')).data.autenticacion.usuario.rol.nombre, 'alumno');
  });

  test('el encargado no puede ascender a otros roles ni tocar cuentas con rol', async () => {
    for (const correo of ['admin@utng.edu.mx', 'elena@utng.edu.mx', 'beto@utng.edu.mx', 'nadie@utng.edu.mx']) {
      const r = await beto.mutation('AgregarEmpleado', { correo });
      assert.equal(r.data.resultado, null, correo);
    }
    const yo = (await beto.query('MiPersonal')).data.personal.find((m) => m.rol === 'encargado');
    const r = await beto.mutation('QuitarEmpleado', { usuarioId: yo.usuarioId });
    assert.equal(r.data.resultado, null);
  });

  test('un alumno o un empleado no dan de alta personal', async () => {
    assert.equal((await ana.mutation('AgregarEmpleado', { correo: 'eva@utng.edu.mx' })).data.resultado, null);
    assert.equal((await luis.mutation('AgregarEmpleado', { correo: 'eva@utng.edu.mx' })).data.resultado, null);
    const luisId = (await admin.query('PersonalAdmin')).data.personal
      .find((m) => m.correo === 'luis@utng.edu.mx').usuarioId;
    assert.equal((await ana.mutation('QuitarEmpleado', { usuarioId: luisId })).data.resultado, null);
  });
});

describe('mi cuenta', () => {
  test('el alumno edita su nombre y teléfono; el servidor los valida', async () => {
    await ana.mutation('EditarMiPerfil', { nombre: 'Ana López', telefono: '4181112233' });
    const { data } = await ana.query('MiPerfil');
    assert.equal(data.autenticacion.usuario.nombre, 'Ana López');
    assert.equal(data.autenticacion.usuario.numeroDeTelefono, '4181112233');
    await assert.rejects(ana.mutation('EditarMiPerfil', { nombre: 'A' }));
    await assert.rejects(ana.mutation('EditarMiPerfil', { nombre: 'Ana', telefono: 'abc' }));
  });

  test('un alumno sin pedidos en curso elimina su cuenta y sus datos', async () => {
    const gil = await alumno('gil');
    await gil.mutation('CrearPerfil', { nombre: 'Gil Soto', telefono: '4189998877' });
    const antes = await gil.query('MiPerfil');
    const usuarioId = antes.data.autenticacion.usuario.id;
    await gil.mutation('EliminarMiCuenta');
    const { data } = await gil.query('MiPerfil');
    assert.equal(data.autenticacion, null);
    const anonimo = await adminDataConnect.executeGraphql(
      'query U($id: UUID!) { usuario(id: $id) { nombre numeroDeTelefono } }',
      { variables: { id: usuarioId } },
    );
    assert.equal(anonimo.data.usuario.nombre, 'Cuenta eliminada');
    assert.equal(anonimo.data.usuario.numeroDeTelefono, null);
    await signOut(gil.auth);
    await deleteApp(gil.app);
  });

  test('no se elimina con pedidos en curso ni si la cuenta es del personal', async () => {
    const hugo = await alumno('hugo');
    await hugo.mutation('CrearPerfil', { nombre: 'Hugo Paz' });
    await hugo.mutation('CrearPedido', pedido());
    await assert.rejects(hugo.mutation('EliminarMiCuenta'), /pedidos en curso/);
    assert.ok((await hugo.query('MiPerfil')).data.autenticacion);
    await assert.rejects(beto.mutation('EliminarMiCuenta'), /personal/);
    assert.ok((await beto.query('MiPerfil')).data.autenticacion);
    await signOut(hugo.auth);
    await deleteApp(hugo.app);
  });
});

describe('bandeja de avisos', () => {
  async function avisoPara(quien, titulo) {
    const { data } = await quien.query('MiPerfil');
    await adminDataConnect.executeGraphql(
      'mutation A($u: UUID!, $t: String!) { notificacion_insert(data: { titulo: $t, mensaje: "Pasa por tu pedido", usuario: { id: $u } }) }',
      { variables: { u: data.autenticacion.usuario.id, t: titulo } },
    );
  }

  test('cada usuario ve solo sus avisos y los marca como leídos', async () => {
    await avisoPara(ana, 'Tu pedido está listo');
    await avisoPara(beto, 'Aviso de Beto');

    const deAna = (await ana.query('MisNotificaciones')).data.notificacions;
    assert.ok(deAna.some((n) => n.titulo === 'Tu pedido está listo' && n.leido === false));
    assert.ok(deAna.every((n) => n.titulo !== 'Aviso de Beto'));

    await ana.mutation('MarcarAvisosLeidos');
    const despues = (await ana.query('MisNotificaciones')).data.notificacions;
    assert.ok(despues.every((n) => n.leido));

    const deBeto = (await beto.query('MisNotificaciones')).data.notificacions;
    assert.ok(deBeto.some((n) => n.titulo === 'Aviso de Beto' && n.leido === false));
  });
});

describe('cancelar pedido', () => {
  const estadoDe = async (quien, id) =>
    (await quien.query('MiPedido', { id })).data.pedidos[0].estado;

  test('el alumno cancela su pedido por pagar', async () => {
    const p = pedido();
    await ana.mutation('CrearPedido', p);
    const r = await ana.mutation('CancelarMiPedido', { id: p.id });
    assert.equal(r.data.resultado.pagado, false);
    assert.equal(await estadoDe(ana, p.id), 'cancelado');
  });

  test('un pedido pagado que espera cocina se cancela e indica reembolso', async () => {
    const p = pedido();
    await ana.mutation('CrearPedido', p);
    await pagado(p);
    const r = await ana.mutation('CancelarMiPedido', { id: p.id });
    assert.equal(r.data.resultado.pagado, true);
    const { data } = await ana.query('MiPedido', { id: p.id });
    assert.equal(data.pedidos[0].estado, 'cancelado');
    assert.equal(data.pedidos[0].codigoEntrega, null);
  });

  test('en preparación ya no se cancela', async () => {
    const p = pedido();
    await ana.mutation('CrearPedido', p);
    await pagado(p);
    await beto.mutation('AvanzarPedido', { id: p.id, estado: 'preparando' });
    const r = await ana.mutation('CancelarMiPedido', { id: p.id });
    assert.equal(r.data.resultado, null);
    assert.equal(await estadoDe(ana, p.id), 'preparando');
  });

  test('nadie cancela un pedido ajeno', async () => {
    const p = pedido();
    await ana.mutation('CrearPedido', p);
    assert.equal((await beto.mutation('CancelarMiPedido', { id: p.id })).data.resultado, null);
    assert.equal(await estadoDe(ana, p.id), 'por_pagar');
  });
});
