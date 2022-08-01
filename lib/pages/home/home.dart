import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/bd/ordenTrabajo.dart';
import 'package:flutter_application/pages/enviarArchivos/showArchivosOT.dart';
import 'package:flutter_application/pages/home/drawer.dart';
import 'package:flutter_application/pages/home/show_ot.dart';
import 'package:flutter_application/pages/mapa/mapaflutter.dart';
import 'package:flutter_application/pages/validacion/connectivity.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import "package:latlong2/latlong.dart";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
  int _id = 0; 
  String _username = '';
  String _fullname = ''; 
  String _password = '';
  bool estadoIcon = false;
class UL{
  static Future userLog(id, username, fullname,password) async {
    _id = id;
    _username = username;
    _fullname = fullname;
    _password = password;    
  }
}
class _HomeState extends State<Home> {
  final String getData = """
    query {           
          workordersByUser(userId: $_id) { 
            id
            code
            scheduledAt 
            priority
            assetId 
            assetType 
            descriptionOfIssue 
            scopeOfWork 
            locationX 
            locationY 
            notes 
            assignedTo { 
              id 
              fullName 
            }
            grid {
              id
              gridName
            }
            completion{
              id
              action
              description
              evidence{
                id
                description
                url
              }
            }
          }
	      }  
    """;

  final sentOt = """
        mutation CreateWorkorderCompletion(\$files: [Upload!]!, \$options: WorkorderCompletionInput!){
          createWorkorderCompletion(files: \$files, options: \$options){
            errors{
              field
              message
            }
            completion{
              id
              action
              description
              reportedBy{
                id
                fullName
              }
              workorder{
                id
                code
              }
              evidence{
                id
                url
              }
            }
          }
        }
      """;

  OrdenTrabajoList _OT = OrdenTrabajoList(id: [], code: [], scheduledAt: [], priority: [], assetId: [], assetType: [], descriptionOfIssue: [], scopeOfWork: [], locationX: [], locationY: [], notes: [], assignedToId: [], fullName: [], completionId: [], completionAction: []);
  List<OrdenTrabajo> listOTPendientes = [];
  List<OrdenTrabajo> AuxlistOTPendientes = [];
  List<OrdenTrabajo> listOTAtendidos = [];
  List<OrdenTrabajo> AuxlistOTAtendidos = [];
  List<OrdenTrabajo> listOTEnviados = [];
  List<OrdenTrabajo> AuxlistOTEnviados = [];
  List iconCargaArray = <bool>[];
  bool sendOts = false;
  @override
  void initState() {
    cargaOTs( _id );
    super.initState();
    cargaOTs( _id );
  }

  showSnackBar(String msn){
    final snackBar = SnackBar(
          content: Text(msn),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  cargaOTs(id) async {
    AuxlistOTPendientes = await BD.listOTSinPendientes(id);
    AuxlistOTAtendidos = await BD.listOTSinAtendidos(id);
    AuxlistOTEnviados = await BD.listOTEnviados(id);    
    setState(() {
      listOTPendientes = AuxlistOTPendientes;
      listOTAtendidos = AuxlistOTAtendidos;
      listOTEnviados = AuxlistOTEnviados;
      
      for (var item in listOTPendientes) {
        iconCargaArray.add(false);
      }
      estadoIcon = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const Drawer(child: Drawers(),),
        appBar: AppBar(
          title: const Text("Bandeja de OT",
            style: TextStyle(
              fontSize: 22
            ),
          ),
          bottom: TabBar(
                indicatorColor: const Color.fromRGBO(0, 34, 61, 1),
                labelColor: const Color.fromRGBO(0, 34, 61, 1),
                tabs: const [
                  Tab(text: 'Pendientes'),
                  Tab(text: 'Atendidos'),
                  Tab(text: 'Enviados',)
                ],
                labelStyle: TextStyle(fontSize: fontSize),
                onTap: (value) {
                  if (value == 1) { setState(() {sendOts = true;}); cargaOTs(_id);
                  }else{ setState(() {sendOts = false;}); cargaOTs(_id); }
                },
              ),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(44, 240, 233, 1),
          foregroundColor: const Color.fromRGBO(0, 34, 61, 1),
          actions: [
            IconButton(
              onPressed: () {
                try {
                  cargaOtUserLog(context).then((value) => cargaOTs(_id));
                } catch (e) {
                  showSnackBar(e.toString());
                }
                //cargaOTs(_id);
              }, 
              icon: const Icon(Icons.file_download_outlined,color: Color.fromRGBO(0, 34, 61, 1), size: 34,),
            ),
            /*IconButton(
              onPressed: () {
                cargaOTs(_id);
              }, 
              icon: const Icon(Icons.sync_rounded,color: Color.fromRGBO(0, 34, 61, 1),),
            ),*/
          ],
        ),
        
        body: TabBarView(
          children: [
            listaOtsPendientes(),
            listaOtsAtendidos(),
            listaOtsEnviados(),
          ],
        ),
        floatingActionButton: sendOts ? Mutation(
          options: MutationOptions(
            document: gql(sentOt), 
            update: (GraphQLDataProxy cache, QueryResult? result) {
              /*var msn = result?.data!['errors'];
              if (msn != null) {
                showSnackBar(msn);
              }*/
            },
            onCompleted: (dynamic resultData) {
              //print("RESULT MUTATION" + resultData);
              setState(() {
                estadoIcon = false;
              });
              //cargaOTs(_id);
            },
            onError: (error) => showSnackBar(error!.graphqlErrors.toString()),
          ),
          builder: (
            RunMutation runMutation,
            QueryResult? result,
          ) {
            return FloatingActionButton(
              onPressed: () async {
                cargaOTs(_id);
                bool result = await internetConnectivity();
                if (result) {
                  var i = 0;
                  for (var item in listOTAtendidos) {    
                    if (item.countArchivos != '0' && (item.completionAction != 'null' || item.completionAction != '') ) {
                      setState(() {
                        iconCargaArray[i] = true;
                        estadoIcon = true;
                      });
                      var multipartFileArray = await BD.getArchivosOT(int.parse(item.id));                    
                      runMutation(
                        {
                          "options": {
                            "workorderId": int.parse(item.id),
                            "userId" : int.parse(item.assignedToId),
                            "action": int.parse(item.completionAction),
                            "description": item.comentario
                          },
                          "files": multipartFileArray
                        }
                      );
                      await BD.updateOtSend(int.parse(item.id));
                      setState(() {
                        iconCargaArray[i] = false;
                      });
                    }else{
                      //showSnackBar(item.code + " sin archivos");
                    }
                  }     
                  cargaOTs(_id);
                }else{
                  alertNotifyException(context, 'Sin conexión');
                }
              }, 
              child: const Icon(Icons.send_rounded,color: Color.fromRGBO(44, 240, 233, 1), ),
              backgroundColor: const Color.fromRGBO(0, 34, 61, 1),
            );
          },
        ) : Container(),
      ),
    );
  }

  listaOtsPendientes(){
    return 
      ListView.builder(
        itemCount: listOTPendientes.length,
        itemBuilder: (context, i) {   
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(   
                  leading: Transform.scale(
                    scale: 1.2,
                    child: CircleAvatar(
                      child: Text((listOTPendientes[i].priority.substring(0,2)).toUpperCase(), style: const TextStyle(color: Color.fromRGBO(44, 240, 233, 1)),),
                      backgroundColor: const Color.fromRGBO(0, 34, 61, 1),
                    ),
                  ),
                  title: Text(listOTPendientes[i].code, style: const TextStyle(fontSize: 20),),
                  subtitle: Text(listOTPendientes[i].assetType, style: TextStyle(fontSize: fontSize),),            
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          print('listOTSinEnviar---' + listOTPendientes[i].comentario);
                          OT.showOT(listOTPendientes[i].id, listOTPendientes[i].priority, listOTPendientes[i].assetType, listOTPendientes[i].descriptionOfIssue, listOTPendientes[i].scopeOfWork, listOTPendientes[i].notes, listOTPendientes[i].assetId, listOTPendientes[i].send, listOTPendientes[i].code, listOTPendientes[i].comentario, listOTPendientes[i].completionAction);
                          return const OpenContainerTransformDemo();
                        },
                      ),
                    ).then((value) => cargaOTs(_id));
                  },
                  trailing: 
                  iconCargaArray[i] ? 
                    estadoIcon ?  const SizedBox(
                      width: 25, height: 25,
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(0, 34, 61, 1),
                      ),
                    )
                    :
                    const Icon(Icons.check_circle_rounded, color: Color.fromRGBO(44, 240, 233, 1),) 
                  :
                  const SizedBox(width: 25, height: 25,),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text("• "+listOTPendientes[i].descriptionOfIssue, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text('• Trabajo: ${listOTPendientes[i].scopeOfWork}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text('• Nota: ${listOTPendientes[i].notes}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text('• Prioridad: ${listOTPendientes[i].priority}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                      ],
                    ),
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return Mapaflutter(LatLng(double.parse(listOTPendientes[i].locationY), double.parse(listOTPendientes[i].locationX)), 18.0);
                            },
                          ),
                        );
                      },
                      icon:  Icon(Icons.map_rounded,  color: const Color.fromRGBO(0, 34, 61, 1), size: iconSize,),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return ShowArchivoOT(id: int.parse(listOTPendientes[i].id), code: listOTPendientes[i].code,);
                              },
                            ),
                          );
                      },
                      icon: Icon(Icons.perm_media_outlined, color: const Color.fromRGBO(0, 34, 61, 1), size: iconSize,),
                    ),
                    Text(listOTPendientes[i].countArchivos),
                    /*TextButton(
                      onPressed: () {
                        // Perform some action
                      },
                      child: const Text('ACTION 2'),
                    ),*/
                  ],
                ),
              ],
            ),
          );
        }          
      );
  }
  listaOtsAtendidos(){
    return 
      ListView.builder(
        itemCount: listOTAtendidos.length,
        itemBuilder: (context, i) {   
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(   
                  leading: Transform.scale(
                    scale: 1.2,
                    child: CircleAvatar(
                      child: Text((listOTAtendidos[i].priority.substring(0,2)).toUpperCase(), style: const TextStyle(color: Color.fromRGBO(44, 240, 233, 1)),),
                      backgroundColor: const Color.fromRGBO(0, 34, 61, 1),
                    ),
                  ),
                  title: Text(listOTAtendidos[i].code, style: const TextStyle(fontSize: 20),),
                  subtitle: Text(listOTAtendidos[i].assetType, style: TextStyle(fontSize: fontSize),),            
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          print('listOTSinEnviar---' + listOTAtendidos[i].comentario);
                          OT.showOT(listOTAtendidos[i].id, listOTAtendidos[i].priority, listOTAtendidos[i].assetType, listOTAtendidos[i].descriptionOfIssue, listOTAtendidos[i].scopeOfWork, listOTAtendidos[i].notes, listOTAtendidos[i].assetId, listOTAtendidos[i].send, listOTAtendidos[i].code, listOTAtendidos[i].comentario, listOTAtendidos[i].completionAction);
                          return const OpenContainerTransformDemo();
                        },
                      ),
                    ).then((value) => cargaOTs(_id));
                  },
                  trailing: 
                  iconCargaArray[i] ? 
                    estadoIcon ?  const SizedBox(
                      width: 25, height: 25,
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(0, 34, 61, 1),
                      ),
                    )
                    :
                    const Icon(Icons.check_circle_rounded, color: Color.fromRGBO(44, 240, 233, 1),) 
                  :
                  const SizedBox(width: 25, height: 25,),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text("• "+listOTAtendidos[i].descriptionOfIssue, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text('• Trabajo: ${listOTAtendidos[i].scopeOfWork}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text('• Nota: ${listOTAtendidos[i].notes}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                          child: Text('• Prioridad: ${listOTAtendidos[i].priority}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                        ),
                      ],
                    ),
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return Mapaflutter(LatLng(double.parse(listOTAtendidos[i].locationY), double.parse(listOTAtendidos[i].locationX)), 18.0);
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.map_rounded,  color: const Color.fromRGBO(0, 34, 61, 1), size: iconSize,),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                return ShowArchivoOT(id: int.parse(listOTAtendidos[i].id), code: listOTAtendidos[i].code,);
                              },
                            ),
                          );
                      },
                      icon: Icon(Icons.perm_media_outlined, color: const Color.fromRGBO(0, 34, 61, 1), size: iconSize,),
                    ),
                    Text(listOTAtendidos[i].countArchivos),
                    /*TextButton(
                      onPressed: () {
                        // Perform some action
                      },
                      child: const Text('ACTION 2'),
                    ),*/
                  ],
                ),
              ],
            ),
          );
        }          
      );
  }
  listaOtsEnviados(){
    return 
    ListView.builder(
      itemCount: listOTEnviados.length,
      itemBuilder: (context, i) {   
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(   
                leading: Transform.scale(
                  scale: 1.2,
                  child: CircleAvatar(
                    child: Text((listOTEnviados[i].priority.substring(0,2)).toUpperCase(), style: const TextStyle(color: Color.fromRGBO(44, 240, 233, 1)),),
                    backgroundColor: const Color.fromRGBO(0, 34, 61, 1),
                  ),
                ),
                title: Text(listOTEnviados[i].code, style: const TextStyle(fontSize: 20),),
                subtitle: Text(listOTEnviados[i].assetType, style: TextStyle(fontSize: fontSize),),            
                /*onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        print('listOTSinEnviar---' + listOTEnviados[i].comentario);
                        OT.showOT(listOTEnviados[i].id, listOTEnviados[i].priority, listOTEnviados[i].assetType, listOTEnviados[i].descriptionOfIssue, listOTEnviados[i].scopeOfWork, listOTEnviados[i].notes, listOTEnviados[i].assetId, listOTEnviados[i].send, listOTEnviados[i].code, listOTEnviados[i].comentario, listOTEnviados[i].completionAction);
                        return const OpenContainerTransformDemo();
                      },
                    ),
                  ).then((value) => cargaOTs(_id));
                  setState(() {
                    cargaOTs(_id);
                  });
                },*/
                trailing: IconButton(
                  onPressed: (){}, 
                  icon: Icon(Icons.check_circle_rounded, size: iconSize,), 
                  color: Colors.green, 
                )
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                        child: Text("• "+listOTEnviados[i].descriptionOfIssue, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                        child: Text('• Trabajo: ${listOTEnviados[i].scopeOfWork}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                        child: Text('• Nota: ${listOTEnviados[i].notes}', style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: fontSize),),
                      ),
                    ],
                  ),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                            return Mapaflutter(LatLng(double.parse(listOTEnviados[i].locationY), double.parse(listOTEnviados[i].locationX)), 18.0);
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.map_rounded,  color: const Color.fromRGBO(0, 34, 61, 1),size: iconSize,),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return ShowArchivoOT(id: int.parse(listOTEnviados[i].id), code: listOTEnviados[i].code,);
                            },
                          ),
                        );
                    },
                    icon: Icon(Icons.perm_media_outlined, color: const Color.fromRGBO(0, 34, 61, 1), size: iconSize,),
                  ),
                  Text(listOTEnviados[i].countArchivos),
                  /*TextButton(
                    onPressed: () {
                      // Perform some action
                    },
                    child: const Text('ACTION 2'),
                  ),*/
                ],
              ),
            ],
          ),
        );
      }          
    );
  }
}
