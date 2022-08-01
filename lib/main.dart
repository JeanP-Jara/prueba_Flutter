import 'package:flutter/material.dart';
import 'package:flutter_application/pages/login/theme_state.dart';
import 'package:flutter_application/routes/pages.dart';
import 'package:flutter_application/routes/routes.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  MyApp({Key? key}) : super(key: key);

  final HttpLink httpLink = HttpLink('https://pouer-campo-services.herokuapp.com/graphql',);
  @override
  Widget build(BuildContext context) {    
    ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        link: httpLink,      
        cache: GraphQLCache(),
      ),
    );
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeState>(
              create: (_)=> ThemeState(),
            ), 
          ],
          child: Consumer<ThemeState>(
            builder: (context, state, child){
              return MaterialApp(
                title: 'Pouer',
                theme: ThemeData(
                  brightness: state.currentTheme,
                  primarySwatch: state.currentcolor,
                  floatingActionButtonTheme: state.currentButton,
                  //textTheme: const TextTheme(headline1: TextStyle(fontSize: 25)),
                ),
                initialRoute: Routes.SPLASH,
                routes: appRoutes(),
              );
            },          
          ),
        ),
      ),
    );
    
  }
}