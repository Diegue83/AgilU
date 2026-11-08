// HU-05: cuando el encargado marca un pedido como listo, se avisa al alumno
// en todos sus dispositivos y se guarda el aviso en Notificacion.
const DESTINO = `
  query DestinoAviso($id: UUID!) {
    pedido(id: $id) {
      folio
      estado
      cafeteria {
        nombre
      }
      usuario {
        id
        dispositivoTokens_on_usuario {
          token
        }
      }
    }
  }
`;

const GUARDAR = `
  mutation GuardarAviso($usuario: UUID!, $pedido: UUID!, $titulo: String!, $mensaje: String!) {
    notificacion_insert(data: {
      usuarioId: $usuario, pedidoId: $pedido, titulo: $titulo, mensaje: $mensaje
    })
  }
`;

const BORRAR_TOKENS = `
  mutation BorrarTokens($tokens: [String!]!) {
    dispositivoToken_deleteMany(where: { token: { in: $tokens } })
  }
`;

const TOKEN_INVALIDO = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/**
 * Devuelve cuántos dispositivos recibieron el aviso. Los tokens que FCM
 * reporta como inválidos se borran para no volver a usarlos.
 */
async function avisarPedidoListo(event, { dataConnect, messaging }) {
  const { variables, data, errors } = event.data.payload;
  if (errors && errors.length) return 0;
  if (!variables || variables.estado !== 'listo') return 0;
  if (!data || !data._execute) return 0;

  const res = await dataConnect.executeGraphql(DESTINO, { variables: { id: variables.id } });
  const pedido = res.data.pedido;
  if (!pedido || pedido.estado !== 'listo') return 0;

  const folio = `AGU-${String(pedido.folio).padStart(5, '0')}`;
  const titulo = 'Tu pedido está listo';
  const mensaje = `Pasa por ${folio} a ${pedido.cafeteria.nombre}. Ten a la mano tu código de entrega.`;
  await dataConnect.executeGraphql(GUARDAR, {
    variables: { usuario: pedido.usuario.id, pedido: variables.id, titulo, mensaje },
  });

  const tokens = pedido.usuario.dispositivoTokens_on_usuario.map((d) => d.token);
  if (tokens.length === 0) return 0;
  const envio = await messaging.sendEachForMulticast({
    tokens,
    notification: { title: titulo, body: mensaje },
    data: { pedidoId: variables.id, tipo: 'pedido_listo' },
    android: { priority: 'high' },
  });

  const invalidos = envio.responses
    .map((r, i) => (!r.success && TOKEN_INVALIDO.has(r.error?.code) ? tokens[i] : null))
    .filter(Boolean);
  if (invalidos.length) {
    await dataConnect.executeGraphql(BORRAR_TOKENS, { variables: { tokens: invalidos } });
  }
  return envio.successCount;
}

module.exports = { avisarPedidoListo };
