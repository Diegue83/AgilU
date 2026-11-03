const { onMutationExecuted } = require('firebase-functions/dataconnect');
const { onCall, HttpsError } = require('firebase-functions/https');
const { logger } = require('firebase-functions');
const { initializeApp } = require('firebase-admin/app');
const { getDataConnect } = require('firebase-admin/data-connect');
const { getStorage } = require('firebase-admin/storage');

const { cancelarSiQuedoAgotado } = require('./cancelaciones');
const { subirFoto, ErrorDeFoto } = require('./fotos');

initializeApp();

const SERVICIO = {
  serviceId: 'agilu-a232a-service',
  location: 'us-east4',
};

// Debe coincidir con la ubicación del servicio en dataconnect/dataconnect.yaml.
const DISPARADOR = {
  service: SERVICIO.serviceId,
  connector: 'agilu',
  region: SERVICIO.location,
};

async function alAgotarse(event) {
  const cancelados = await cancelarSiQuedoAgotado(event, getDataConnect(SERVICIO));
  if (cancelados > 0) {
    logger.info('Pedidos cancelados por producto agotado', {
      productoId: event.data.payload.variables.id,
      cancelados,
    });
  }
}

exports.cancelarAlAgotar = onMutationExecuted(
  { ...DISPARADOR, operation: 'EstablecerDisponibilidad' },
  alAgotarse,
);

exports.cancelarAlEditarAgotado = onMutationExecuted(
  { ...DISPARADOR, operation: 'EditarMiProducto' },
  alAgotarse,
);

// HU-20: la app envía la foto ya reducida; aquí se valida tipo, tamaño y que
// el producto sea de la cafetería del encargado antes de guardarla.
exports.subirFotoProducto = onCall(
  { region: SERVICIO.location, maxInstances: 5 },
  async (req) => {
    try {
      return await subirFoto(
        {
          uid: req.auth?.uid,
          productoId: req.data?.productoId,
          imagenBase64: req.data?.imagenBase64,
          tipo: req.data?.tipo,
        },
        { dataConnect: getDataConnect(SERVICIO), bucket: getStorage().bucket() },
      );
    } catch (e) {
      if (e instanceof ErrorDeFoto) throw new HttpsError(e.codigo, e.message);
      logger.error('No se pudo guardar la foto', { error: e.message });
      throw new HttpsError('internal', 'No se pudo guardar la foto.');
    }
  },
);
