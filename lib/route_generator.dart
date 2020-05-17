import 'package:flutter/material.dart';
import 'package:food_size/src/pages/categories.dart';
import 'package:food_size/src/pages/listFood.dart';
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
      case '/listFood':
        return MaterialPageRoute(
          builder: (_) => ListFood(
            data:args
          )
        );
        break;
      case'/categories':
        return MaterialPageRoute(
          builder: (_) => Categories()
        );
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