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

part 'listar_menu.dart';

part 'mi_perfil.dart';

part 'mi_pedido.dart';

part 'mis_pedidos.dart';







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
