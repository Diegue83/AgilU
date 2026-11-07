const { randomUUID } = require('node:crypto');

const { validarImagen, ErrorDeFoto } = require('./fotos');

const UUID = /^[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}$/i;

// Solo el alumno dueño del pedido puede subir su comprobante, y solo mientras
// el pedido está por pagar.
const PEDIDO_DEL_ALUMNO = `
  query PedidoDelAlumno($id: UUID!, $uid: String!) {
    pedidos(
      where: {
        id: { eq: $id }
        usuario: { autenticacion_on_usuario: { firebaseAuthUid: { eq: $uid } } }
      }
      limit: 1
    ) {
      estado
      cafeteria {
        id
      }
    }
  }
`;

const MARCAR_EN_REVISION = `
  mutation MarcarEnRevision($id: UUID!, $url: String!) {
    pedido_update(id: $id, data: {
      estado: "pago_en_revision", comprobanteUrl: $url, motivoRechazoPago: null
    })
  }
`;

/**
 * HU-08: guarda el comprobante de transferencia y deja el pedido en revisión
 * para que el encargado lo valide.
 */
async function subirComprobante({ uid, pedidoId, imagenBase64, tipo }, { dataConnect, bucket }) {
  if (!uid) throw new ErrorDeFoto('unauthenticated', 'Inicia sesión.');
  if (typeof pedidoId !== 'string' || !UUID.test(pedidoId)) {
    throw new ErrorDeFoto('invalid-argument', 'Pedido inválido.');
  }
  const { datos, ext } = validarImagen(imagenBase64, tipo);

  const res = await dataConnect.executeGraphql(PEDIDO_DEL_ALUMNO, {
    variables: { id: pedidoId, uid },
  });
  const pedido = res.data.pedidos[0];
  if (!pedido) throw new ErrorDeFoto('permission-denied', 'El pedido no es tuyo.');
  if (pedido.estado !== 'por_pagar') {
    throw new ErrorDeFoto('failed-precondition', 'Este pedido ya no espera comprobante.');
  }

  const ruta = `comprobantes/${pedido.cafeteria.id}/${pedidoId}.${ext}`;
  const token = randomUUID();
  await bucket.file(ruta).save(datos, {
    resumable: false,
    contentType: tipo,
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  const url = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/` +
    `${encodeURIComponent(ruta)}?alt=media&token=${token}`;

  await dataConnect.executeGraphql(MARCAR_EN_REVISION, { variables: { id: pedidoId, url } });
  return { estado: 'pago_en_revision' };
}

module.exports = { subirComprobante };
