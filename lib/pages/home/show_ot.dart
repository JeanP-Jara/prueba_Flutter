import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:md5_file_checksum/md5_file_checksum.dart';
import 'package:path_provider/path_provider.dart';

class OpenContainerTransformDemo extends StatefulWidget {
  
  const OpenContainerTransformDemo({Key? key}) : super(key: key);
  
  @override
  _OpenContainerTransformDemoState createState() {
    return _OpenContainerTransformDemoState();
  }
}

String _priority = '';
String _assetType = '';
String _descriptionOfIssue = '';
String _scopeOfWork = '';
String _notes = '';
String _assetId = '';
String _send = '';
String _code = '';
String _id = '';
String _comentario = '';
String _completionAction = '';
bool estadoIcon = false;

class OT{
  static Future showOT(id, priority, assetType, descriptionOfIssue, scopeOfWork, notes, assetId, send, code, comentario, completionAction ) async {
    _priority = priority;
    _assetType = assetType;
    _descriptionOfIssue = descriptionOfIssue;
    _scopeOfWork = scopeOfWork;    
    _notes = notes;    
    _assetId = assetId;
    _send = send;
    _code = code;
    _id = id;
    _comentario = comentario;
    _completionAction = completionAction;
  }
}

class _OpenContainerTransformDemoState extends State<OpenContainerTransformDemo> {
  File? img;
  File? video;
  
  final  _actionList = ['Servicio pendiente de programación', 'Servicio cerrado', 'Servicio pendiente de reprogramación'];
  String _action = 'Acción';
  
  int _action_id = 3;

  final form = GlobalKey<FormState>();

  final picker = ImagePicker();

  Future setArchivo(bool archivoOp, int op) async {
    XFile? pickedFile;
    bool val = false;
    String msn = "";

    if(archivoOp){
      if(op == 1){      
        pickedFile = await picker.pickImage(source: ImageSource.camera);    
        img = File(pickedFile!.path);  
      }else{
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
        img = File(pickedFile!.path);  
      }

      if (pickedFile != null) {

        final fileChecksum = await Md5FileChecksum.getFileChecksum(filePath: pickedFile.path);
        print("fileChecksum: $fileChecksum");

        final Directory extDir = await getApplicationDocumentsDirectory();
        String dirPath = extDir.path;

        final String filePath = '$dirPath/$fileChecksum.jpg';

        try {
          final File newImage = await img!.copy(filePath);
          msn = "Foto Cargado.";
          val = true;
        } catch (e) {
          print("Error: $e");
          msn = "Error al cargar foto. Intente de nuevo.";
        }

        if (val) {
          final File newImage = await img!.copy(filePath);
          DateTime date = DateTime.now();
          BD.insertArchivo(int.parse(_id), fileChecksum, newImage.path, date.toString());
          setState(() {
            if(pickedFile != null){
              img = File(pickedFile.path);
            }else{
              print("VACIO- img");
            }
          });
        }
        showSnackBar(msn);
      }
      Navigator.of(context).pop();
    }else{
      if(op == 1){
        pickedFile = await picker.pickVideo(source: ImageSource.camera);
        video = File(pickedFile!.path);
      }else{
        pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      }

      if(pickedFile != null){

        var fileChecksum = await Md5FileChecksum.getFileChecksum(filePath: pickedFile.path);
        print("fileChecksum: $fileChecksum");

        final Directory extDir = await getApplicationDocumentsDirectory();
        String dirPath = extDir.path;

        final String filePath = '$dirPath/$fileChecksum.mp4';

        try {
          final File newVideo = await video!.copy(filePath);
          msn = "Video cargado";
          val = true;
        } catch (e) {
          print(e);
          msn = "Error al cargar video. Intente nuevamente";
        }

        if (val) {
          final File newVideo = await video!.copy(filePath);
          
          DateTime date = DateTime.now();
          BD.insertArchivo(int.parse(_id), fileChecksum, newVideo.path, date.toString());
        }
        showSnackBar(msn);
      }
      Navigator.of(context).pop();
    }
    
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

  checksum(path)async {
    final fileChecksum = await Md5FileChecksum.getFileChecksum(filePath: path);
    print("fileChecksum: ${fileChecksum.toString()}");
  }

  @override
  void initState() {
    print(_comentario);
    if (_send == '1') {
      estadoIcon = true;
    }else{
      estadoIcon = false;
    }
    print("_completionAction:  "+_completionAction);
    if (_completionAction == '0') {
      _action = _actionList[0];
    }else if(_completionAction == '1'){
      _action = _actionList[1];
    }else if(_completionAction == '2'){
      _action = _actionList[2];
    }
    print(_assetId);
    print(_id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulario OT"),
        centerTitle: true,
        backgroundColor:  Colors.white,
        foregroundColor: const Color.fromRGBO(0, 34, 61, 1),
        actions: [
          IconButton(
            onPressed: (){
              getOptionArchivo(true);
            }, 
            icon: const Icon(Icons.camera_enhance_rounded),
          ),
          IconButton(
            onPressed: (){
              getOptionArchivo(false);
            }, 
            icon: const Icon(Icons.video_call_rounded),
          ),
        ],
        //backgroundColor: Color.fromRGBO( 27, 27, 27, 1),
      ),
      body: ListView(
        children: [    
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  title: Text(_assetType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Código: $_code'),
                      Text('Descripción: $_descriptionOfIssue'),
                    ],
                  ),
                  trailing: estadoIcon ? 
                    IconButton(
                      onPressed: (){}, 
                      icon: const Icon(Icons.check_circle_rounded), 
                      color: Colors.green, 
                      
                    ) :
                    IconButton(
                      icon: const Icon(Icons.highlight_off_rounded), 
                      color: Colors.red, 
                      onPressed: (){}, 
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trabajo: $_scopeOfWork',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 2,),
                      Text('Nota: $_notes',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 2,),
                      Text('Prioridad: $_priority',
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: Colors.black54),
                      ),
                      /*const SizedBox(height: 10,),
                      Switch(value: false, onChanged: (selected){})*/
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              elevation: 2,
              child: Column(
                children: [
                  Center(
                    child: DropdownButton(
                      items: _actionList.map((String _lista){
                        return DropdownMenuItem(
                          value: _lista,
                          child: Text(_lista),
                        );
                      }).toList(),            
                      onChanged: <String>(newValue){
                        if (newValue == 'Servicio pendiente de programación') {
                          _action_id = 0;
                        } else if(newValue ==  'Servicio cerrado') {
                          _action_id = 1;
                        }else if(newValue ==  'Servicio pendiente de reprogramación'){
                          _action_id = 2;
                        }
                        setState((){
                          //print(newValue);
                          _action = newValue;
                        });
                      },
                      hint: Text(_action, /*style: TextStyle(color: Colors.white,)*/),     
                      //dropdownColor: Color.fromRGBO( 27, 27, 27, 1),                       
                      //style: TextStyle(color: Colors.white,),
                      
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Form(
                    key: form,  
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [                 
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),                          
                            decoration: BoxDecoration(
                                border: Border.all(color: const Color.fromRGBO(0, 34, 61, 1), ),
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child:Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),                    
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                initialValue: _comentario,
                                decoration: const InputDecoration(  
                                  hintText: 'Comentario',
                                  focusedBorder: InputBorder.none,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      //color: Colors.white70
                                  )
                                ),
                                keyboardType: TextInputType.multiline,
                                minLines: 2,
                                maxLines: 15,
                                style: const TextStyle(fontSize: 16,
                                    /*color: Colors.white*/),
                                onSaved: (value) {
                                  _comentario =  value!;
                                }
                              )
                            ), 
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: img == null ? const Center(): Image.file(img!),
                            //child: /*img == null ? const Center():*/ Image.file(File("/data/user/0/com.example.flutter_application/app_flutter/zaBW12nFav9na01F9DD10A==.jpg")),
                          ),
                        ],
                      ),
                    ),
                  ), 
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save_rounded, color: Color.fromRGBO(44, 240, 233, 1),),
        onPressed: () async {
          form.currentState?.save();
          if (_action_id > 2 ) {
            showSnackBar("Selecione una Acción");
          }else{
            int result = await BD.updateOt(int.parse(_id), _action_id, _comentario);
            if (result != 0) {
              showSnackBar("OT Guardado");
            }else{
              showSnackBar("Error al Guardar");
            }
          }
        },
        heroTag: null,
        backgroundColor:const Color.fromRGBO(0, 34, 61, 1),
      ),
    );
  }

  getOptionArchivo(bool archivoOp){
    return showDialog(
      barrierColor: const Color.fromRGBO(14, 106, 142 , 0.7),
      context: context, 
      builder:(BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Cámara"),
                    Icon(Icons.camera_alt_rounded),
                  ],
                ),
                onTap: () => setArchivo(archivoOp , 1),
              ),
              const Divider(height: 24,),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Galería"),
                    Icon(Icons.image_rounded),
                  ],
                ),
                onTap: () => setArchivo(archivoOp, 2),
              ),                        
            ],
          ),
        );
      }
    );
  }
}
