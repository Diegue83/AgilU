// Edge Function "avisar": envía los avisos de ÁgilU (bandeja y push por FCM)
// sin Cloud Functions de Firebase.
//
// La app la llama después de una acción, con el token de Firebase del usuario:
//   POST /functions/v1/avisar  { "evento": "pedido_listo", "pedidoId": "..." }
// La función:
//   1. Verifica el token de Firebase (firma de Google, proyecto agilu-a232a).
//   2. Lee el pedido (o la solicitud) en SQL Connect con la cuenta de servicio
//      y comprueba con reglas.ts que quien llama puede pedir ese aviso y que
//      el pedido de verdad está en ese estado. Así nadie inventa avisos.
//   3. Guarda el aviso en la bandeja (tabla Notificacion) y lo envía por FCM.
//
// Secretos de la función (Supabase > Edge Functions > Secrets):
//   FIREBASE_SERVICE_ACCOUNT  JSON de una cuenta de servicio del proyecto
//                             (Firebase > Configuración > Cuentas de servicio).

import { createRemoteJWKSet, importPKCS8, jwtVerify, SignJWT } from 'npm:jose@5.9.6';

import {
  Aviso,
  AvisoRechazado,
  avisoDePedido,
  avisoDeSolicitud,
  Persona,
  validarEntrada,
} from './reglas.ts';

const PROYECTO = 'agilu-a232a';
const DATA_CONNECT =
  `https://firebasedataconnect.googleapis.com/v1/projects/${PROYECTO}` +
  '/locations/us-east4/services/agilu-a232a-service:executeGraphql';
const FCM = `https://fcm.googleapis.com/v1/projects/${PROYECTO}/messages:send`;

const llavesFirebase = createRemoteJWKSet(
  new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'),
);

async function uidDelToken(req: Request): Promise<string> {
  const token = (req.headers.get('authorization') ?? '').replace(/^Bearer\s+/i, '');
  if (!token) throw new AvisoRechazado(401, 'Inicia sesión.');
  try {
    const { payload } = await jwtVerify(token, llavesFirebase, {
      issuer: `https://securetoken.google.com/${PROYECTO}`,
      audience: PROYECTO,
    });
    if (typeof payload.sub !== 'string' || !payload.sub) throw new Error();
    return payload.sub;
  } catch {
    throw new AvisoRechazado(401, 'Sesión inválida.');
  }
}

// Token de acceso de Google para la cuenta de servicio (SQL Connect y FCM).
let tokenGoogle: { valor: string; vence: number } | null = null;
async function accesoGoogle(): Promise<string> {
  if (tokenGoogle && tokenGoogle.vence > Date.now() + 60_000) return tokenGoogle.valor;
  const cuenta = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? '{}');
  if (!cuenta.client_email || !cuenta.private_key) {
    throw new AvisoRechazado(500, 'Falta configurar la cuenta de servicio.');
  }
  const llave = await importPKCS8(cuenta.private_key, 'RS256');
  const asercion = await new SignJWT({
    scope: 'https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/firebase.messaging',
  })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(cuenta.client_email)
    .setAudience('https://oauth2.googleapis.com/token')
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(llave);
  const r = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: asercion,
    }),
  });
  const j = await r.json();
  if (!r.ok) throw new AvisoRechazado(502, 'No se pudo autorizar con Google.');
  tokenGoogle = { valor: j.access_token, vence: Date.now() + j.expires_in * 1000 };
  return tokenGoogle.valor;
}

async function graphql(query: string, variables: Record<string, unknown>) {
  const r = await fetch(DATA_CONNECT, {
    method: 'POST',
    headers: { Authorization: `Bearer ${await accesoGoogle()}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });
  const j = await r.json();
  if (!r.ok || j.errors?.length) {
    console.error('SQL Connect', JSON.stringify(j.errors ?? j).slice(0, 500));
    throw new AvisoRechazado(502, 'No se pudo consultar la base.');
  }
  return j.data;
}

const PERSONA = `
  id
  rol { nombre }
  autenticacion_on_usuario { firebaseAuthUid }
  dispositivoTokens_on_usuario { token }
`;

// deno-lint-ignore no-explicit-any
const persona = (u: any): Persona => ({
  usuarioId: u.id,
  uid: u.autenticacion_on_usuario?.firebaseAuthUid ?? null,
  rol: u.rol?.nombre ?? null,
  // deno-lint-ignore no-explicit-any
  tokens: (u.dispositivoTokens_on_usuario ?? []).map((t: any) => t.token),
});

async function avisoParaPedido(evento: Parameters<typeof avisoDePedido>[0], uid: string, pedidoId: string) {
  const d = await graphql(
    `query P($id: UUID!) {
      pedido(id: $id) {
        id folio estado motivoRechazoPago pagadoEn
        usuario { ${PERSONA} }
        cafeteria { usuarios_on_cafeteria { ${PERSONA} } }
      }
    }`,
    { id: pedidoId },
  );
  const p = d.pedido;
  if (!p) throw new AvisoRechazado(404, 'El pedido no existe.');
  const aviso = avisoDePedido(evento, uid, {
    id: p.id,
    folio: p.folio,
    estado: p.estado,
    motivoRechazoPago: p.motivoRechazoPago,
    pagadoEn: p.pagadoEn,
    alumno: persona(p.usuario),
    personal: p.cafeteria.usuarios_on_cafeteria.map(persona),
  });
  // No repetir el mismo aviso del mismo pedido a la misma persona.
  const ya = await graphql(
    `query Y($pedido: UUID!, $titulo: String!) {
      notificacions(where: { pedido: { id: { eq: $pedido } }, titulo: { eq: $titulo } }) { usuario { id } }
    }`,
    { pedido: pedidoId, titulo: aviso.titulo },
  );
  // deno-lint-ignore no-explicit-any
  const avisados = new Set(ya.notificacions.map((n: any) => n.usuario.id));
  aviso.destinatarios = aviso.destinatarios.filter((x) => !avisados.has(x.usuarioId));
  return aviso;
}

async function avisoParaSolicitud(uid: string): Promise<Aviso> {
  const d = await graphql(
    `query S($uid: String!) {
      autenticacion(key: { firebaseAuthUid: $uid }) {
        usuario {
          nombre
          solicitudEmpleo_on_usuario { cafeteria { usuarios_on_cafeteria { ${PERSONA} } } }
        }
      }
    }`,
    { uid },
  );
  const s = d.autenticacion?.usuario?.solicitudEmpleo_on_usuario;
  if (!s) throw new AvisoRechazado(409, 'No tienes una solicitud pendiente.');
  return avisoDeSolicitud({
    nombre: d.autenticacion.usuario.nombre,
    personal: s.cafeteria.usuarios_on_cafeteria.map(persona),
  });
}

async function guardarEnBandeja(aviso: Aviso, pedidoId: string | null) {
  if (aviso.destinatarios.length === 0) return;
  await graphql(
    `mutation N($data: [Notificacion_Data!]!) { notificacion_insertMany(data: $data) }`,
    {
      data: aviso.destinatarios.map((x) => ({
        titulo: aviso.titulo,
        mensaje: aviso.mensaje,
        usuarioId: x.usuarioId,
        ...(pedidoId ? { pedidoId } : {}),
      })),
    },
  );
}

async function enviarPush(aviso: Aviso, datos: Record<string, string>): Promise<number> {
  let enviados = 0;
  for (const token of aviso.destinatarios.flatMap((x) => x.tokens)) {
    const r = await fetch(FCM, {
      method: 'POST',
      headers: { Authorization: `Bearer ${await accesoGoogle()}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: { token, notification: { title: aviso.titulo, body: aviso.mensaje }, data: datos },
      }),
    });
    if (r.ok) {
      enviados++;
    } else if (r.status === 404 || r.status === 400) {
      // Token vencido o inválido: se olvida para no volver a intentarlo.
      await graphql(`mutation D($t: String!) { dispositivoToken_delete(key: { token: $t }) }`, { t: token })
        .catch(() => {});
    }
  }
  return enviados;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') return new Response('Método no permitido', { status: 405 });
  try {
    const uid = await uidDelToken(req);
    const { evento, pedidoId } = validarEntrada(await req.json().catch(() => null));
    const aviso = pedidoId
      ? await avisoParaPedido(evento, uid, pedidoId)
      : await avisoParaSolicitud(uid);
    await guardarEnBandeja(aviso, pedidoId);
    const enviados = await enviarPush(aviso, { evento, ...(pedidoId ? { pedidoId } : {}) });
    return Response.json({ destinatarios: aviso.destinatarios.length, enviados });
  } catch (e) {
    const estado = e instanceof AvisoRechazado ? e.estado : 500;
    const mensaje = e instanceof AvisoRechazado ? e.message : 'Error interno.';
    if (!(e instanceof AvisoRechazado)) console.error(e);
    return Response.json({ error: mensaje }, { status: estado });
  }
});
