import 'dart:ffi';

import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/bd/tracking.dart';
import 'package:flutter_application/pages/validacion/connectivity.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:flutter_application/bd/users.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:graphql_flutter/graphql_flutter.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final sentTracking = """
        mutation CreateTracking(\$options: LocationInput!){
          createTracking(options: \$options){
            id
            latitud
            longitud
            altitud
            precision
            employee{
              id
            }
          }
        }
      """;

  List<Tracking> listTrackingSinEnviar = [];
  @override
  void initState() {
    
    super.initState();
  }

  @override
  void dispose() {
    //BackgroundLocation.stopLocationService();
    super.dispose();
  }

  String userLog ='';
  String passwordLog ='';
  final formkey = GlobalKey<FormState>();
  //Users users = Users(id: [], username: [], fullname: [], password: []);
  var fontSize = 20.0; //14
  var iconSize = 34.0; //24
  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent));*/

    return Scaffold(
      body: Stack(
        children: [          
          Image.asset(            
            'assets/background_blanco.png',
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 60,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(            
                      'assets/ICONO_POUR.png',
                      fit: BoxFit.fill,
                      height: 115,
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                Image.asset(            
                  'assets/NOMBRE_POUER.png',
                  fit: BoxFit.fill,
                  width: 150,
                ),
                const SizedBox(
                  height: 80,
                ),
                const Text(
                  'Bienvenidos a nuestra aplicación',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Color.fromRGBO(119, 118, 118, 1),
                  ),
                ),

              ] 
            ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 16,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                              //border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          )),
                      Container(
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                hintText: 'USUARIO',
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    fontSize: fontSize,
                                    color: const Color.fromRGBO(119, 118, 118, 1),
                                )
                            ),
                            style: const TextStyle(fontSize: 16,
                                color: Colors.black38),
                            onSaved: (value) {
                              userLog =  value!;
                            }
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              //border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  Icons.vpn_key,
                                  color: Colors.black,
                                  size: iconSize,
                                ),
                              ),
                            ],
                          )),
                      Container(
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                          child: TextFormField(
                            obscureText: true,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'CONTRASEÑA',
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: fontSize,
                                  color: const Color.fromRGBO(119, 118, 118, 1),
                              ),
                            ),
                            style: const TextStyle(fontSize: 16,
                                color: Colors.black45),
                            onSaved: (value) {
                              passwordLog =  value!;
                            },
                          )),
                    ],
                  ),                  
                  const SizedBox(height: 16, ),    
                  Mutation(
                    options: MutationOptions(
                      document: gql(sentTracking), 
                      update: (GraphQLDataProxy cache, QueryResult? result) {

                      },
                      onCompleted: (dynamic resultData) {
                        print("RESULT MUTATION" + resultData.toString());
                        
                      },
                    ),
                    builder: (
                      RunMutation runMutation,
                      QueryResult? result,
                    ){
                      return ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromRGBO(0, 34, 61, 1),
                          ),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.fromLTRB(107, 15, 107, 15),
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),)
                          ),
                        ),
                        onPressed: () async {     
                          formkey.currentState?.save();                             
                          User user = await BD.users(userLog, passwordLog);
                        
                          if (user.id != 0) {
                            await BackgroundLocation.setAndroidNotification(
                              title: '',
                              message: '',
                              icon: '',
                            );
                            //await BackgroundLocation.setAndroidConfiguration(1000);
                            
                            await BackgroundLocation.startLocationService(
                              distanceFilter: 0,
                              //forceAndroidLocationManager: true
                            );
                            
                            DateTime _selectedDate = DateTime.now();
                            int min = 0;

                            BackgroundLocation.getLocationUpdates((location) async {       
                              DateTime date = DateTime.now();                          
                              var dateAux = _selectedDate.add(Duration(minutes: min));
                              if(date.hour == dateAux.hour){
                                if (date.minute >= dateAux.minute ) {
                                  min += 1;
                                  print('''\n
                                    Latitude:  ${location.latitude}
                                    Longitude: ${location.longitude}
                                    Altitude: ${location.altitude}
                                    Accuracy: ${location.accuracy}
                                    Bearing:  ${location.bearing}
                                    Speed: ${location.speed}
                                    Time: ${location.time}
                                    Fecha: $date
                                  ''');
                                  bool result = await internetConnectivity(); 
                                  print("CONECTIVIDAD INTERNET - "+result.toString());
                                  
                                  listTrackingSinEnviar = await BD.getTrackingSinEnviar(user);
                                  if(result){
                                    for (var item in listTrackingSinEnviar) {
                                      print(item.n_id);
                                      runMutation(
                                        {
                                          "options":{
                                            "latitud" : item.latitud,
                                            "longitud": item.longitud,
                                            "altitud": item.altitud,
                                            "precision": item.precision,
                                            "employee": item.id
                                          }
                                        }
                                      );
                                      BD.updateTrackingSinEnviar(item.n_id);
                                    }
                                    runMutation(
                                      {
                                        "options":{
                                          "latitud" : location.latitude,
                                          "longitud": location.longitude,
                                          "altitud": location.altitude,
                                          "precision": location.accuracy,
                                          "employee": user.id
                                        }
                                      }
                                    );  
                                    BD.insertTracking(location, user, date, 1);                                 
                                  }else{
                                    BD.insertTracking(location, user, date, 0);
                                  }
                                  
                                }
                              }                              
                            });
                            //cargaOtUserLog(context);
                            Navigator.pushReplacementNamed(context, Routes.MAPAFLUTTER);
                          }else{
                            showAlertUsers(context, 'Usuario no encontrado');  
                          }
                          
                        },                           
                        child: Text(
                          'INGRESAR',
                          style: TextStyle(
                            fontSize: fontSize,
                            color: const Color.fromRGBO(44, 240, 233, 1),
                          ),
                        ),
                      );
                    }
                  ), 
                   
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
  
}