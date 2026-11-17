// Reglas de los avisos de ÁgilU: quién puede pedir cada aviso, en qué estado
// debe estar el pedido y a quién le llega. Sin dependencias para poder
// probarlas fuera de Supabase (node --test).

export type Evento =
  | 'comprobante'
  | 'pago_validado'
  | 'pago_rechazado'
  | 'pedido_listo'
  | 'solicitud';

export const EVENTOS: Evento[] = [
  'comprobante',
  'pago_validado',
  'pago_rechazado',
  'pedido_listo',
  'solicitud',
];

export interface Persona {
  usuarioId: string;
  uid: string | null;
  rol: string | null;
  tokens: string[];
}

export interface PedidoParaAviso {
  id: string;
  folio: number;
  estado: string;
  motivoRechazoPago: string | null;
  pagadoEn: string | null;
  alumno: Persona;
  personal: Persona[]; // usuarios de la cafetería del pedido
}

export interface SolicitudParaAviso {
  nombre: string;
  personal: Persona[]; // usuarios de la cafetería solicitada
}

export interface Aviso {
  titulo: string;
  mensaje: string;
  destinatarios: Persona[];
}

export class AvisoRechazado extends Error {
  estado: number;
  constructor(estado: number, mensaje: string) {
    super(mensaje);
    this.estado = estado;
  }
}

export const formatearFolio = (n: number) => `AGU-${String(n).padStart(5, '0')}`;

const esPersonalDe = (uid: string, p: PedidoParaAviso, roles: string[]) =>
  p.personal.some((x) => x.uid === uid && x.rol !== null && roles.includes(x.rol));

const encargados = (personas: Persona[]) => personas.filter((x) => x.rol === 'encargado');

/** Decide el aviso de un pedido, o lanza AvisoRechazado. */
export function avisoDePedido(evento: Evento, uid: string, p: PedidoParaAviso): Aviso {
  const folio = formatearFolio(p.folio);
  switch (evento) {
    case 'comprobante':
      if (p.alumno.uid !== uid) throw new AvisoRechazado(403, 'El pedido no es tuyo.');
      if (p.estado !== 'pago_en_revision') throw new AvisoRechazado(409, 'El pedido no espera validación.');
      return {
        titulo: 'Nuevo comprobante',
        mensaje: `El pedido ${folio} espera que valides el pago.`,
        destinatarios: encargados(p.personal),
      };
    case 'pago_validado':
      if (!esPersonalDe(uid, p, ['encargado'])) throw new AvisoRechazado(403, 'No eres encargado de esta cafetería.');
      if (!p.pagadoEn || !['pendiente', 'preparando', 'listo'].includes(p.estado)) {
        throw new AvisoRechazado(409, 'El pago de este pedido no está validado.');
      }
      return {
        titulo: 'Pago validado',
        mensaje: `Tu pago del pedido ${folio} fue aprobado; ya entró a cocina.`,
        destinatarios: [p.alumno],
      };
    case 'pago_rechazado':
      if (!esPersonalDe(uid, p, ['encargado'])) throw new AvisoRechazado(403, 'No eres encargado de esta cafetería.');
      if (p.estado !== 'por_pagar' || !p.motivoRechazoPago) {
        throw new AvisoRechazado(409, 'El pago de este pedido no fue rechazado.');
      }
      return {
        titulo: 'Comprobante rechazado',
        mensaje: `Revisa tu pedido ${folio}: ${p.motivoRechazoPago}`,
        destinatarios: [p.alumno],
      };
    case 'pedido_listo':
      if (!esPersonalDe(uid, p, ['encargado', 'empleado'])) {
        throw new AvisoRechazado(403, 'No atiendes esta cafetería.');
      }
      if (p.estado !== 'listo') throw new AvisoRechazado(409, 'El pedido no está listo.');
      return {
        titulo: 'Tu pedido está listo',
        mensaje: `Pasa a recoger tu pedido ${folio}.`,
        destinatarios: [p.alumno],
      };
    default:
      throw new AvisoRechazado(400, 'Evento desconocido.');
  }
}

/** Aviso al encargado de una solicitud de trabajo nueva. */
export function avisoDeSolicitud(s: SolicitudParaAviso): Aviso {
  return {
    titulo: 'Nueva solicitud de trabajo',
    mensaje: `${s.nombre} pidió entrar como empleado. Revísala en Personal.`,
    destinatarios: encargados(s.personal),
  };
}

/** Entrada de la función: evento conocido y pedido cuando hace falta. */
export function validarEntrada(cuerpo: unknown): { evento: Evento; pedidoId: string | null } {
  const c = (cuerpo ?? {}) as Record<string, unknown>;
  const evento = c.evento as Evento;
  if (!EVENTOS.includes(evento)) throw new AvisoRechazado(400, 'Evento desconocido.');
  if (evento === 'solicitud') return { evento, pedidoId: null };
  const pedidoId = c.pedidoId;
  if (typeof pedidoId !== 'string' || !/^[0-9a-f-]{32,36}$/i.test(pedidoId)) {
    throw new AvisoRechazado(400, 'Pedido inválido.');
  }
  return { evento, pedidoId };
}
