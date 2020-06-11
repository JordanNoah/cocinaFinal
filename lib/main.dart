import 'package:flutter/material.dart';
import 'package:food_size/route_generator.dart';
import 'package:flutter/services.dart';

void main() async{
  runApp(MyApp());
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Cocina',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        initialRoute: '/',
        onGenerateRoute: RouterGenerator.generateRoute
    );
  }
}