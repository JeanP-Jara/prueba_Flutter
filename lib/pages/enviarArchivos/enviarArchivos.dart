import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/pages/enviarArchivos/showArchivosOT.dart';
import 'package:flutter_application/pages/home/drawer.dart';
import 'package:flutter_application/pages/validacion/connectivity.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:http_parser/http_parser.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';



class FormOT extends StatefulWidget {
  const FormOT({Key? key}) : super(key: key);

  @override
  State<FormOT> createState() => _FormOTState();
}

class _FormOTState extends State<FormOT> {

  File? img;
  bool estadoIcon = false;
  final  _lista = ['opcion1', 'opcion2', 'opcion3'];
  String _vista = 'Tipo de OT';

  final form = GlobalKey<FormState>();

  final picker = ImagePicker();

  List listArchOT = [];
  List listArchOTAux = [];

  Future selImagen(op) async{
    var pickedFile;
    if(op == 1){
      pickedFile = await picker.getImage(source: ImageSource.camera);
    }else{
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    }

    setState(() {
      if(pickedFile != null){
        img = File(pickedFile.path);
      }else{
        print("VACIO- img");
      }
    });
  }

  @override
  void initState() {
    getArchivosOt();
    super.initState();
  }

  getArchivosOt() async {
    listArchOTAux = await BD.getDataArchivosOT();
    setState(() {
      listArchOT = listArchOTAux;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        //backgroundColor: Color.fromRGBO(66, 66, 66, 1),
        appBar: AppBar(
          title: const Text("Archivos OT"),
          centerTitle: true,
          backgroundColor: const Color.fromRGBO(44, 240, 233, 1),
          foregroundColor: const Color.fromRGBO(0, 34, 61, 1),
          /*actions: [
            Container(
              width: 100,
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  InkWell(
                    onTap: (){
                      selImagen(1);
                    },
                    child: const Icon(Icons.camera_enhance_rounded),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.pushReplacementNamed(context, Routes.VIDEO);
                    },
                    child: const Icon(Icons.video_call_rounded),
                  )
                ],
              ),
            ),
          ],*/
          //backgroundColor: Color.fromRGBO( 27, 27, 27, 1),
        ),
        drawer: const Drawer(child: Drawers(),),
        body: Column(
          children: listArchOT.map((e) => 
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(left: BorderSide(color: Color.fromRGBO(0, 34, 61, 1), width: 5)),
                      //borderRadius: BorderRadius.circular(15)
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.upload_file_outlined, color: Color.fromRGBO(44, 240, 233, 1)),
                        backgroundColor: Color.fromRGBO(0, 34, 61, 1),
                      ),
                      title: Text(e["code"]),
                      subtitle: Text("N° de archivos: "+(e["count(ar.id_workordersbyuser)"]).toString()),
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return ShowArchivoOT(id: e["id"], code: e["code"],);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ),
        /*floatingActionButton: Mutation(
          options: MutationOptions(
            document: gql(sentArchivos), 
            onCompleted: (dynamic resultData) {
              print(resultData);
            },
          ),
          builder: (RunMutation runMutation, QueryResult? result) {
            return FloatingActionButton(
              
              onPressed: () async {
                bool result = await internetConnectivity();
                if (result) {
                  for (var i in listArchOT) {
                    print(i['asset_id']);
                    print(i['completion_id']);
                    var getArchivosOT = await BD.getArchivosOT(i['asset_id']);
                    
                    for (var item in getArchivosOT) {
                      //print(item.toString());
                      print(item['c_ruta']);
                      var byteData = File(item['c_ruta']).readAsBytesSync();
                      var multipartFile = MultipartFile.fromBytes(
                        'video',
                        byteData,
                        filename: '${DateTime.now().second}.mp4',
                        contentType: MediaType("video", "mp4"),
                      );
                      //final file = await File(item['c_ruta']);
                      runMutation(
                        {
                          "files": multipartFile,
                          "comletionId": i['completion_id'],
                        }
                      );
                    }
                    
                  }     
                }else{
                  alertNotifyException(context, 'Sin conexión');
                }
              }, 

              /*icon*/ child: const Icon(Icons.send_rounded,color: Color.fromRGBO(44, 240, 233, 1), ),
              /*label: const Text(
                "Sinc. OT",
                style: TextStyle(
                  color: Color.fromRGBO(44, 240, 233, 1), 
                ),
              ),*/
              backgroundColor: const Color.fromRGBO(0, 34, 61, 1)
            );
          },
        ),*/
      ),
    );
  }
  
}