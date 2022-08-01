// ignore_for_file: file_names

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:video_player/video_player.dart';


class ShowArchivoOT extends StatefulWidget {
  final int id;
  final String code;
  const ShowArchivoOT({Key? key, required this.id, required this.code}) : super(key: key);
  
  @override
  _ShowArchivoOTState createState() {
    return _ShowArchivoOTState();
  }
}

class _ShowArchivoOTState extends State<ShowArchivoOT> {
  late VideoPlayerController _videoPlayerController;
  bool img = true;
  Future _initVideoPlayer( filePath ) async {
    _videoPlayerController = VideoPlayerController.file(File(filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  Future _pauseVideoPlayer( filePath ) async {
    _videoPlayerController = VideoPlayerController.file(File(filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(false);
    await _videoPlayerController.pause();
  }

  List listArchivos = [];
  List listArchivosAux = [];
  @override
  void initState() {
    getArchivosOT();
    super.initState();
  }

  @override
  void dispose() {
    if (listArchivosAux.isEmpty) {
      
    }
    _videoPlayerController.dispose();
    super.dispose();
  }

  getArchivosOT()async{
    listArchivosAux = await BD.getArchivosOTShow(widget.id);
    setState(() {
      listArchivos = listArchivosAux;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.code),
        centerTitle: true,
        backgroundColor:  Colors.white,
        foregroundColor: const Color.fromRGBO(0, 34, 61, 1),
      ),
      body: ListView(
        children: listArchivos.map((e) => 
        Padding(
              padding: const EdgeInsets.fromLTRB(50, 8, 50, 8),
              child: Container(
                color: Colors.black38,
                height: 250,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    InkWell(
                      child: ( (e["c_ruta"]).toString().substring((e["c_ruta"]).toString().lastIndexOf('.')) == ".jpg") ? 
                      Image.file(
                        File(e["c_ruta"],), 
                        fit: BoxFit.fill,
                        height: double.infinity,
                        width: double.infinity,
                      ) : SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child:  Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            FutureBuilder(
                              future: _pauseVideoPlayer(e["c_ruta"]),
                              builder: (context, state) {
                                if (state.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else {
                                  return VideoPlayer(_videoPlayerController);
                                }
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 32),
                              child: Icon(Icons.play_circle_outline_rounded , size: 72,),
                            )
                          ],
                        ), 
                      ),
                      onTap: (){
                        showDialog(
                          context: context, 
                          builder: (BuildContext context){
                            String cad = (e["c_ruta"]).toString();
                            String ext = cad.substring(cad.lastIndexOf('.'));
                            print(ext);
                            if (ext == ".jpg") {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Image.file(File(e["c_ruta"]),fit: BoxFit.fill,
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                                  ),
                                  
                                ],
                              );
                            }
                            else if (ext == ".mp4"){
                              return FutureBuilder(
                                future: _initVideoPlayer(e["c_ruta"]),
                                builder: (context, state) {
                                  if (state.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: VideoPlayer(_videoPlayerController),
                                    );
                                  }
                                },
                              );
                            }
                            else {
                              return Container();
                            }
                          },
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Color.fromRGBO(0, 0, 0, 0.77),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(e["c_fecha"], style: TextStyle(color: Colors.white),),
                            )
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
        ).toList(),
      ),        
      
      /*floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.send_rounded, color: Color.fromRGBO(44, 240, 233, 1),),
        onPressed: () async {
          bool result = await internetConnectivity();
          if (result) {
            print("Envia");
          } else {
            print(result);
            alertNotifyException(context, 'Sin conexión');
          }
          
        },
        heroTag: null,
        backgroundColor:const Color.fromRGBO(0, 34, 61, 1),
      ),*/
    );
  }
}
