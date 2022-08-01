
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/login/theme_state.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:provider/provider.dart';



class Drawers extends StatefulWidget {
  const Drawers({Key? key}) : super(key: key);
  
  @override
  State<Drawers> createState() => _DrawersState();
}
int _selectedDrawerItem = 2;
var fontSize = 18.0; //14
var iconSize = 30.0; //24
class _DrawersState extends State<Drawers> {

  final padding = const EdgeInsets.symmetric(horizontal: 20);
  
   _onSelectedItem(int pos){ 
     setState(() {
       _selectedDrawerItem = pos;
     });   
   }
      
  @override
  Widget build(BuildContext context) {
    return Material(
            //color: Color.fromRGBO(66, 66, 66, 1),            
            child: ListView(              
              padding: padding,              
              children:  <Widget>[
                const DrawerHeader(
                  /*decoration: BoxDecoration(
                    color: Color.fromRGBO(44, 240, 233, 1),                  
                  ),*/
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      //color: Colors.white,
                      fontSize: 26,
                    ),
                  ),                
                ),
                ListTile(                  
                  leading: Icon(Icons.message_outlined, size: iconSize, ),
                  title: Text('Bandeja de OT', style: TextStyle(fontSize: fontSize,)),
                  selected: (1 == _selectedDrawerItem),                  
                  selectedColor: const Color.fromRGBO(0, 34, 61, 1),
                  selectedTileColor: const Color.fromRGBO(44, 240, 233, 0.6),          
                  onTap: () {                    
                    _onSelectedItem(1);
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, Routes.HOME);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map_outlined, size: iconSize,),
                  title: Text('Mapa',style: TextStyle(fontSize: fontSize),),
                  selected: (2 == _selectedDrawerItem), 
                  selectedColor: const Color.fromRGBO(0, 34, 61, 1),
                  selectedTileColor: const Color.fromRGBO(44, 240, 233, 0.6), 
                  onTap: () {
                    _onSelectedItem(2);
                    Navigator.of(context);
                    //Navigator.pushReplacementNamed(context, Routes.MAPA);
                    Navigator.pushReplacementNamed(context, Routes.MAPAFLUTTER);
                  },
                ),
                /*ListTile(
                  leading: const Icon(Icons.upload_file_outlined/*, color: Colors.white,*/),
                  title: const Text('Archivos'/*, style: const TextStyle(color: Colors.white),*/),
                  selected: (3 == _selectedDrawerItem),  
                  selectedColor: const Color.fromRGBO(0, 34, 61, 1),
                  selectedTileColor: const Color.fromRGBO(44, 240, 233, 0.6), 
                  onTap: () {
                    _onSelectedItem(3);
                    Navigator.of(context);
                    Navigator.pushReplacementNamed(context, Routes.ENVIAR_ARCHIVOS);
                  },
                ), */  
                /*Consumer<ThemeState>(
                  builder: (context, state, child){
                    return ListTile(
                      leading: state.isDrakModeEnabled ?  const Icon(Icons.wb_sunny_outlined ) : const Icon(Icons.dark_mode_outlined),
                      title: state.isDrakModeEnabled ? const Text('Tema Claro') : const Text('Tema Oscuro'),
                      selectedColor: Color.fromRGBO(44, 240, 233, 1),  
                      onTap: () {
                        //print(state.isDrakModeEnabled);
                        state.setDarkMode(!state.isDrakModeEnabled);
                        //Navigator.pushReplacementNamed(context, Routes.LOGIN);
                      },
                    );
                  },
                  
                ),   */        

                //const SizedBox(height: 15,),
                const Divider(/*color: Colors.white,*/),

                ListTile(
                  leading: Icon(Icons.close_outlined, size: iconSize,),
                  title: Text('Salir', style: TextStyle(fontSize: fontSize),),
                  onTap: () {
                    BackgroundLocation.stopLocationService();
                    _onSelectedItem(2);
                    Navigator.of(context);
                    Navigator.pushReplacementNamed(context, Routes.LOGIN);
                  },
                ),

                
              ],
            ),
          );
  }
}