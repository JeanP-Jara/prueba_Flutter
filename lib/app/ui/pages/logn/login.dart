
import 'package:flutter/material.dart';
import 'package:flutter_application_1/app/ui/routes/routes.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  
  @override
  State<Login> createState() => _LoginState();
}



class _LoginState extends State<Login> {
   String txtuser='';
   String txtpassword='';
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: NetworkImage("https://images.pexels.com/photos/799443/pexels-photo-799443.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500"),
          fit: BoxFit.cover
          )
        ),
        child: Form(
          key: formkey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                const Text("Sign in", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 35.0, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child:  TextFormField(
                    onSaved: (value) {
                      txtuser =  value!;
                    },
                    validator: (value) {
                      if(value != ''){
                        return "VACIO";
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "User",
                      fillColor: Colors.white,
                      filled: true
                    ),
                    
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child:  TextFormField(
                    onSaved: (value) {
                      txtpassword =  value!;
                    },
                    validator: (value) {
                      if(value != ''){
                        return "VACIO";
                      }
                    },
                    obscureText: true,
                    decoration:const InputDecoration(
                      hintText: "Password",
                      fillColor: Colors.white,
                      filled: true
                    ),
                  ),
                ),
                SizedBox(height: 10),
                RaisedButton(
                  color: Colors.green[300],
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  onPressed: (){    
                    formkey.currentState?.save();
                    print(txtuser);
                    print(txtpassword);
                    if( txtuser == 'a' && txtpassword == 'b' ){
                      Navigator.pushReplacementNamed(context, Routes.HOME);
                    }                    
                  }, 
                  child: const Text("Entrar", style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                  ),)
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}


