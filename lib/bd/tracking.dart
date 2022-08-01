class Tracking {
  int n_id = 0;
  double latitud = 0.0; 
  double longitud = 0.0; 
  double altitud = 0.0; 
  double precision = 0.0; 
  int id = 0;
  String username ='';
  String fullname = '';
  String fecha = '';
  int estado = 0;

  Tracking({ required this.n_id, required this.latitud, required this.longitud, required this.altitud, required this.precision, 
  required this.id, required this.username, required this.fullname, required this.fecha, 
  required this.estado});

  Map<dynamic, dynamic> toMap(){
    return { 
      n_id: n_id,
      latitud: latitud,
      longitud: longitud,
      altitud: altitud,
      precision: precision,
      id: id,       
      username: username,
      fullname: fullname,
      fecha: fecha,      
      estado: estado
    };
  }
}