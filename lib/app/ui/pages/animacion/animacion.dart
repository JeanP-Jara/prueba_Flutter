import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Animacion  extends StatelessWidget {
  const Animacion ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Bar"),
      ),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context,index){
          return Card(
            child: FadeInImage(
              image: NetworkImage("https://picsum.photos/id/$index/400/300"), 
              placeholder: const AssetImage("assets/spinner.gif"),
            ),
          );
        }
      ),
    );
  }
}