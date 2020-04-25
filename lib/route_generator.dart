import 'package:flutter/material.dart';
import 'package:food_size/src/pages/foods.dart';
import 'package:food_size/src/pages/playRecipie.dart';
import 'package:food_size/src/pages/showFood.dart';

class RouterGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Foods());
        break;
      case '/showfood':
        return MaterialPageRoute(
          builder: (_) => ShowFood(
            data:args
          )
        );
        break;
      case '/playRecipie':
        return MaterialPageRoute(
          builder: (_) => PlayRecipie(
            data:args
          )
        );
        break;
      default:

      return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        body: Center(
          child: Text("NO EXISTE   RUTA"),
        ),
      );
    });
  }
}