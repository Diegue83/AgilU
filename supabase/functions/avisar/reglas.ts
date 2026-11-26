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
  /** Permisos del rol (RolPermiso): deciden quién avisa y a quién le llega. */
  permisos: string[];
  /** Estación asignada; quien cobra con estación solo cobra la suya. */
  puestoId?: string | null;
  /** Preferencias de push (la bandeja guarda el aviso de todos modos). */
  avisos?: { pedidoListo: boolean; pagos: boolean; personal: boolean };
  tokens: string[];
}

export interface PedidoParaAviso {
  id: string;
  folio: number;
  estado: string;
  motivoRechazoPago: string | null;
  pagadoEn: string | null;
  /** Estación que cobra el pedido (null en pedidos anteriores). */
  puestoId?: string | null;
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

const esPersonalDe = (uid: string, p: PedidoParaAviso, permiso: string) =>
  p.personal.some((x) => x.uid === uid && x.permisos.includes(permiso) && atiende(x, p));

/** Sin estación atiende toda la cafetería; con estación, solo los pedidos de ella. */
const atiende = (x: Persona, p: PedidoParaAviso) =>
  !x.puestoId || !p.puestoId || x.puestoId === p.puestoId;

const conPermiso = (personas: Persona[], permiso: string) =>
  personas.filter((x) => x.permisos.includes(permiso));

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
        destinatarios: conPermiso(p.personal, 'pagos.validar').filter((x) => atiende(x, p)),
      };
    case 'pago_validado':
      if (!esPersonalDe(uid, p, 'pagos.validar')) throw new AvisoRechazado(403, 'No validas pagos en esta cafetería.');
      if (!p.pagadoEn || !['pendiente', 'preparando', 'listo'].includes(p.estado)) {
        throw new AvisoRechazado(409, 'El pago de este pedido no está validado.');
      }
      return {
        titulo: 'Pago validado',
        mensaje: `Tu pago del pedido ${folio} fue aprobado; ya entró a cocina.`,
        destinatarios: [p.alumno],
      };
    case 'pago_rechazado':
      if (!esPersonalDe(uid, p, 'pagos.validar')) throw new AvisoRechazado(403, 'No validas pagos en esta cafetería.');
      if (p.estado !== 'por_pagar' || !p.motivoRechazoPago) {
        throw new AvisoRechazado(409, 'El pago de este pedido no fue rechazado.');
      }
      return {
        titulo: 'Comprobante rechazado',
        mensaje: `Revisa tu pedido ${folio}: ${p.motivoRechazoPago}`,
        destinatarios: [p.alumno],
      };
    case 'pedido_listo':
      if (!esPersonalDe(uid, p, 'pedidos.atender')) {
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
    destinatarios: conPermiso(s.personal, 'personal.gestionar'),
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

/** Si la persona quiere recibir por push este evento. */
export function quierePush(x: Persona, evento: Evento): boolean {
  const a = x.avisos;
  if (!a) return true;
  switch (evento) {
    case 'pedido_listo':
      return a.pedidoListo;
    case 'pago_validado':
    case 'pago_rechazado':
      return a.pagos;
    case 'comprobante':
    case 'solicitud':
      return a.personal;
    default:
      return true;
  }
}
