import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/pages/home/drawer.dart';
import 'package:flutter_application/pages/mapa/popup_mapa_flutter.dart';
import 'package:flutter_application/pages/validacion/show_alert.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:latlong2/latlong.dart";
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class Mapaflutter extends StatefulWidget {
  final LatLng latLng;
  final double zoom;
  const Mapaflutter(this.latLng, this.zoom,{ Key? key}) : super(key: key);
  
  @override
  State<Mapaflutter> createState() => _MapaflutterState(latLng, zoom);
}

class _MapaflutterState extends State<Mapaflutter> {
  final LatLng _latLng;
  final double _zoom;
  _MapaflutterState(this._latLng, this._zoom);
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late StreamController<double> _centerCurrentLocationStreamController;
  final PopupController _popupLayerController = PopupController();
  FloatingSearchBarController controllerSearch = FloatingSearchBarController();
  MapController _mapController = MapController();
  
  List<Marker> _listMrkersOT = [];
  List<Marker> _listPuntos = [];

  List<String> filteredSearch = [];

  String selectedTerm='Buscar';
  
  bool showListLayer = true;
  bool showLayerAT = true;
  bool showLayerMT = true;
  bool showLayerBT = true;
  bool showLayerAP = true;
  bool showPoints = true;
  bool showOT = true;

  bool showLayerATAux = true;
  bool showLayerMTAux = true;
  bool showLayerBTAux = true;
  bool showLayerAPAux = true;
  bool showPointsAux = true;

  bool valueEstruct = false;
  bool valueSubEst = false;
  bool valueOT = true;
  bool valueLLV = false;
  bool valuePAP = false;
  bool valuePCR = false;
  bool valuePSP = false;
  bool valueSED = false;

  bool vertt = false;
  bool onTapLayer = false;
  bool onTapLayerFloating = false;
  List<Polyline> polyLineList=[];

  @override
  void initState() {
    getMarkers();
    getPuntos();
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.never;
    _centerCurrentLocationStreamController = StreamController<double>();
    controllerSearch = FloatingSearchBarController();
    _mapController = MapController();
    vertt = true;

  }
  getMarkers()async{
    List<Marker> AuxlistMrkers = await BD.ListMArkerOTs();
    setState(() {
      _listMrkersOT = AuxlistMrkers;
    });
    print(_listMrkersOT.length);
  }
  getPuntos() async {
    List<Marker> AuxlistPuntos = await BD.ListPuntos();
    setState(() {
      _listPuntos = AuxlistPuntos;
    });
  }

  @override
  void dispose() {
    _centerCurrentLocationStreamController.close();
    controllerSearch.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
          title: const Text("Mapa"),
          centerTitle: true,
      ),  */   
      drawer: const Drawer(child: Drawers(),),
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              //center: LatLng(-9.2437871,-74.6387234),
              center: LatLng(_latLng.latitude, _latLng.longitude),
              zoom: _zoom,
              maxZoom: 18.4,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  //print("onPositionChanged");
                  setState(
                    () => _centerOnLocationUpdate = CenterOnLocationUpdate.never,
                  );
                }
              },
              onTap: (_, __) {
                _popupLayerController.hideAllPopups();
                setState(() {
                  //showLayer1 = true;
                  //showPoints = true;
                  vertt = true;
                  if (onTapLayer) {
                    onTapLayer = false;
                    if (!onTapLayerFloating) {
                      showListLayer = true;
                    }
                    showLayerAT = showLayerATAux;
                    showLayerMT = showLayerMTAux;
                    showLayerBT = showLayerBTAux;
                    showLayerAP = showLayerAPAux;
                    showPoints = showPointsAux;
                  }
                  
                });
              },
              plugins: [
                //LocationPlugin(),
                MarkerClusterPlugin(),
                const LocationMarkerPlugin(),
              ]
            ),
            children: [
              TileLayerWidget(
                options: TileLayerOptions(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                  //tileProvider: const CachedTileProvider(),
                  //maxZoom: 20,
                ),
              ),
              LocationMarkerLayerWidget(
                plugin: LocationMarkerPlugin(
                  centerCurrentLocationStream:
                      _centerCurrentLocationStreamController.stream,
                  centerOnLocationUpdate: _centerOnLocationUpdate,
                ),
              ),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  popupController: _popupLayerController,
                  markers: vertt ? []: _listMrkersOT,
                  markerRotateAlignment: PopupMarkerLayerOptions.rotationAlignmentFor(AnchorAlign.top),
                  popupBuilder: (BuildContext ctxt, Marker marker) =>
                      PopupMapaFlutter(marker),
                ),
              ),
              
            ],
            layers: vertt ? [
              TileLayerOptions(
                wmsOptions:  WMSTileLayerOptions(
                  baseUrl: 'http://lb-visor-927781765.us-east-2.elb.amazonaws.com/geoserver/espace/wms?',
                  version: '1.3.0',
                  layers: ['pouer_cond_at'],
                  format: 'image/png',
                  //crs: const Epsg4326(),
                  otherParameters: {
                    'TILED' : 'true',
                    'FORMAT_OPTIONS': 'antialias:off',
                    //'serverType': 'geoserver',
                  },
                ),
                backgroundColor: Colors.transparent,
                opacity: showLayerAT ? 1.0 : 0.0,
                fastReplace: true,
              ),
              TileLayerOptions(
                wmsOptions:  WMSTileLayerOptions(
                  baseUrl: 'http://lb-visor-927781765.us-east-2.elb.amazonaws.com/geoserver/espace/wms?',
                  version: '1.3.0',
                  layers: ['pouer_cond_mt'],
                  format: 'image/png',
                  //crs: const Epsg4326(),
                  otherParameters: {
                    'TILED' : 'true',
                    'FORMAT_OPTIONS': 'antialias:off',
                    //'serverType': 'geoserver',
                  },
                ),
                backgroundColor: Colors.transparent,
                opacity: showLayerMT ? 1.0 : 0.0,
                fastReplace: true,
              ),
              TileLayerOptions(
                wmsOptions:  WMSTileLayerOptions(
                  baseUrl: 'http://lb-visor-927781765.us-east-2.elb.amazonaws.com/geoserver/espace/wms?',
                  version: '1.3.0',
                  layers: ['pouer_cond_bt'],
                  format: 'image/png',
                  //crs: const Epsg4326(),
                  otherParameters: {
                    'TILED' : 'true',
                    'FORMAT_OPTIONS': 'antialias:off',
                    //'serverType': 'geoserver',
                  },
                ),
                backgroundColor: Colors.transparent,
                opacity: showLayerBT ? 1.0 : 0.0,
                fastReplace: true,
              ),
              TileLayerOptions(
                wmsOptions:  WMSTileLayerOptions(
                  baseUrl: 'http://lb-visor-927781765.us-east-2.elb.amazonaws.com/geoserver/espace/wms?',
                  version: '1.3.0',
                  layers: ['pouer_cond_ap'],
                  format: 'image/png',
                  //crs: const Epsg4326(),
                  otherParameters: {
                    'TILED' : 'true',
                    'FORMAT_OPTIONS': 'antialias:off',
                    //'serverType': 'geoserver',
                  },
                ),
                backgroundColor: Colors.transparent,
                opacity: showLayerAP ? 1.0 : 0.0,
                fastReplace: true,
              ),
              //orden de trabajos
              MarkerClusterLayerOptions(
                maxClusterRadius: 20,
                size: const Size(40, 40),
                fitBoundsOptions: const FitBoundsOptions(
                  padding: EdgeInsets.all(50),
                ),
                markers: showOT ? _listMrkersOT : [],
                polygonOptions: const PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 3),
                builder: (context, markers) {
                  return const Icon(Icons.location_on, color: Colors.black,)/*FloatingActionButton(
                    child: Text(markers.length.toString()),
                    onPressed: (){
                      //print("object");
                    },
                  )*/;
                },
                onMarkerTap: (marker){
                  print(marker.key.toString().replaceAll("[<'", "").replaceAll("'>]", ""));
                  setState(() {
                    _centerOnLocationUpdate = CenterOnLocationUpdate.never;
                    if(!onTapLayerFloating){
                      showLayerATAux = showLayerAT;
                      showLayerMTAux = showLayerMT;
                      showLayerBTAux = showLayerBT;
                      showLayerAPAux = showLayerAP;
                      showPointsAux = showPoints;
                      if(showLayerAT){ showLayerAT = false; }
                      if(showLayerMT){ showLayerMT = false; }
                      if(showLayerBT){ showLayerBT = false; }
                      if(showLayerAP){ showLayerAP = false; }
                      if(showPoints){ showPoints = false; }
                    }                    
                    vertt = false;
                    showListLayer = false;
                    onTapLayer = true;
                  });
                  _popupLayerController.togglePopup(marker);
                },
              ),
              MarkerClusterLayerOptions(
                disableClusteringAtZoom: 14,
                maxClusterRadius: 20,
                size: const Size(40, 40),
                fitBoundsOptions: const FitBoundsOptions(
                  padding: EdgeInsets.all(25),
                ),
                markers: showPoints ? _listPuntos : [],
                polygonOptions: const PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 3),
                builder: (context, markers) {
                  return FloatingActionButton(
                    child: Text(markers.length.toString(), style: const TextStyle(color: Colors.black),),
                    onPressed: (){
                      setState(() {
                        _centerOnLocationUpdate = CenterOnLocationUpdate.never;
                      });
                      var getZonn = _mapController.zoom;
                      getZonn+=2;
                      _mapController.move(
                        LatLng(markers.last.point.latitude,markers.last.point.longitude),
                        getZonn
                      );
                    },
                    backgroundColor: const Color.fromRGBO(255, 241, 27, 1),
                    heroTag: null,
                  );
                },
              ),
            ]: [],
            //BOTON
            nonRotatedChildren: [
                Positioned(
                  right: 20,
                  bottom: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.3,
                        child: SpeedDial(
                          /*overlayColor: const Color.fromRGBO(14, 106, 142 , 0.7),
                          icon: Icons.multiline_chart_rounded,
                          icon: Icons.map_rounded,*/
                          child: Icon(Icons.map_rounded, color: const Color.fromRGBO(44, 240, 233, 1), size: iconSize,),
                          activeIcon: Icons.close,
                          backgroundColor: const Color.fromRGBO(0, 34, 61, 1),
                          foregroundColor: const Color.fromRGBO(44, 240, 233, 1),
                          renderOverlay: false,
                          //isOpenOnStart: true,
                          //closeManually: true,
                          children: [
                            SpeedDialChild(
                              backgroundColor: const Color.fromRGBO(128, 142, 149, 1),
                              child: showListLayer ? const Icon(Icons.layers_clear_rounded, color: Color.fromRGBO(44, 240, 233, 1), ) : const Icon(Icons.layers_rounded, color: Color.fromRGBO(44, 240, 233, 1), ),
                              label: 'capas',
                              onTap: () {
                                _popupLayerController.hideAllPopups();
                                setState(() {
                                  if(showListLayer){                                  
                                    showLayerATAux = showLayerAT;
                                    showLayerMTAux = showLayerMT;
                                    showLayerBTAux = showLayerBT;
                                    showLayerAPAux = showLayerAP;
                                    showPointsAux = showPoints;
                                    if(showLayerAT){ showLayerAT = false; }
                                    if(showLayerMT){ showLayerMT = false; }
                                    if(showLayerBT){ showLayerBT = false; }
                                    if(showLayerAP){ showLayerAP = false; }
                                    if(showPoints){ showPoints = false; }
                                  }else{                                  
                                      showLayerAT = showLayerATAux;
                                      showLayerMT = showLayerMTAux;
                                      showLayerBT = showLayerBTAux;
                                      showLayerAP = showLayerAPAux;
                                      showPoints = showPointsAux;                                                                 
                                  }
                                  showListLayer = showListLayer ? false : true;
                                  onTapLayerFloating = !onTapLayerFloating;
                                });

                              },
                            ),
                            SpeedDialChild(
                              backgroundColor: const Color.fromRGBO(128, 142, 149, 1),
                              child:  const Icon(Icons.handyman_rounded, color: Color.fromRGBO(44, 240, 233, 1), ),
                              label: 'OT',
                              onTap: () {
                                _popupLayerController.hideAllPopups();
                                setState(() {
                                  showOT = showOT ? false : true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 25,),
                      Transform.scale(
                        scale: 1.3,
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(
                              () => _centerOnLocationUpdate = CenterOnLocationUpdate.always,
                            );
                            _centerCurrentLocationStreamController.add(16);
                          },
                          child: Icon(Icons.my_location, color: Color.fromRGBO(44, 240, 233, 1), size: iconSize,),
                          backgroundColor: const Color.fromRGBO(0, 34, 61, 1),                        
                          heroTag: null,
                        ),
                      )
                      
                      
                    ],
                  ),
                )
              ],
          ),

          //CAPA
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 100,),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: showListLayer ? Card(
                elevation: 4.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('AT', style: TextStyle(fontSize: fontSize,)),   
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            splashRadius: 40,
                            activeColor: const Color.fromRGBO(0, 129, 200, 1), 
                            value: showLayerAT, 
                            onChanged: (value){
                              setState(() {
                                showLayerAT = !showLayerAT;
                              });                    
                            } 
                          ),
                        ),                       
                        
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('MT', style: TextStyle(fontSize: fontSize),),          
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            splashRadius: 40,
                            activeColor: const Color.fromRGBO(244, 24, 24, 1), 
                            value: showLayerMT, 
                            onChanged: (value){
                              setState(() {
                                showLayerMT = !showLayerMT;
                              });                    
                            } 
                          ),
                        ),
                        
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('BT', style: TextStyle(fontSize: fontSize),),    
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            splashRadius: 40,
                            activeColor: const Color.fromRGBO(134, 219, 37, 1), 
                            value: showLayerBT, 
                            onChanged: (value){
                              setState(() {
                                showLayerBT = !showLayerBT;
                              });                    
                            } 
                          ),
                        )                      
                        
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('AP', style: TextStyle(fontSize: fontSize),),      
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            splashRadius: 40,
                            activeColor: const Color.fromRGBO(251, 118, 7, 1), 
                            value: showLayerAP, 
                            onChanged: (value){
                              setState(() {
                                showLayerAP = !showLayerAP;
                              });                    
                            } 
                          ),
                        )                    
                        
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 10,),
                        Text('Estructuras',style: TextStyle(fontSize: fontSize),),          
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            splashRadius: 40,
                            activeColor: const Color.fromRGBO(248, 218, 87, 1), 
                            checkColor: Colors.black,
                            value: showPoints, 
                            onChanged: (value){
                              setState(() {
                                showPoints = !showPoints;
                              });                    
                            } 
                          ),
                        )                
                        
                      ],
                    )
                  ],
                ),
            ) : Container(),
              ),]
          ),
          
          FloatingSearchBar(
            elevation: 4.0,
            controller: controllerSearch,
            hint: 'Buscar...',
            hintStyle: TextStyle(fontSize: fontSize),
            scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
            transitionDuration: const Duration(milliseconds: 800),
            transitionCurve: Curves.easeInOut,
            physics: const BouncingScrollPhysics(),
            axisAlignment: MediaQuery.of(context).orientation == Orientation.portrait ? 0.0 : -1.0,
            openAxisAlignment: 0.0,
            width: MediaQuery.of(context).orientation == Orientation.portrait ? 600 : 500,
            height: 54.0,
            debounceDelay: const Duration(milliseconds: 500),
            clearQueryOnClose: false,
            /*title: Text(
              selectedTerm,
              //style: Theme.of(context).textTheme.headline6,
            ),*/
            /*onFocusChanged: (b){
              setState(() {
                valueEstruct = false; valueSubEst = false; valueOT = false;
              });
            },*/
            onQueryChanged: (query) {
              if(query.length >= 2){
                getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
              }else{
                setState(() {
                  filteredSearch.clear();
                });
              }
            },
            onSubmitted: (query) {
              setState(() {
                _centerOnLocationUpdate = CenterOnLocationUpdate.never;
              });
              getBuscar(query, context);
              controllerSearch.close();
            },
            transition: CircularFloatingSearchBarTransition(),
            actions: [
              FloatingSearchBarAction.searchToClear(
                showIfClosed: true,
              ),
            ],
            builder: (context, transition) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  child: Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          const SizedBox(height: 10,),
                          options(controllerSearch.query),
                          const Divider(
                            height: 20,
                            indent: 15,
                            endIndent: 15,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: filteredSearch
                                .map(
                                  (term) => ListTile(
                                    title: Text(
                                      term,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: const Icon(Icons.search_rounded),
                                    /*trailing: IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          deleteSearchTerm(term);
                                        });
                                      },
                                    ),*/
                                    onTap: () {
                                      setState(() {
                                        selectedTerm = term;
                                        controllerSearch.query = selectedTerm;
                                        _centerOnLocationUpdate = CenterOnLocationUpdate.never;
                                      });
                                      getBuscar(controllerSearch.query, context);
                                      controllerSearch.close();
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ]
      ),
    );
  }

  getListOption(String query, bool valueEstruct, bool valueSubEst, bool valueOT, bool valueLLV, bool valuePAP, bool valuePCR, bool valuePSP, bool valueSED) async {
    List<String> listOptionBuscar = await BD.listOptionBuscar(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
    setState(() {
      filteredSearch = listOptionBuscar;
    });
  }
  
  getBuscar(query, context) async {
    LatLng _buscar = await BD.buscar(query);
    if (_buscar == LatLng(0.0,0.0)) {
      return alertNotifyException(context, 'No se encontro resultados');
    }else{
      _mapController.move(
        _buscar,
        18
      );
    }
    
  }

  Widget options(String query){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(              
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: const [
                    Icon(Icons.location_on, size: 14,),
                    SizedBox(width: 2,),
                    Text(
                      'Orden de Trabajo',
                      //style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = false;
                    valueOT = true;
                    valueLLV = false;
                    valuePAP = false;
                    valuePCR = false;
                    valuePSP = false;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valueOT ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: const Text(
                  'Estructura',
                  //style: TextStyle(fontSize: 12),
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = true;
                    valueSubEst = false;
                    valueOT = false;
                    valueLLV = false;
                    valuePAP = false;
                    valuePCR = false;
                    valuePSP = false;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valueEstruct ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: [
                    SvgPicture.asset("assets/mapa/SED.svg", width: 10, height: 10,),
                    const SizedBox(width: 4,),
                    const Text(
                      'SED',
                      //style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = false;
                    valueOT = false;
                    valueLLV = false;
                    valuePAP = false;
                    valuePCR = false;
                    valuePSP = false;
                    valueSED = true;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valueSED ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            /*Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: const Text(
                  'Subestación',
                  //style: TextStyle(fontSize: 12),
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = true;
                    valueOT = false;
                    valueLLV = false;
                    valuePAP = false;
                    valuePCR = false;
                    valuePSP = false;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valueSubEst ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),*/
          ],
        ),
        const SizedBox(height: 7,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(              
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: [
                    SvgPicture.asset('assets/mapa/LLV.svg', width: 10, height: 10,),
                    const SizedBox(width: 4,),
                    const Text(
                      'LLV',
                      //style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = false;
                    valueOT = false;
                    valueLLV = true;
                    valuePAP = false;
                    valuePCR = false;
                    valuePSP = false;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valueLLV? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: [
                    SvgPicture.asset("assets/mapa/PAP.svg", width: 10, height: 10,),
                    const SizedBox(width: 4,),
                    const Text(
                      'PAP',
                      //style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = false;
                    valueOT = false;
                    valueLLV = false;
                    valuePAP = true;
                    valuePCR = false;
                    valuePSP = false;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valuePAP ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: [
                    SvgPicture.asset("assets/mapa/PCR.svg", width: 10, height: 10,),
                    const SizedBox(width: 4,),
                    const Text(
                      'PCR',
                      //style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = false;
                    valueOT = false;
                    valueLLV = false;
                    valuePAP = false;
                    valuePCR = true;
                    valuePSP = false;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valuePCR ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 5),
              alignment: Alignment.center,
              child: InkWell(
                child: Row(
                  children: [
                    SvgPicture.asset("assets/mapa/PSP.svg", width: 10, height: 10,),
                    const SizedBox(width: 4,),
                    const Text(
                      'PSP',
                      //style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: (){
                  setState(() {
                    valueEstruct = false;
                    valueSubEst = false;
                    valueOT = false;
                    valueLLV = false;
                    valuePAP = false;
                    valuePCR = false;
                    valuePSP = true;
                    valueSED = false;
                  });
                  if(query.length >= 2){
                    getListOption(query, valueEstruct, valueSubEst, valueOT, valueLLV, valuePAP, valuePCR, valuePSP, valueSED);
                  }else{
                    filteredSearch.clear();
                  }
                },
              ),
              decoration: BoxDecoration(
                color: valuePSP ? const Color.fromRGBO(120, 255, 255, 1) : Colors.white,
                border: Border.all(color: const Color.fromRGBO(44, 240, 233, 1)),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            
          ],
        ),
      ],
    );
  }
}

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();
  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      //Now you can set options that determine how the image gets cached via whichever plugin you use.
    );
  }
}
