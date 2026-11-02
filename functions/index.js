const { onMutationExecuted } = require('firebase-functions/dataconnect');
const { logger } = require('firebase-functions');
const { initializeApp } = require('firebase-admin/app');
const { getDataConnect } = require('firebase-admin/data-connect');

const { cancelarSiQuedoAgotado } = require('./cancelaciones');

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
