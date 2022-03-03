

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/ui/pages/animacion/animacion.dart';
import 'package:flutter_application_1/app/ui/pages/home/home_page.dart';
import 'package:flutter_application_1/app/ui/pages/logn/login.dart';
import 'package:flutter_application_1/app/ui/pages/request_permission/request_permission_page.dart';
import 'package:flutter_application_1/app/ui/pages/splash/splash_page.dart';
import 'package:flutter_application_1/app/ui/pages/video/video.dart';
import 'package:flutter_application_1/app/ui/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes(){
  return{
    Routes.SPLASH:(_)=> const SplashPage(),
    Routes.PERMISSIONS:(_)=> const RequestPermissionPage(),    
    Routes.LOGIN:(_)=> const Login(),
    Routes.HOME:(_) => const HomePage(),
    Routes.VIDEO:(_) => const VideoCam(),
    Routes.ANIMACION:(_) => const Animacion(),
  };
}