import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/bd/pointsbygrid.dart';
import 'package:flutter_application/bd/users.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class InicioCarga extends StatefulWidget {
  const InicioCarga({Key? key}) : super(key: key);

  @override
  State<InicioCarga> createState() => _InicioCargaState();
}

class _InicioCargaState extends State<InicioCarga> {
  final String getDataUsers = """
    query { 
          users { 
            id 
            username 
            password 
            fullName 
            profile { 
              id 
              name 
            } 
          },
          app { 
            version 
            trackingEach 
          },
          PointsByGrid(gridId: 44676) { 
            id 
            objCode 
            objType 
            coordinates 
            topology { 
              id 
              topoName 
            }
          },
          LinesByGrid(gridId: 44676) { 
            id 
            objCode 
            objType 
            coordinates 
            topology { 
              id 
              topoName 
            }
          }
	      }  
    """;
 
  Users users = Users(id: [], username: [], fullname: [], password: []);
  PointsByGridList pointList = PointsByGridList(id: [], objcode: [], objtype: [], nlatitud: [], nlongitud: [], idtopology: [], nametopology: []);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(            
            'assets/pantalla_001_codigp.png',
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
          Query(
            options: QueryOptions(
              //errorPolicy: ErrorPolicy.ignore,
              document: gql(getDataUsers),
            ), 
            builder: (QueryResult result, {fetchMore, refetch} ){
              if (result.hasException) {
                //return alertNotifyException(context, 'Sin conexión');
                return Container();
              }
              /*if (result.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }*/
              if(result.isConcrete){
                var dataUser = result.data?['users'];//[i];//['username'];
                var dataPuntos = result.data?['PointsByGrid'];
                /*print(dataPuntos);
                print(result.data?['users'][0]['username']);
                print(result.data?['PointsByGrid'][0]['objType']);*/

                users.id.clear();
                users.username.clear();
                users.fullname.clear();
                users.password.clear();
                
                pointList.id.clear();
                pointList.idtopology.clear();
                pointList.nlatitud.clear();
                pointList.nlongitud.clear();
                pointList.objcode.clear();
                pointList.objtype.clear();
                pointList.nametopology.clear();

                for (var item in dataUser) {                   
                  users.id.add(item['id']);
                  users.username.add(item['username'].toString());
                  users.fullname.add(item['fullName'].toString());
                  users.password.add(item['password'].toString());                          
                }

                for (var item in dataPuntos) {
                  pointList.id.add(int.parse(item['id']));
                  pointList.idtopology.add(int.parse(item['topology'][0]['id']));
                  pointList.nlatitud.add(item['coordinates'][1]);
                  pointList.nlongitud.add(item['coordinates'][0]);
                  pointList.objcode.add(item['objCode'].toString());
                  pointList.objtype.add(item['objType'].toString());
                  pointList.nametopology.add(item['topology'][0]['topoName'].toString());
                }
                
                BD.insert(context, users, pointList);
                //return alertNotify('Usuarios actualizados');
              }
              return Container();
            },      
          ),
          
        ],
      ),
    );
  }
  
}


      