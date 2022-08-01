import 'package:flutter/material.dart';
import 'package:flutter_application/bd/bd.dart';
import 'package:flutter_application/bd/ordenTrabajo.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
int _id = 0; 
  String _username = '';
  String _fullname = ''; 
  String _password = '';
  bool estadoIcon = false;

class ULinit{
  static Future userLoginit(id, username, fullname,password) async {
    _id = id;
    _username = username;
    _fullname = fullname;
    _password = password;    
  }
}

final String getData = """
    query {           
          workordersByUser(userId: $_id) { 
            id
            code
            scheduledAt 
            priority
            assetId 
            assetType 
            descriptionOfIssue 
            scopeOfWork 
            locationX 
            locationY 
            notes 
            assignedTo { 
              id 
              fullName 
            }
            grid {
              id
              gridName
            }
            completion{
              id
              action
              description
              evidence{
                id
                description
                url
              }
            }
          }
	      }  
    """;
OrdenTrabajoList _OT = OrdenTrabajoList(id: [], code: [], scheduledAt: [], priority: [], assetId: [], assetType: [], descriptionOfIssue: [], scopeOfWork: [], locationX: [], locationY: [], notes: [], assignedToId: [], fullName: [], completionId: [], completionAction: []);
showAlertUsers(context, String cadena){
  showDialog(
    barrierColor: const Color.fromRGBO(14, 106, 142 , 0.7),
    context: context, 
    builder: (BuildContext context){
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: const [
            Text("ALERTA", 
                style: TextStyle(
                    color: Color.fromRGBO(119, 118, 118, 1),
                ),
              ),
            Divider(
              height: 40,
              thickness: 2,
              color: Color.fromRGBO(44, 240, 233, 1),
              indent: 10,
              endIndent: 10,
            ),
          ],
        ),               
        content: SingleChildScrollView(
          child: Column(
            children: [
              ///Text('Usuarios actualizados', style: const TextStyle(fontSize: 16, color: Color.fromRGBO(119, 118, 118, 1),),), 
              //SizedBox(height: 15), 
              Text(cadena, 
                style: const TextStyle(
                  fontSize: 16, 
                  color: Color.fromRGBO(119, 118, 118, 1),
                ),
              ),          
              const SizedBox(height: 35),     
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.fromLTRB(70, 15, 70, 15),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),)
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromRGBO(44, 240, 233, 1),
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();                          
                },                           
                child:const Text('ACEPTAR'),
              ),
            ],
          ),
        ),
      );
    }
  );
}

alertNotifyException(context, String text){
    print(text);
    return showDialog(
      barrierColor: const Color.fromRGBO(14, 106, 142 , 0.7),
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: const [
              Text("ALERTA", 
                  style: TextStyle(
                      color: Color.fromRGBO(119, 118, 118, 1),
                  ),
                ),
              Divider(
                  height: 40,
                  thickness: 2,
                  color: Color.fromRGBO(44, 240, 233, 1),
                  indent: 10,
                  endIndent: 10,
                ),
            ],
          ),               
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(text, style: const TextStyle(fontSize: 16, color: Color.fromRGBO(119, 118, 118, 1),),),          
                const SizedBox(height: 35),     
                ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.fromLTRB(70, 15, 70, 15),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),)
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromRGBO(44, 240, 233, 1),
                    ),
                  ),
                  onPressed: (){                                 
                    Navigator.of(context).pop();
                  },                           
                  child:const Text('ACEPTAR'),
                ),
              ],
            ),
          ),
        );
      }
    );
  }


  cargaOtUserLog(context){
    return showDialog(
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(14, 106, 142 , 0.7),
      context: context, 
      builder: (BuildContext context){
        return Query(
          options: QueryOptions(
            document: gql(getData),
          ), 
          builder: (QueryResult result, {fetchMore, refetch} ){
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }      
            if(result.isConcrete){              
              var data = result.data?['workordersByUser'];
              //print(data);
              _OT.assetId.clear();
              _OT.assetType.clear();
              _OT.descriptionOfIssue.clear();
              _OT.fullName.clear();
              _OT.id.clear();
              _OT.locationX.clear();
              _OT.locationY.clear();
              _OT.notes.clear();
              _OT.priority.clear();
              _OT.scheduledAt.clear();
              _OT.scopeOfWork.clear();
              _OT.id.clear();
              _OT.code.clear();
              _OT.assignedToId.clear();
            
              for (var item in data) {  
                _OT.id.add(item['id'].toString());
                _OT.code.add(item['code'].toString());
                _OT.assetId.add(item['assetId'].toString());
                _OT.assetType.add(item['assetType'].toString());
                _OT.descriptionOfIssue.add(item['descriptionOfIssue'].toString());
                _OT.fullName.add(item['assignedTo']['fullName'].toString());
                _OT.locationX.add(item['locationX'].toString());
                _OT.locationY.add(item['locationY'].toString());
                _OT.notes.add(item['notes'].toString());
                _OT.priority.add(item['priority'].toString());
                _OT.scheduledAt.add(item['scheduledAt'].toString());
                _OT.scopeOfWork.add(item['scopeOfWork'].toString());
                _OT.assignedToId.add(item['assignedTo']['id'].toString());
                //_OT.completionId.add(item['completion'][0]['id'].toString());
                _OT.completionId.add('0');
              }
              BD.InsertOT(_OT, context);   
//              Navigator.pushReplacementNamed(context, Routes.MAPAFLUTTER);
            }
            return Container();
          },      
        );
      }
    );
  }