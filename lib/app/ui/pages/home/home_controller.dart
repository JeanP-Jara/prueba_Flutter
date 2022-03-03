


import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/app/ui/utils/map_style.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends ChangeNotifier{
  final Map<MarkerId,Marker> _markers = {};

  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  final initialCameraPosition = const CameraPosition(
    target: LatLng(-12.2176412,-76.9484089),
    zoom: 13,
  );

  void onMapCreated(GoogleMapController controller){
    controller.setMapStyle(mapStyle);
  }

  void onTap(LatLng position){
    final id = _markers.length.toString();
    final markerId = MarkerId(_markers.length.toString());
    final marker = Marker(
      markerId: markerId,
      position: position,
      draggable: true,
      //anchor: const Offset(0.5, 1),
      icon: BitmapDescriptor.defaultMarkerWithHue(100),//color marcador
      onTap: (){
        _markersController.sink.add(id);
      },
      onDrag: (newPosition){
        
      }
    );
    _markers[markerId] = marker;    
    print(marker.position.latitude);
    print(marker.position.longitude);    
    notifyListeners();
  }
  HomeController(){
    _init();
  }
  Future <void> _init() async {
    final initposition = await Geolocator.getCurrentPosition();
    print("posicion Dipostivo $initposition");
  }
 
  
}