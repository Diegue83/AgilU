library agilu_connector;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'crear_perfil.dart';

part 'crear_pedido.dart';

part 'crear_cafeteria.dart';

part 'crear_puesto.dart';

part 'asignar_rol.dart';

part 'crear_producto.dart';

part 'crear_estacion.dart';

part 'editar_estacion.dart';

part 'eliminar_estacion.dart';

part 'crear_mi_producto.dart';

part 'editar_mi_producto.dart';

part 'establecer_disponibilidad.dart';

part 'eliminar_mi_producto.dart';

part 'publicar_oferta.dart';

part 'quitar_oferta.dart';

part 'editar_mi_cafeteria.dart';

part 'avanzar_pedido.dart';

part 'listar_menu.dart';

part 'mi_perfil.dart';

part 'mi_pedido.dart';

part 'mis_pedidos.dart';

part 'mis_estaciones.dart';

part 'mis_productos.dart';

part 'listar_cafeterias.dart';

part 'ocupacion_franjas.dart';

part 'diagnosticar_pedido.dart';

part 'mi_cafeteria.dart';

part 'panel_pedidos.dart';







class AgiluConnector {
  
  
  CrearPerfilVariablesBuilder crearPerfil ({required String nombre, }) {
    return CrearPerfilVariablesBuilder(dataConnect, nombre: nombre,);
  }
  
  
  CrearPedidoVariablesBuilder crearPedido ({required String id, required String cafeteriaId, required Timestamp recogerA, required dynamic items, }) {
    return CrearPedidoVariablesBuilder(dataConnect, id: id,cafeteriaId: cafeteriaId,recogerA: recogerA,items: items,);
  }
  
  
  CrearCafeteriaVariablesBuilder crearCafeteria ({required String nombre, }) {
    return CrearCafeteriaVariablesBuilder(dataConnect, nombre: nombre,);
  }
  
  
  CrearPuestoVariablesBuilder crearPuesto ({required String nombre, required String cafeteriaId, }) {
    return CrearPuestoVariablesBuilder(dataConnect, nombre: nombre,cafeteriaId: cafeteriaId,);
  }
  
  
  AsignarRolVariablesBuilder asignarRol ({required String correo, required String rol, }) {
    return AsignarRolVariablesBuilder(dataConnect, correo: correo,rol: rol,);
  }
  
  
  CrearProductoVariablesBuilder crearProducto ({required String nombre, required double precio, required int cantidadEnStock, required String categoria, required String puestoId, }) {
    return CrearProductoVariablesBuilder(dataConnect, nombre: nombre,precio: precio,cantidadEnStock: cantidadEnStock,categoria: categoria,puestoId: puestoId,);
  }
  
  
  CrearEstacionVariablesBuilder crearEstacion ({required String nombre, required int orden, }) {
    return CrearEstacionVariablesBuilder(dataConnect, nombre: nombre,orden: orden,);
  }
  
  
  EditarEstacionVariablesBuilder editarEstacion ({required String id, required String nombre, required int orden, required bool activo, }) {
    return EditarEstacionVariablesBuilder(dataConnect, id: id,nombre: nombre,orden: orden,activo: activo,);
  }
  
  
  EliminarEstacionVariablesBuilder eliminarEstacion ({required String id, }) {
    return EliminarEstacionVariablesBuilder(dataConnect, id: id,);
  }
  
  
  CrearMiProductoVariablesBuilder crearMiProducto ({required String nombre, required double precio, required String puestoId, required bool disponible, }) {
    return CrearMiProductoVariablesBuilder(dataConnect, nombre: nombre,precio: precio,puestoId: puestoId,disponible: disponible,);
  }
  
  
  EditarMiProductoVariablesBuilder editarMiProducto ({required String id, required String nombre, required double precio, required String puestoId, required bool disponible, }) {
    return EditarMiProductoVariablesBuilder(dataConnect, id: id,nombre: nombre,precio: precio,puestoId: puestoId,disponible: disponible,);
  }
  
  
  EstablecerDisponibilidadVariablesBuilder establecerDisponibilidad ({required String id, required bool disponible, }) {
    return EstablecerDisponibilidadVariablesBuilder(dataConnect, id: id,disponible: disponible,);
  }
  
  
  EliminarMiProductoVariablesBuilder eliminarMiProducto ({required String id, }) {
    return EliminarMiProductoVariablesBuilder(dataConnect, id: id,);
  }
  
  
  PublicarOfertaVariablesBuilder publicarOferta ({required String id, required double precioOferta, required Timestamp hasta, required bool esEspecialidad, }) {
    return PublicarOfertaVariablesBuilder(dataConnect, id: id,precioOferta: precioOferta,hasta: hasta,esEspecialidad: esEspecialidad,);
  }
  
  
  QuitarOfertaVariablesBuilder quitarOferta ({required String id, }) {
    return QuitarOfertaVariablesBuilder(dataConnect, id: id,);
  }
  
  
  EditarMiCafeteriaVariablesBuilder editarMiCafeteria ({required int aperturaMinutos, required int cierreMinutos, required int anticipacionMinutos, required int intervaloMinutos, required int capacidadPorFranja, required bool permitirInmediatos, }) {
    return EditarMiCafeteriaVariablesBuilder(dataConnect, aperturaMinutos: aperturaMinutos,cierreMinutos: cierreMinutos,anticipacionMinutos: anticipacionMinutos,intervaloMinutos: intervaloMinutos,capacidadPorFranja: capacidadPorFranja,permitirInmediatos: permitirInmediatos,);
  }
  
  
  AvanzarPedidoVariablesBuilder avanzarPedido ({required String id, required String estado, }) {
    return AvanzarPedidoVariablesBuilder(dataConnect, id: id,estado: estado,);
  }
  
  
  ListarMenuVariablesBuilder listarMenu () {
    return ListarMenuVariablesBuilder(dataConnect, );
  }
  
  
  MiPerfilVariablesBuilder miPerfil () {
    return MiPerfilVariablesBuilder(dataConnect, );
  }
  
  
  MiPedidoVariablesBuilder miPedido ({required String id, }) {
    return MiPedidoVariablesBuilder(dataConnect, id: id,);
  }
  
  
  MisPedidosVariablesBuilder misPedidos () {
    return MisPedidosVariablesBuilder(dataConnect, );
  }
  
  
  MisEstacionesVariablesBuilder misEstaciones () {
    return MisEstacionesVariablesBuilder(dataConnect, );
  }
  
  
  MisProductosVariablesBuilder misProductos () {
    return MisProductosVariablesBuilder(dataConnect, );
  }
  
  
  ListarCafeteriasVariablesBuilder listarCafeterias () {
    return ListarCafeteriasVariablesBuilder(dataConnect, );
  }
  
  
  OcupacionFranjasVariablesBuilder ocupacionFranjas ({required String cafeteriaId, }) {
    return OcupacionFranjasVariablesBuilder(dataConnect, cafeteriaId: cafeteriaId,);
  }
  
  
  DiagnosticarPedidoVariablesBuilder diagnosticarPedido ({required String cafeteriaId, required Timestamp recogerA, required dynamic items, }) {
    return DiagnosticarPedidoVariablesBuilder(dataConnect, cafeteriaId: cafeteriaId,recogerA: recogerA,items: items,);
  }
  
  
  MiCafeteriaVariablesBuilder miCafeteria () {
    return MiCafeteriaVariablesBuilder(dataConnect, );
  }
  
  
  PanelPedidosVariablesBuilder panelPedidos ({required Timestamp desde, required Timestamp hasta, }) {
    return PanelPedidosVariablesBuilder(dataConnect, desde: desde,hasta: hasta,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'agilu',
    'agilu-a232a-service',
  );

  AgiluConnector({required this.dataConnect});
  static AgiluConnector get instance {
    
    return AgiluConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
