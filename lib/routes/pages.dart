import 'package:flutter/cupertino.dart';
import 'package:flutter_application/pages/enviarArchivos/enviarArchivos.dart';
import 'package:flutter_application/pages/home/home.dart';
import 'package:flutter_application/pages/home/show_ot.dart';
import 'package:flutter_application/pages/login/carga.dart';
import 'package:flutter_application/pages/login/login.dart';
import 'package:flutter_application/pages/mapa/mapaflutter.dart';
import 'package:flutter_application/pages/mapa/request_permission_page.dart';
import 'package:flutter_application/pages/mapa/splash_page.dart';
import 'package:flutter_application/routes/routes.dart';
import "package:latlong2/latlong.dart";

Map<String, Widget Function(BuildContext)> appRoutes(){
  return{
    Routes.LOGIN:(_) => const Login(),
    Routes.HOME:(_) => const Home(),
    Routes.ENVIAR_ARCHIVOS:(_) => const FormOT(),
    Routes.SPLASH:(_) => const SplashPage(),
    Routes.PERMISSIONS:(_) => const RequestPermissionPage(),
    Routes.MAPAFLUTTER:(_) => Mapaflutter(LatLng(-12.061316,-77.112514), 10.0),
    Routes.CARGAINI:(_) => const InicioCarga(),
    Routes.SHOW_OT:(_) => const OpenContainerTransformDemo(),
  };
}