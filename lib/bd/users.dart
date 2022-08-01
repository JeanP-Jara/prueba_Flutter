class Users {
  List id = [];
  List username = []; 
  List fullname = [];
  List password = [];  

  Users({ required this.id, required this.username, required this.fullname, required this.password});

  Map<String, dynamic> toMap(){
    return { 
      'id': id,       
      'username': username,
      'fullname': fullname,
      'password': password      
    };
  }
}

class User {
  int id = 0;
  String username = ""; 
  String fullname = "";
  String password = "";  

  User({ required this.id, required this.username, required this.fullname, required this.password});

  Map<String, dynamic> toMap(){
    return { 
      'id': id,       
      'username': username,
      'fullname': fullname,
      'password': password      
    };
  }
}