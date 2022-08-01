import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/bd/ordenTrabajo.dart';
import 'package:flutter_application/pages/home/show_ot.dart';
import 'package:flutter_map/flutter_map.dart';

class PopupMapaFlutter extends StatefulWidget {
  final Marker marker;

  const PopupMapaFlutter(this.marker, {Key? key}) : super(key: key);
  
  @override
  State<PopupMapaFlutter> createState() => _PopupMapaFlutterState(marker);
}

class _PopupMapaFlutterState extends State<PopupMapaFlutter> {
  final Marker _marker;

  final List<IconData> _icons = [
    Icons.star_border,
    Icons.star_half,
    Icons.star
  ];
  bool estadoIcon = false;
  _PopupMapaFlutterState(this._marker);

  OrdenTrabajo MarkerOT = OrdenTrabajo(id: '', code: '', scheduledAt: '', priority: '', assetId: '', assetType: '', descriptionOfIssue: '', scopeOfWork: '', locationX: '', locationY: '', notes: '', assignedToId: '', fullName: '', completionId: '', send: '', completionAction: '', comentario: '', countArchivos: '');
  @override
  void initState() {
    cargaOTs();
    super.initState();
  }
  cargaOTs() async {
    OrdenTrabajo auxMarkerOT = await BD.MarkerOT(_marker.point.latitude, _marker.point.longitude , int.parse(_marker.key.toString().replaceAll("[<'", "").replaceAll("'>]", "")));
    setState(() {
      MarkerOT = auxMarkerOT;
      print(MarkerOT.send);
      if(MarkerOT.send == '1'){
        estadoIcon = true;
      }
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3.0,
      clipBehavior: Clip.hardEdge,
      child: _cardDescription(context),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(17),
          child: Container(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      MarkerOT.code,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: estadoIcon ? 
                      const Icon(
                        Icons.check_circle_rounded, 
                        color: Colors.blue,
                      ) : const Icon(
                        Icons.highlight_off_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 40,
                  thickness: 2,
                  color: Color.fromRGBO(44, 240, 233, 1),
                  indent: 5,
                  endIndent: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text(
                        'Trabajo: ${MarkerOT.scopeOfWork}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      const SizedBox( height: 5,),
                      Text(
                        'Descripción: ${MarkerOT.descriptionOfIssue}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                      /*SizedBox( height: 5,),
                      Text(
                        'Nota: ${MarkerOT.notes}',
                        style: const TextStyle(fontSize: 12.0),
                      ),*/
                      const SizedBox( height: 5,),
                      Text(
                        'Prioridad: ${MarkerOT.priority}',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
                
                /*Text(
                  'Position: ${MarkerOT.locationX}, ${MarkerOT.locationY}',
                  style: const TextStyle(fontSize: 12.0),
                ),*/
                const SizedBox(height: 15),     
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),)
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(44, 240, 233, 1),
                        ),
                      ),
                      onPressed: (){
                        print("object");
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              OT.showOT(MarkerOT.id, MarkerOT.priority, MarkerOT.assetType, MarkerOT.descriptionOfIssue, MarkerOT.scopeOfWork, MarkerOT.notes, MarkerOT.assetId, MarkerOT.send, MarkerOT.code, MarkerOT.comentario, MarkerOT.completionAction);
                              return const OpenContainerTransformDemo();
                            },
                          ),
                        );
                      },                         
                      child:const Text('ATENDER'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}