// Pruebas de las reglas de avisos: node --test supabase/functions/avisar/
import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  AvisoRechazado,
  avisoDePedido,
  avisoDeSolicitud,
  formatearFolio,
  type PedidoParaAviso,
  type Persona,
  validarEntrada,
} from './reglas.ts';

const ana: Persona = { usuarioId: 'u-ana', uid: 'uid-ana', rol: 'alumno', tokens: ['t-ana'] };
const beto: Persona = { usuarioId: 'u-beto', uid: 'uid-beto', rol: 'encargado', tokens: ['t-beto'] };
const luis: Persona = { usuarioId: 'u-luis', uid: 'uid-luis', rol: 'empleado', tokens: [] };

const pedido = (cambios: Partial<PedidoParaAviso> = {}): PedidoParaAviso => ({
  id: 'p1',
  folio: 7,
  estado: 'pago_en_revision',
  motivoRechazoPago: null,
  pagadoEn: null,
  alumno: ana,
  personal: [beto, luis],
  ...cambios,
});

const rechazo = (f: () => unknown, estado: number) =>
  assert.throws(f, (e) => e instanceof AvisoRechazado && e.estado === estado);

test('el folio se formatea igual que en la app', () => {
  assert.equal(formatearFolio(7), 'AGU-00007');
});

test('el comprobante lo avisa su dueño y le llega solo al encargado', () => {
  const a = avisoDePedido('comprobante', 'uid-ana', pedido());
  assert.deepEqual(a.destinatarios.map((x) => x.usuarioId), ['u-beto']);
  assert.match(a.mensaje, /AGU-00007/);
  rechazo(() => avisoDePedido('comprobante', 'uid-beto', pedido()), 403);
  rechazo(() => avisoDePedido('comprobante', 'uid-ana', pedido({ estado: 'por_pagar' })), 409);
});

test('pago validado: solo el encargado y solo si de verdad se pagó', () => {
  const pagado = pedido({ estado: 'pendiente', pagadoEn: '2026-11-12T12:00:00Z' });
  assert.deepEqual(avisoDePedido('pago_validado', 'uid-beto', pagado).destinatarios, [ana]);
  rechazo(() => avisoDePedido('pago_validado', 'uid-luis', pagado), 403);
  rechazo(() => avisoDePedido('pago_validado', 'uid-ana', pagado), 403);
  rechazo(() => avisoDePedido('pago_validado', 'uid-beto', pedido()), 409);
});

test('pago rechazado incluye el motivo', () => {
  const r = pedido({ estado: 'por_pagar', motivoRechazoPago: 'Monto incompleto' });
  const a = avisoDePedido('pago_rechazado', 'uid-beto', r);
  assert.match(a.mensaje, /Monto incompleto/);
  rechazo(() => avisoDePedido('pago_rechazado', 'uid-beto', pedido({ estado: 'por_pagar' })), 409);
});

test('pedido listo: encargado o empleado, solo con el pedido listo', () => {
  const listo = pedido({ estado: 'listo', pagadoEn: 'x' });
  assert.deepEqual(avisoDePedido('pedido_listo', 'uid-luis', listo).destinatarios, [ana]);
  assert.deepEqual(avisoDePedido('pedido_listo', 'uid-beto', listo).destinatarios, [ana]);
  rechazo(() => avisoDePedido('pedido_listo', 'uid-ana', listo), 403);
  rechazo(() => avisoDePedido('pedido_listo', 'uid-luis', pedido({ estado: 'preparando' })), 409);
});

test('la solicitud de trabajo le llega a los encargados de esa cafetería', () => {
  const a = avisoDeSolicitud({ nombre: 'Rosa Medina', personal: [beto, luis] });
  assert.deepEqual(a.destinatarios, [beto]);
  assert.match(a.mensaje, /Rosa Medina/);
});

test('la entrada se valida', () => {
  assert.deepEqual(validarEntrada({ evento: 'solicitud' }), { evento: 'solicitud', pedidoId: null });
  const id = 'c0000000000040008000000000000001';
  assert.deepEqual(validarEntrada({ evento: 'pedido_listo', pedidoId: id }), { evento: 'pedido_listo', pedidoId: id });
  rechazo(() => validarEntrada({ evento: 'borrar_todo' }), 400);
  rechazo(() => validarEntrada({ evento: 'pedido_listo', pedidoId: '1; drop' }), 400);
  rechazo(() => validarEntrada(null), 400);
});
