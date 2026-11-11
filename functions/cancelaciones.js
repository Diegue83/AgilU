// Mutación de administrador que no está en el conector: ninguna función
// escucha "pedido_updateMany", así que no puede dispararse a sí misma.
const CANCELAR_PEDIDOS_CON_PRODUCTO = `
  mutation CancelarPedidosConProducto($productoId: UUID!) {
    pedido_updateMany(
      where: {
        estado: { in: ["por_pagar", "pago_en_revision", "pendiente"] }
        detallePedidos_on_pedido: { exist: { productoId: { eq: $productoId } } }
      }
      data: { estado: "cancelado" }
    )
  }
`;

/**
 * HU-16: si un producto quedó agotado, cancela los pedidos que todavía no se
 * empiezan a preparar. Los que se preparan o se entregaron no se tocan.
 * Devuelve cuántos pedidos se cancelaron.
 */
async function cancelarSiQuedoAgotado(event, dataConnect) {
  const { variables, errors } = event.data.payload;
  if (errors && errors.length) return 0;
  if (!variables || variables.disponible !== false) return 0;

  const res = await dataConnect.executeGraphql(CANCELAR_PEDIDOS_CON_PRODUCTO, {
    variables: { productoId: variables.id },
  });
  return res.data.pedido_updateMany;
}

module.exports = { cancelarSiQuedoAgotado };
