
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/pages/mapa/request_permission_controler.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissionPage extends StatefulWidget {
  const RequestPermissionPage({Key? key}) : super(key: key);

  @override
  State<RequestPermissionPage> createState() => _RequestPermissionPageState();
}

class _RequestPermissionPageState extends State<RequestPermissionPage> with WidgetsBindingObserver {

  final _controller = RequestPermissionController(Permission.locationWhenInUse);
  late StreamSubscription _subscription;

  @override
  void initState() {
    _controller.request();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _subscription = _controller.onStatusChanged.listen(
      (status) { 
        switch (status) {
          case PermissionStatus.granted:
            //Navigator.pushReplacementNamed(context, Routes.MAPA);
            Navigator.pushReplacementNamed(context, Routes.CARGAINI);
            break;
          case PermissionStatus.permanentlyDenied:
            showDialog(
              context: context, 
              builder: (_)=>AlertDialog(
                title:const Text("INFO"),
                content:const Text("Acceso denegado Permanentemente"),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                      openAppSettings();
                    }, 
                    child:const Text("Configuración")
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child:const Text("Cancelar")
                  ),
                ],
              ));
            
            break;
          case PermissionStatus.denied:
            showDialog(
              context: context, 
              builder: (_)=>AlertDialog(
                title:const Text("INFO"),
                content:const Text("Acceso denegado"),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                      openAppSettings();
                    }, 
                    child:const Text("Configuración")
                  ),
                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child:const Text("Cancelar")
                  ),
                ],
              ));
            break;
          case PermissionStatus.restricted:
            
            break;
          case PermissionStatus.limited:
            
            break;
        }
        
      });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if(state == AppLifecycleState.resumed){
      final status = await _controller.check();
      if(status == PermissionStatus.granted){
        //Navigator.pushReplacementNamed(context, Routes.MAPA);
        Navigator.pushReplacementNamed(context, Routes.CARGAINI);
      }
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: ElevatedButton(
            onPressed: (){
              _controller.request();
            }, 
            child:const Text("Permitir acceso a la ubicacion del dispositivo")),
        ),
      ),*/
    );
  }
}