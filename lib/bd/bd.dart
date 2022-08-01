import 'dart:convert';
import 'dart:io';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_application/bd/ordenTrabajo.dart';
import 'package:flutter_application/bd/pointsbygrid.dart';
import 'package:flutter_application/bd/tracking.dart';
import 'package:flutter_application/bd/users.dart';
import 'package:flutter_application/pages/home/home.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import "package:latlong2/latlong.dart";
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class BD{

  static Future<Database> _openBD() async {
    return openDatabase(p.join(await getDatabasesPath(), 'app.db'),
      onCreate: (db, version){
        db.execute(" CREATE TABLE users (id INTEGER, username TEXT, fullname TEXT, password TEXT); ");
        db.execute(" CREATE TABLE workordersbyuser (id INTEGER, code TEXT, scheduled_at TEXT, priority TEXT,  asset_id INTEGER,  asset_type TEXT, description_ofIssue TEXT, scope_of_work TEXT, location_x TEXT, location_y TEXT, notes TEXT, assigned_to_id INTEGER, fullname TEXT, completion_id INTEGER, completion_action INTEGER, b_send INTEGER, c_comentario TEXT);");
        //db.execute(" CREATE TABLE pl_linea (n_idpl_linea INTEGER PRIMARY KEY, c_codigo TEXT, c_tipolinea TEXT, n_latitud_ini REAL, n_longitud_ini REAL,	n_latitud_fin REAL,	n_longitud_fin REAL, c_descripcion TEXT); ");
        db.execute(" CREATE TABLE pl_estructura(n_id_puntos INTEGER PRIMARY KEY, c_tipo_punto TEXT, c_codigo TEXT, n_latitud REAL, n_longitud REAL, idtopology INTEGER, toponametopology TEXT );");
        db.execute(" CREATE TABLE tracking(n_id INTEGER PRIMARY KEY, latitud REAL, longitud REAL, altitud REAL, precision REAL, id INTEGER, username TEXT, fullname TEXT, fecha TEXT, estado INTEGER);");
        db.execute(" CREATE TABLE doc_archivo(n_id_archivo INTEGER PRIMARY KEY, id_workordersbyuser INTEGER, c_checksum TEXT, c_ruta TEXT, c_fecha TEXT);");
      }, version: 1);
  }

  static Future insert(context, Users users, PointsByGridList point) async {
    Database database = await _openBD();
    try {
      database.delete("users");
      //database.delete("pl_linea");
      database.delete("pl_estructura");
    } catch (e) {
      print("Error al eliminar users");
    }
    for (var i = 0; i < users.username.length; i++) {         
      database.rawInsert(
        "insert into users (id, username, fullname, password)"
        "values (${users.id[i]},'${users.username[i]}', '${users.fullname[i]}', '${users.password[i]}' )"
      );
    }
    
    /*database.rawInsert(
        "INSERT INTO pl_linea(n_idpl_linea, c_codigo, c_tipolinea, n_latitud_ini, n_longitud_ini, n_latitud_fin, n_longitud_fin, c_descripcion)"
        "VALUES	(1,'RS_La Shilla Sector I','Red Secundaria',-7.13344916974434,-78.5174361921485,-7.13351933841339,-78.5178799848181,'Red Secundaria')	" 
    );*/

    for (var i = 0; i < point.id.length; i++) {         
      database.rawInsert(
        "INSERT INTO pl_estructura(n_id_puntos, c_tipo_punto, n_latitud, n_longitud, c_codigo, idtopology, toponametopology)"
        "VALUES	(${point.id[i]}, '${point.objtype[i]}', ${point.nlatitud[i]}, ${point.nlongitud[i]},'${point.objcode[i]}', ${point.idtopology[i]}, '${point.nametopology[i]}')	"
      );
    }
    
    
    Navigator.pushReplacementNamed(context, Routes.LOGIN);

  }

  static Future delete(Users users) async {
    Database database = await _openBD();
    return database.delete("users", where: "id = ?", whereArgs: [users.id]);
  }

  static Future<void> update(Users users) async {
    Database database = await _openBD();
    database.update("users", users.toMap(), where: "id = ?", whereArgs: [users.id]);
  }


  static Future<User> users(userLog, passwordLog) async{
    Database database = await _openBD();
    final List<Map<String, dynamic>> usersMap = await database.query("users");
    var bytes = utf8.encode(passwordLog); 
    var digest = md5.convert(bytes).toString();
    int id = 0;
    String username = "";
    String fullname = "";
    String password = "";
    for (var i in usersMap) {  
      print('---'+i['username']);
      print('---'+i['password']);
      print("MD5: $digest"); 
      if( userLog == i['username'] && digest == i['password']){       
        UL.userLog(i['id'], i['username'], i['fullname'], i['password']);
        ULinit.userLoginit(i['id'], i['username'], i['fullname'], i['password']);
        id = i['id'];
        username = i['username'];
        fullname = i['fullname'];
        password = i['password'];

      }
    }
    return User(id: id, username: username, fullname: fullname, password: password);
  }

  static Future InsertOT( OrdenTrabajoList OT, context) async{
    print("Bd: InsertOT");
    Database db = await _openBD();
    var exist = false;
    var exist2 = false;
    final List<Map<String, dynamic>> OTMap = await db.query("workordersbyuser");
      
    for (var i = 0; i < OT.assetId.length; i++) {
      exist = false;
      for (var j in OTMap) {
        if (j['id'] == int.parse(OT.id[i])) {
          db.rawUpdate(
            " update workordersbyuser set "
            "   code = '${OT.code[i]}', scheduled_at = '${OT.scheduledAt[i]}', priority = '${OT.priority[i]}', "
            "   asset_id = '${int.parse(OT.assetId[i])}', asset_type = '${OT.assetType[i]}', description_ofIssue = '${OT.descriptionOfIssue[i]}', "
            "   scope_of_work = '${OT.scopeOfWork[i]}', location_x = '${OT.locationX[i]}', location_y = '${OT.locationY[i]}', notes = '${OT.notes[i]}', "
            "   assigned_to_id = '${int.parse(OT.assignedToId[i])}', fullname = '${OT.fullName[i]}', completion_id = '${int.parse(OT.completionId[i])}' "
            "   where id = '${int.parse(OT.id[i])}' "
          );
          exist = true;
        }       
      }
      if (!exist) {
        db.rawInsert(
          "insert into workordersbyuser (id, code, scheduled_at, priority, asset_id, asset_type, description_ofIssue, scope_of_work, location_x, location_y, notes, assigned_to_id, fullname, completion_id, b_send, c_comentario )"
          "values ('${int.parse(OT.id[i])}', '${OT.code[i]}', '${OT.scheduledAt[i]}', '${OT.priority[i]}','${int.parse(OT.assetId[i])}', '${OT.assetType[i]}', '${OT.descriptionOfIssue[i]}' ,'${OT.scopeOfWork[i]}' , '${OT.locationX[i]}', '${OT.locationY[i]}', '${OT.notes[i]}', '${int.parse(OT.assignedToId[i])}', '${OT.fullName[i]}','${int.parse(OT.completionId[i])}', 0, '')"
        );
        print(OT.code[i]);
      }
    }

    if(OT.assetId.length < OTMap.length){
      for (var j in OTMap) {
        exist2 = false;
        for (var i = 0; i < OT.assetId.length; i++) {
          if (j['id'] == int.parse(OT.id[i])) {
            exist2 = true;
          } 
        }
        if (!exist2) {
          db.delete("workordersbyuser", where: "id = ${j['id']}");
        }
      }
    }
    Navigator.of(context).pop();   
  }

  static Future<int> updateOt(int _id, int _action_id, String comentario) async {
    Database db = await _openBD();
    print(_id);
    print("comentario: " + comentario);
    var resultado = await db.rawUpdate(
      "UPDATE workordersbyuser SET completion_action = $_action_id, c_comentario = '$comentario', b_send = 1 WHERE id = $_id;" 
    );
    print("rows Update: "+resultado.toString());
    return resultado;
  }

  static Future<int> updateOtSend(int _id) async {
    Database db = await _openBD();
    print(_id);
    var resultado = await db.rawUpdate(
      "UPDATE workordersbyuser SET b_send = 2 WHERE id = $_id;" 
    );
    print("rows Update: "+resultado.toString());
    return resultado;
  }

  static Future<List<OrdenTrabajo>> listOTSinPendientes(id) async{
    Database database = await _openBD();
    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
        " SELECT *, count(d.n_id_archivo) FROM workordersbyuser w "
        " left join doc_archivo d on d.id_workordersbyuser = w.id "
        " where w.assigned_to_id = $id and w.b_send = 0 "
        " group by w.id "
      );
    return List.generate(oTMap.length, 
      (i) => OrdenTrabajo(       
        id: (oTMap[i]['id']).toString(),
        code: oTMap[i]['code'],
        scheduledAt: oTMap[i]['scheduled_at'], 
        priority: oTMap[i]['priority'], 
        assetId: (oTMap[i]['asset_id']).toString(), 
        assetType: oTMap[i]['asset_type'], 
        descriptionOfIssue: oTMap[i]['description_ofIssue'], 
        scopeOfWork: oTMap[i]['scope_of_work'], 
        locationX: oTMap[i]['location_x'], 
        locationY: oTMap[i]['location_y'], 
        notes: oTMap[i]['notes'], 
        assignedToId: (oTMap[i]['assigned_to_id']).toString(), 
        fullName: oTMap[i]['fullname'],
        completionId: (oTMap[i]['completion_id']).toString(),
        send: (oTMap[i]['b_send']).toString(), 
        completionAction: (oTMap[i]['completion_action']).toString(), 
        comentario: oTMap[i]['c_comentario'],
        countArchivos: (oTMap[i]['count(d.n_id_archivo)']).toString(),
      )
    );
  }

  static Future<List<OrdenTrabajo>> listOTSinAtendidos(id) async{
    Database database = await _openBD();
    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
        " SELECT *, count(d.n_id_archivo) FROM workordersbyuser w "
        " left join doc_archivo d on d.id_workordersbyuser = w.id "
        " where w.assigned_to_id = $id and w.b_send = 1 "
        " group by w.id "
      );
    return List.generate(oTMap.length, 
      (i) => OrdenTrabajo(       
        id: (oTMap[i]['id']).toString(),
        code: oTMap[i]['code'],
        scheduledAt: oTMap[i]['scheduled_at'], 
        priority: oTMap[i]['priority'], 
        assetId: (oTMap[i]['asset_id']).toString(), 
        assetType: oTMap[i]['asset_type'], 
        descriptionOfIssue: oTMap[i]['description_ofIssue'], 
        scopeOfWork: oTMap[i]['scope_of_work'], 
        locationX: oTMap[i]['location_x'], 
        locationY: oTMap[i]['location_y'], 
        notes: oTMap[i]['notes'], 
        assignedToId: (oTMap[i]['assigned_to_id']).toString(), 
        fullName: oTMap[i]['fullname'],
        completionId: (oTMap[i]['completion_id']).toString(),
        send: (oTMap[i]['b_send']).toString(), 
        completionAction: (oTMap[i]['completion_action']).toString(), 
        comentario: oTMap[i]['c_comentario'],
        countArchivos: (oTMap[i]['count(d.n_id_archivo)']).toString(),
      )
    );
  }

  static Future<List<OrdenTrabajo>> listOTEnviados(id) async {
    Database database = await _openBD();
    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
        " SELECT *, count(d.n_id_archivo) FROM workordersbyuser w "
        " left join doc_archivo d on d.id_workordersbyuser = w.id "
        " where w.assigned_to_id = $id and w.b_send = 2 "
        " group by w.id "
      );
    /*for (var i in oTMap) {   
      //print(i['id_workordersby_user']);   
      print("---"+i['asset_type']);
      print("---"+i['username']);
      print(i['count(d.n_id_archivo)']);
    }*/
    return List.generate(oTMap.length, 
      (i) => OrdenTrabajo(       
        id: (oTMap[i]['id']).toString(),
        code: oTMap[i]['code'],
        scheduledAt: oTMap[i]['scheduled_at'], 
        priority: oTMap[i]['priority'], 
        assetId: (oTMap[i]['asset_id']).toString(), 
        assetType: oTMap[i]['asset_type'], 
        descriptionOfIssue: oTMap[i]['description_ofIssue'], 
        scopeOfWork: oTMap[i]['scope_of_work'], 
        locationX: oTMap[i]['location_x'], 
        locationY: oTMap[i]['location_y'], 
        notes: oTMap[i]['notes'], 
        assignedToId: (oTMap[i]['assigned_to_id']).toString(), 
        fullName: oTMap[i]['fullname'],
        completionId: (oTMap[i]['completion_id']).toString(),
        send: (oTMap[i]['b_send']).toString(), 
        completionAction: (oTMap[i]['completion_action']).toString(),
        comentario: oTMap[i]['c_comentario'],
        countArchivos: (oTMap[i]['count(d.n_id_archivo)']).toString(),
      )
    );
  }

  static Future<List<Marker>> ListMArkerOTs() async {
    Database database = await _openBD();

    final List<Map<String, dynamic>> oTMap = await database.query("workordersbyuser");
    for (var i in oTMap) {   
      //print(i['id_workordersby_user']);   
      print(i['location_x']);
      print(i['location_y']);
      print(i['completion']);
    }
    return List.generate(oTMap.length, 
      (i) => Marker(  
        key: Key((oTMap[i]['id']).toString()),      
        point: LatLng(double.parse(oTMap[i]['location_y']), double.parse(oTMap[i]['location_x'])),
        width: 40,
        height: 40,
        builder: (_) => const Icon(Icons.location_on, color: Colors.black,),
        anchorPos: AnchorPos.align(AnchorAlign.top),
        rotate: true,
      )
    );
  }

  /*static Future<List<LatLng>> ListLineas2() async {
    Database database = await _openBD();
    List<LatLng> arr = [];
    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
      "SELECT n_latitud_ini, n_longitud_ini, n_latitud_fin, n_longitud_fin FROM pl_linea"
    );
    for (var i in oTMap) {
      arr.add(
        LatLng(i['n_latitud_ini'], i['n_longitud_ini'])
      );
      arr.add(
        LatLng(i['n_latitud_fin'], i['n_longitud_fin'])
      );
    }
    return arr;
  }*/

  /*static Future<List<Polyline>> ListLineas() async {
    Database database = await _openBD();

    final List<Map<String, dynamic>> oTMap = await database.query("pl_linea");
    
    return List.generate(oTMap.length, 
      (i) => Polyline(
        points: [
          LatLng(oTMap[i]['n_latitud_ini'],oTMap[i]['n_longitud_ini']),
          LatLng(oTMap[i]['n_latitud_fin'],oTMap[i]['n_longitud_fin']),
        ],
        /*color: const Color(0xFF669DF6),
        strokeWidth: 1.0,
        borderColor: const Color(0xFF1967D2),
        borderStrokeWidth: 0.3,*/
      )
    );
  }*/
  static Future<List<Marker>> ListPuntos() async {
    Database database = await _openBD();
    final List<Map<String, dynamic>> oTMap = await database.query("pl_estructura");
    for (var i in oTMap) {
      if(i['c_tipo_punto'] == 'RI'){
        print(i['c_tipo_punto']);
      }
    }
    return List.generate(oTMap.length, 
      (i) => Marker(        
        point: LatLng(oTMap[i]['n_latitud'], oTMap[i]['n_longitud']),
        width: 10,
        height: 10,
        //ICONO
        //builder: (ctx) => Image.asset("assets/mapa/${oTMap[i]['c_tipo_punto']}.png"),
        builder: (ctx) => SvgPicture.asset("assets/mapa/${oTMap[i]['c_tipo_punto']}.svg"),
        anchorPos: AnchorPos.align(AnchorAlign.center),
      )
    );
  }

  static Future<OrdenTrabajo> MarkerOT(double latitude, double longitude, int id) async {
    Database database = await _openBD();
    final List<Map<String, dynamic>> oTMap = await database.query("workordersbyuser");
    for (var i in oTMap) {   
      if( latitude == double.parse(i['location_y']) &&
        longitude == double.parse(i['location_x']) && id == i['id']
      ){
        print("Encuentras marker");
        return OrdenTrabajo(
            id: (i['id']).toString(),
            code: i['code'],
            scheduledAt: i['scheduled_at'],              
            priority: i['priority'], 
            assetId: (i['asset_id']).toString(), 
            assetType: i['asset_type'], 
            descriptionOfIssue: i['description_ofIssue'], 
            scopeOfWork: i['scope_of_work'], 
            locationX: i['location_x'], 
            locationY: i['location_y'], 
            notes: i['notes'], 
            assignedToId: (i['assigned_to_id']).toString(), 
            fullName: i['fullname'],
            completionId: (i['completion_id']).toString(),
            send: (i['b_send']).toString(),
            completionAction: (i['completion_action']).toString(),
            comentario: i['c_comentario'],
            countArchivos: '0'
        );
      }
    }
    return OrdenTrabajo(id:'', code: '', scheduledAt: '', priority: '', assetId: '', assetType: '', descriptionOfIssue: '', scopeOfWork: '', locationX: '', locationY: '', notes: '', assignedToId: '', fullName: '', completionId: '', send: '', completionAction: '', comentario: '', countArchivos: '0');
  }

  static Future<List<String>> listOptionBuscar(String query, bool valueEstruct, bool valueSubEst, bool valueOT, bool valueLLV, bool valuePAP, bool valuePCR, bool valuePSP, bool valueSED) async {
    Database database = await _openBD();
    List<String> list = [];
    list.clear();
    if (valueEstruct) {
      final List<Map<String, dynamic>> oTMap2 = await database.rawQuery(
        " SELECT c_codigo, c_tipo_punto FROM pl_estructura"
        " WHERE c_codigo LIKE '%$query%' "
        "ORDER BY c_codigo ASC"
      );

      if (oTMap2.isNotEmpty) {
        for (var i in oTMap2) {
          if (list.length < 20) {
            list.add(i['c_codigo'] + ' / ' +i['c_tipo_punto']);
          }
        }
      }
    } else if(valueSubEst){

    }else if(valueOT){
      final List<Map<String, dynamic>> oTMap1 = await database.rawQuery(
        " SELECT code, asset_type FROM workordersbyuser "
        " WHERE code LIKE '%$query%' "
      );
      if (oTMap1.isNotEmpty) {
        for (var i in oTMap1) {
          if(list.length < 20){
            list.add(i['code']+" / "+i['asset_type']);
          }
        }
      }
    } else if (valueLLV){
      final List<Map<String, dynamic>> oTMap3 = await database.rawQuery(
        " SELECT c_codigo, c_tipo_punto FROM pl_estructura"
        " WHERE c_tipo_punto = 'LLV' and c_codigo LIKE '%$query%' "
        "ORDER BY c_codigo ASC"
      );

      if (oTMap3.isNotEmpty) {
        for (var i in oTMap3) {
          if (list.length < 20) {
            list.add(i['c_codigo'] + ' / ' +i['c_tipo_punto']);
          }
        }
      }

    } else if (valuePAP){

      final List<Map<String, dynamic>> oTMap4 = await database.rawQuery(
        " SELECT c_codigo, c_tipo_punto FROM pl_estructura"
        " WHERE c_tipo_punto = 'PAP' and c_codigo LIKE '%$query%' "
        "ORDER BY c_codigo ASC"
      );

      if (oTMap4.isNotEmpty) {
        for (var i in oTMap4) {
          if (list.length < 20) {
            list.add(i['c_codigo'] + ' / ' +i['c_tipo_punto']);
          }
        }
      }

    } else if (valuePCR){

      final List<Map<String, dynamic>> oTMap5 = await database.rawQuery(
        " SELECT c_codigo, c_tipo_punto FROM pl_estructura"
        " WHERE c_tipo_punto = 'PCR' and c_codigo LIKE '%$query%' "
        "ORDER BY c_codigo ASC"
      );

      if (oTMap5.isNotEmpty) {
        for (var i in oTMap5) {
          if (list.length < 20) {
            list.add(i['c_codigo'] + ' / ' +i['c_tipo_punto']);
          }
        }
      }

    } else if (valuePSP){
      final List<Map<String, dynamic>> oTMap6 = await database.rawQuery(
        " SELECT c_codigo, c_tipo_punto FROM pl_estructura"
        " WHERE c_tipo_punto = 'PSP' and c_codigo LIKE '%$query%' "
        "ORDER BY c_codigo ASC"
      );

      if (oTMap6.isNotEmpty) {
        for (var i in oTMap6) {
          if (list.length < 20) {
            list.add(i['c_codigo'] + ' / ' +i['c_tipo_punto']);
          }
        }
      }

    } else if (valueSED){
      final List<Map<String, dynamic>> oTMap7 = await database.rawQuery(
        " SELECT c_codigo, c_tipo_punto FROM pl_estructura"
        " WHERE c_tipo_punto = 'SED' and c_codigo LIKE '%$query%' "
        "ORDER BY c_codigo ASC"
      );

      if (oTMap7.isNotEmpty) {
        for (var i in oTMap7) {
          if (list.length < 20) {
            list.add(i['c_codigo'] + ' / ' +i['c_tipo_punto']);
          }
        }
      }
    }
    
    return list;
  }

  static Future<LatLng> buscar(String query ) async {
    print(query);
    Database database = await _openBD();
    String queryAux = query.split(" / ")[0];
    double latitud = 0.0;
    double longitud= 0.0;
    print(queryAux);
    final List<Map<String, dynamic>> oTMap1 = await database.rawQuery(
      " SELECT code, location_y, location_x FROM workordersbyuser "
      " WHERE code LIKE '%$queryAux%' "
    );
    
    if (oTMap1.isNotEmpty) {
      latitud = double.parse(oTMap1[0]['location_y']);
      longitud = double.parse(oTMap1[0]['location_x']);
    }else {
      final List<Map<String, dynamic>> oTMap2 = await database.rawQuery(
        " SELECT c_codigo, n_latitud, n_longitud FROM pl_estructura "
        "where c_codigo LIKE '%$queryAux%'"
      );
      if (oTMap2.isNotEmpty) {
        latitud = oTMap2[0]['n_latitud'];
        longitud = oTMap2[0]['n_longitud'];
      }
    }
    print('$latitud $longitud');
    return LatLng(latitud,longitud);
  }

  static Future insertTracking(Location location, User user, date, int estado) async {
    Database database = await _openBD();
    
    print("Insert Tracking --- estado: " + estado.toString());
 
    database.rawInsert(
      "insert into tracking(latitud, longitud, altitud, precision, id, username, fullname, fecha, estado)"
      "values (${location.latitude}, ${location.longitude}, ${location.altitude}, ${location.accuracy}, ${user.id}, '${user.username}', '${user.fullname}', '$date' , $estado )"
    );

  }

  static Future<List<Tracking>> getTrackingSinEnviar(User user) async {
    Database database = await _openBD();
    
    print("GET Tracking");
 
    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
      "select * from  tracking where estado = 0 and id = ${user.id}"
    );

    return List.generate(oTMap.length, 
      (i) => Tracking(
          n_id: oTMap[i]['n_id'], 
          latitud: oTMap[i]['latitud'], 
          longitud: oTMap[i]['longitud'], 
          altitud: oTMap[i]['altitud'], 
          precision: oTMap[i]['precision'], 
          id: oTMap[i]['id'], 
          username: oTMap[i]['username'], 
          fullname: oTMap[i]['fullname'], 
          fecha: oTMap[i]['fecha'], 
          estado: oTMap[i]['estado']
        )
      );
  }

  static Future<int> updateTrackingSinEnviar(int n_id) async {
    Database db = await _openBD();

    var resultado = await db.rawUpdate(
      "UPDATE tracking SET estado = 1  WHERE n_id = $n_id;" 
    );
    print("rows Update: "+resultado.toString());
    return resultado;
  }
  

  static Future insertArchivo(int id, String checksum, String cRuta, String cFecha) async {
    Database database = await _openBD();
    
    print("Insert Archivo");
    database.rawInsert(
      "insert into doc_archivo(id_workordersbyuser, c_checksum, c_ruta, c_fecha)"
      "values ($id, '$checksum', '$cRuta', '$cFecha')"
    );

  }

  static Future<List<Map<String, dynamic>>> getDataArchivosOT() async {
    Database database = await _openBD();

    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
      " SELECT w.id, w.completion_id, w.code, ar.id_workordersbyuser, count(ar.id_workordersbyuser) FROM doc_archivo ar"
      " inner join workordersbyuser w on w.id = ar.id_workordersbyuser"
      " GROUP BY ar.id_workordersbyuser"
    );
    return oTMap;
  }

  static Future<List<MultipartFile>> getArchivosOT( int id) async {
    Database database = await _openBD();

    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
      " SELECT * FROM doc_archivo "
      "WHERE id_workordersbyuser = $id"
    );
    var multipartFile = <MultipartFile>[];

    for (var i in oTMap) {
      var extension = p.extension(i['c_ruta']);

      if (extension == '.mp4') {
        print(extension);
        multipartFile.add(
          MultipartFile.fromBytes(
            'video',
            File(i['c_ruta']).readAsBytesSync(),
            filename: '${i['c_checksum']}.mp4',
            contentType: MediaType("video", "mp4"),
          )
        );
      }
      if (extension == '.jpg') {
        print(extension);
        multipartFile.add(
          MultipartFile.fromBytes(
            'photo',
            File(i['c_ruta']).readAsBytesSync(),
            filename: '${i['c_checksum']}.mp4',
            contentType: MediaType("image", "jpeg"),
          )
        );
      }
    }
    print("multipartFile-length --- " + multipartFile.length.toString());
    return multipartFile;
    
  }
  static Future<List<Map<String, dynamic>>> getArchivosOTShow( int id) async {
     Database database = await _openBD();

    final List<Map<String, dynamic>> oTMap = await database.rawQuery(
      " SELECT * FROM doc_archivo "
      "WHERE id_workordersbyuser = $id"
    );

    print(oTMap.toString());

    return oTMap;
    
  }
  //SENTENCIAS SQL

  /*static Future insertar2(Users users) async {
    Database database = await _openBD();
    var resultado = await database.rawInsert(
      "insert into users (id, updatedAt, username, fullname, profileId)"
      "values ( ${users.id}, ${users.updatedAt}, ${users.username}, ${users.fullname}, ${users.profileId}, ${users.password} )"
    );
  }*/

}