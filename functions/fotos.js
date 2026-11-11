const { randomUUID } = require('node:crypto');

const TAMANO_MAXIMO = 1024 * 1024; // 1 MB después de que la app reduce la foto
const TIPOS = {
  'image/jpeg': { ext: 'jpg', firma: [0xff, 0xd8, 0xff] },
  'image/png': { ext: 'png', firma: [0x89, 0x50, 0x4e, 0x47] },
};
const UUID = /^[0-9a-f]{8}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{4}-?[0-9a-f]{12}$/i;

// El producto debe pertenecer a la cafetería del encargado que hace la
// llamada. Se consulta como administrador filtrando por su uid.
const PRODUCTO_DEL_ENCARGADO = `
  query ProductoDelEncargado($id: UUID!, $uid: String!) {
    producto(id: $id) {
      eliminado
      puesto {
        cafeteria {
          id
          usuarios_on_cafeteria(
            where: {
              rol: { nombre: { eq: "encargado" } }
              autenticacion_on_usuario: { firebaseAuthUid: { eq: $uid } }
            }
          ) {
            id
          }
        }
      }
    }
  }
`;

const GUARDAR_URL = `
  mutation GuardarFotoProducto($id: UUID!, $url: String!) {
    producto_update(id: $id, data: { urlDeImagen: $url })
  }
`;

class ErrorDeFoto extends Error {
  constructor(codigo, mensaje) {
    super(mensaje);
    this.codigo = codigo;
  }
}

function validarImagen(base64, tipo) {
  const formato = TIPOS[tipo];
  if (!formato) {
    throw new ErrorDeFoto('invalid-argument', 'La foto debe ser JPG o PNG.');
  }
  if (typeof base64 !== 'string' || base64.length === 0) {
    throw new ErrorDeFoto('invalid-argument', 'No se recibió la foto.');
  }
  const datos = Buffer.from(base64, 'base64');
  if (datos.length === 0 || datos.length > TAMANO_MAXIMO) {
    throw new ErrorDeFoto('invalid-argument', 'La foto pesa más de 1 MB.');
  }
  if (!formato.firma.every((b, i) => datos[i] === b)) {
    throw new ErrorDeFoto('invalid-argument', 'El archivo no es una imagen válida.');
  }
  return { datos, ext: formato.ext };
}

/**
 * HU-20: guarda la foto de un producto. Solo el encargado de la cafetería del
 * producto puede hacerlo. Devuelve la URL pública con token de descarga.
 */
async function subirFoto({ uid, productoId, imagenBase64, tipo }, { dataConnect, bucket }) {
  if (!uid) throw new ErrorDeFoto('unauthenticated', 'Inicia sesión.');
  if (typeof productoId !== 'string' || !UUID.test(productoId)) {
    throw new ErrorDeFoto('invalid-argument', 'Producto inválido.');
  }
  const { datos, ext } = validarImagen(imagenBase64, tipo);

  const res = await dataConnect.executeGraphql(PRODUCTO_DEL_ENCARGADO, {
    variables: { id: productoId, uid },
  });
  const producto = res.data.producto;
  if (!producto || producto.eliminado ||
      producto.puesto.cafeteria.usuarios_on_cafeteria.length !== 1) {
    throw new ErrorDeFoto('permission-denied', 'El producto no es de tu cafetería.');
  }

  const ruta = `productos/${producto.puesto.cafeteria.id}/${productoId}.${ext}`;
  const token = randomUUID();
  await bucket.file(ruta).save(datos, {
    resumable: false,
    contentType: tipo,
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  const url = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/` +
    `${encodeURIComponent(ruta)}?alt=media&token=${token}`;

  await dataConnect.executeGraphql(GUARDAR_URL, { variables: { id: productoId, url } });
  return { url };
}

module.exports = { subirFoto, validarImagen, ErrorDeFoto, TAMANO_MAXIMO };
