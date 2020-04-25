import 'package:flutter/material.dart';
import 'package:food_size/route_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Cocina',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: RouterGenerator.generateRoute
        // routes: {
        //   "/":(BuildContext context)=>Foods(),
        //   "showfood":(BuildContext context,String idRecipe)=>ShowFood(),
        //   "playRecipie":(BuildContext context)=>PlayRecipie()
        // },
    );
  }
}