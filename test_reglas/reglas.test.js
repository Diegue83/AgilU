import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  doc,
  getDoc,
  runTransaction,
  serverTimestamp,
  setDoc,
  updateDoc,
  deleteDoc,
} from 'firebase/firestore';

let env;

const enUnaHora = () => Timestamp.fromMillis(Date.now() + 60 * 60 * 1000);

const pedidoDe = (uid, cambios = {}) => ({
  usuarioId: uid,
  cafeteriaId: 'cafeteria-central',
  items: [{ productoId: '1', nombre: 'Molletes', precioUnitario: 40, cantidad: 1 }],
  total: 40,
  estado: 'pendiente',
  folio: 'AGU-00001',
  recogerA: enUnaHora(),
  creadoEn: serverTimestamp(),
  ...cambios,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-agilu',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'productos/1'), { nombre: 'Molletes', precio: 40 });
    await setDoc(doc(db, 'pedidos/de-ana'), {
      ...pedidoDe('ana'),
      creadoEn: Timestamp.now(),
    });
    await setDoc(doc(db, 'contadores/folio'), { valor: 7 });
  });
});

describe('productos', () => {
  test('un alumno autenticado puede ver el menú', async () => {
    const db = env.authenticatedContext('ana').firestore();
    await assertSucceeds(getDoc(doc(db, 'productos/1')));
  });

  test('sin sesión no se puede ver el menú', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'productos/1')));
  });

  test('un alumno no puede modificar productos', async () => {
    const db = env.authenticatedContext('ana').firestore();
    await assertFails(updateDoc(doc(db, 'productos/1'), { precio: 1 }));
  });
});

describe('pedidos', () => {
  test('el dueño puede leer su pedido', async () => {
    const db = env.authenticatedContext('ana').firestore();
    await assertSucceeds(getDoc(doc(db, 'pedidos/de-ana')));
  });

  test('otro alumno no puede leer el pedido ajeno', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(getDoc(doc(db, 'pedidos/de-ana')));
  });

  test('sin sesión no se puede leer ningún pedido', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'pedidos/de-ana')));
  });

  test('un alumno puede crear su propio pedido', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertSucceeds(setDoc(doc(db, 'pedidos/nuevo'), pedidoDe('beto')));
  });

  test('no se puede crear un pedido a nombre de otro alumno', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(setDoc(doc(db, 'pedidos/nuevo'), pedidoDe('ana')));
  });

  test('no se puede crear un pedido ya marcado como listo', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(
      setDoc(doc(db, 'pedidos/nuevo'), pedidoDe('beto', { estado: 'listo' })),
    );
  });

  test('no se aceptan pedidos vacíos ni con total en cero', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(setDoc(doc(db, 'pedidos/a'), pedidoDe('beto', { items: [] })));
    await assertFails(setDoc(doc(db, 'pedidos/b'), pedidoDe('beto', { total: 0 })));
  });

  test('no se acepta una hora de recogida en el pasado', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(
      setDoc(
        doc(db, 'pedidos/nuevo'),
        pedidoDe('beto', { recogerA: Timestamp.fromMillis(Date.now() - 60000) }),
      ),
    );
  });

  test('no se aceptan campos extra en el pedido', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(
      setDoc(doc(db, 'pedidos/nuevo'), pedidoDe('beto', { pagado: true })),
    );
  });

  test('ni el dueño puede modificar o borrar su pedido', async () => {
    const db = env.authenticatedContext('ana').firestore();
    await assertFails(updateDoc(doc(db, 'pedidos/de-ana'), { estado: 'entregado' }));
    await assertFails(deleteDoc(doc(db, 'pedidos/de-ana')));
  });
});

describe('contador de folio', () => {
  test('la transacción de la app (contador + pedido) se permite', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertSucceeds(
      runTransaction(db, async (tx) => {
        const ref = doc(db, 'contadores/folio');
        const snap = await tx.get(ref);
        const siguiente = snap.data().valor + 1;
        tx.set(ref, { valor: siguiente });
        tx.set(doc(db, 'pedidos/nuevo'), pedidoDe('beto', { folio: 'AGU-00008' }));
      }),
    );
  });

  test('el contador no puede saltar ni regresar', async () => {
    const db = env.authenticatedContext('beto').firestore();
    await assertFails(setDoc(doc(db, 'contadores/folio'), { valor: 100 }));
    await assertFails(setDoc(doc(db, 'contadores/folio'), { valor: 1 }));
  });

  test('sin sesión no se puede tocar el contador', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(setDoc(doc(db, 'contadores/folio'), { valor: 8 }));
  });
});

describe('colecciones no declaradas', () => {
  test('se rechaza cualquier otra colección', async () => {
    const db = env.authenticatedContext('ana').firestore();
    await assertFails(setDoc(doc(db, 'usuarios/ana'), { rol: 'admin' }));
  });
});
