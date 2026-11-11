// HU-23: al cerrar el día, los pedidos pagados cuya hora de recogida ya pasó y
// que nadie recogió quedan como "no_recogido" y cuentan para el sistema de
// confianza. Los que nunca se pagaron se cancelan.
const CERRAR_DIA = `
  mutation CerrarDia($antesDe: Timestamp!) {
    noRecogidos: pedido_updateMany(
      where: {
        estado: { in: ["pendiente", "preparando", "listo"] }
        recogerA: { lt: $antesDe }
      }
      data: { estado: "no_recogido" }
    )
    sinPagar: pedido_updateMany(
      where: {
        estado: { in: ["por_pagar", "pago_en_revision"] }
        recogerA: { lt: $antesDe }
      }
      data: { estado: "cancelado" }
    )
  }
`;

async function cerrarDia(dataConnect, ahora = new Date()) {
  const res = await dataConnect.executeGraphql(CERRAR_DIA, {
    variables: { antesDe: ahora.toISOString() },
  });
  return { noRecogidos: res.data.noRecogidos, sinPagar: res.data.sinPagar };
}

module.exports = { cerrarDia };
