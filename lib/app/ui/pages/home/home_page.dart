import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/ui/pages/home/home_controller.dart';
import 'package:flutter_application_1/app/ui/routes/routes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _actualPage = 0;
  final List<Widget> _paginas =[
    const PaginaHome(),
    const PaginaMapa(),
    const Camera(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create: (_)=> HomeController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Inicio"),
        ),
        body: _paginas[_actualPage],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index){
            setState(() {
              _actualPage = index;
            });
          },
          currentIndex: _actualPage,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Mapa"),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Camara"),
          ],
        ),
        floatingActionButton: buildShareButton(),
      ),      
    );
  }
  Widget buildShareButton()=> FloatingActionButton.extended(
        label:const Text('Share'),
        icon:const Icon(Icons.share),
        backgroundColor: Colors.blue,
        onPressed: (){
          print("Shared");
        },
      );
}

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {

  File? img;
  final picker = ImagePicker();

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

  opciones(context){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    selImagen(1);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Tomar una foto', style: TextStyle(
                            fontSize: 16
                          ),),                          
                        ),
                        Icon(Icons.camera_alt, color: Colors.blue,)
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    selImagen(2);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),                    
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Selecionar una foto', style: TextStyle(
                            fontSize: 16
                          ),),                          
                        ),
                        Icon(Icons.image, color: Colors.blue,)
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),   
                    decoration: BoxDecoration(
                      color: Colors.blue
                    ),                 
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('OK', style: TextStyle(
                              fontSize: 16,
                              color: Colors.white
                            ),
                            textAlign: TextAlign.center,
                          ),                          
                        ),
                        //Icon(Icons.image, color: Colors.blue,)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
          children: [
            Padding(
              padding:const EdgeInsets.all(20),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: (){
                      opciones(context);
                    }, 
                    child:const Text('Selecione una imagen'),
                  ),
                  RaisedButton(
                    onPressed: (){
                      Navigator.pushReplacementNamed(context, Routes.VIDEO);
                    },
                    child: Text('Video'),
                  ),
                  RaisedButton(
                    onPressed: (){
                      Navigator.pushReplacementNamed(context, Routes.ANIMACION);
                    },
                    child: Text('Img Animacion'),
                  ),
                  SizedBox(height: 30,),
                  img == null ? const Center(): Image.file(img!)
                ],
              ),
            ),
          ],
        );
  }
}


class PaginaHome extends StatefulWidget {
  const PaginaHome({Key? key}) : super(key: key);

  @override
  State<PaginaHome> createState() => _PaginaHomeState();
}

class _PaginaHomeState extends State<PaginaHome> {

  double _width = 100.0;
  double _height = 100.0;
  Color _color = Colors.blue;
  BorderRadius  _borderRadius = BorderRadius.circular(10);
  int _i = 1;

  void _cambiarContainer(){

    final random = Random();
      _width = (100 + random.nextInt(150).toDouble());
      _height = (100 + random.nextInt(150).toDouble());
      _color = Color.fromRGBO(random.nextInt(200), random.nextInt(200), random.nextInt(200), 1);
      _borderRadius = BorderRadius.circular(random.nextInt(20).toDouble());
      setState(() {
      });
  }
  final form = GlobalKey<FormState>();
  var  _lista = ['opcion1', 'opcion2', 'opcion3'];
  String _vista = 'Selecione';
  String _input = '';
  String _number = '';
  String _area = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        Expanded(
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              width: _width,
              height: _height,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: _borderRadius
              ),
              child: const Center(
                child: Text("Home",style: TextStyle(fontSize: 30, color: Colors.white),),
              ),
            )
          ),
        ),
        RaisedButton(
          onPressed: () {
            //do {
              form.currentState?.save();
              print(_vista);
              print(_input);
              print(_number);
              print(_area);
              _cambiarContainer();              
              
              //sleep(const Duration(milliseconds: 500));
              //print(_i);
              //_i++;
            //} while (_i <=10);
            
          },
          child: const Text("+")
        ),
        Center(
          child: DropdownButton(
            items: _lista.map((String _lista){
              return DropdownMenuItem(
                value: _lista,
                child: Text(_lista),
                );
            }).toList(),            
            onChanged: <String>(newValue){
              setState((){
                //print(newValue);
                _vista = newValue;
              });
            },
            hint: Text(_vista),
          ),
        ),
        Form(
          key: form,  
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child:  TextFormField(
                    onSaved: (value) {
                      _input =  value!;
                    },                    
                    decoration: const InputDecoration(
                      hintText: "Text",
                      fillColor: Colors.white,
                      filled: true
                    ),
                  ),
                ),      
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child:  TextFormField(                    
                    onSaved: (value) {
                      _number =  value!;
                    },                    
                    decoration: const InputDecoration(
                      hintText: "Text Number",
                      fillColor: Colors.white,
                      filled: true
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),   
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child:  TextFormField(                    
                    onSaved: (value) {
                      _area =  value!;
                    },                    
                    decoration: const InputDecoration(
                      hintText: "Text Area",
                      fillColor: Colors.white,
                      filled: true
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 2,
                    maxLines: 5,
                  ),
                ),          
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PaginaMapa extends StatefulWidget {
  const PaginaMapa({Key? key}) : super(key: key);

  @override
  State<PaginaMapa> createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeController>(
      create: (_)=> HomeController(),
      child: Scaffold(        
        body: Consumer<HomeController>(
          builder: (_, controller, __)=> GoogleMap(
            markers: controller.markers,
            onMapCreated: controller.onMapCreated,
            initialCameraPosition: controller.initialCameraPosition,
            onTap: controller.onTap,
            myLocationButtonEnabled: true,            
            myLocationEnabled: true,            
            //mapType: MapType.satellite,
          ),          
        ),
      ),
    );
  }
  initposition() async {    
    final initposition = await Geolocator.getCurrentPosition();
    print(initposition);
    return true;
  }
}