import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
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
