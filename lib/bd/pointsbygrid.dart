
class PointsByGridList {
  List id = [];
  List objcode = [];
  List objtype = [];
  List nlatitud = [];
  List nlongitud = [];
  List idtopology = [];
  List nametopology = [];

  PointsByGridList({required this.id, required this.objcode, required this.objtype, required this.nlatitud, 
                required this.nlongitud, required this.idtopology, required this.nametopology});

  Map<String, dynamic> toMap(){
    return { 
      'id': id, 
      'objcode': objcode,
      'objtype': objtype,
      'nlatitud': nlatitud,
      'nlongitud': nlongitud,
      'idtopology': idtopology,
      'toponametopology': nametopology
    };
  }
}

class PointsByGrid {
  String id = '';
  String objcode = '';
  String objtype = '';
  String nlatitud = '';
  String nlongitud = '';
  String idtopology = '';
  String nametopology = '';

  PointsByGrid({required this.id, required this.objcode, required this.objtype, required this.nlatitud, 
                required this.nlongitud,required this.idtopology, required this.nametopology});

  Map<String, dynamic> toMap(){
    return { 
      'id': id, 
      'objcode': objcode,
      'objtype': objtype,
      'nlatitud': nlatitud,
      'nlongitud': nlongitud,
      'idtopology': idtopology,
      'toponametopology': nametopology
    };
  }
}

