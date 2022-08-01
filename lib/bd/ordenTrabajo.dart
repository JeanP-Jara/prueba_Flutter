class OrdenTrabajoList {
  List id = [];
  List code = [];
  List scheduledAt =[];
  List priority = [];
  List assetId = [];
  List assetType = [];
  List descriptionOfIssue = [];
  List scopeOfWork = [];
  List locationX = [];
  List locationY = [];
  List notes = [];  
  List assignedToId = [];
  List fullName = [];
  List completionId = [];
  List completionAction = [];

  OrdenTrabajoList({
    required this.id, required this.code,required this.scheduledAt, required this.priority, required this.assetId, required this.assetType, 
    required this.descriptionOfIssue, required this.scopeOfWork, required this.locationX, required this.locationY, required this.notes, 
    required this.assignedToId, required this.fullName, required this.completionId, required this.completionAction
  });

  Map<String, dynamic> toMap(){
    return { 
      'id': id,
      'code': code,
      'scheduledAt': scheduledAt,
      'priority': priority,
      'assetId' : assetId,
      'assetType' : assetType,
      'descriptionOfIssue': descriptionOfIssue,
      'scopeOfWork': scopeOfWork,
      'locationX': locationX,
      'locationY' : locationY,
      'notes' : notes,
      'assignedToId' : assignedToId,
      'fullName' : fullName,
      'completionId': completionId,
      'completionAction' : completionAction,
    };
  }
}

class OrdenTrabajo {
  String id = '';
  String code = '';
  String scheduledAt= '';
  String priority = '';
  String assetId = '';
  String assetType = '';
  String descriptionOfIssue = '';
  String scopeOfWork = '';
  String locationX = '';
  String locationY = '';
  String notes = '';
  String assignedToId = '';
  String fullName = '';
  String completionId = '';
  String send = '';
  String completionAction = '';
  String comentario = '';
  String countArchivos = '';

  OrdenTrabajo({
    required this.id, required this.code,required this.scheduledAt, required this.priority, required this.assetId, required this.assetType, 
    required this.descriptionOfIssue, required this.scopeOfWork, required this.locationX, required this.locationY, required this.notes, 
    required this.assignedToId, required this.fullName, required this.completionId, required this.send, required this.completionAction, 
    required this.comentario, required this.countArchivos
  });

  Map<String, dynamic> toMap(){
    return { 
      'id': id,
      'code': code,
      'scheduledAt': scheduledAt,
      'priority': priority,
      'assetId' : assetId,
      'assetType' : assetType,
      'descriptionOfIssue': descriptionOfIssue,
      'scopeOfWork': scopeOfWork,
      'locationX': locationX,
      'locationY' : locationY,
      'notes' : notes,
      'assignedToId' : assignedToId,
      'fullName' : fullName,
      'completionId': completionId,
      'send': send,
      'completionAction' : completionAction,
      'comentario' : comentario,
      'countArchivos': countArchivos
    };
  }
}

