import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/src/widgets/showFoodChild.dart';
import 'package:http/http.dart' as http;

class ShowFood extends StatefulWidget {
  final List data;
  ShowFood({Key key,@required this.data}) : super(key: key);

  @override
  _ShowFoodState createState() => _ShowFoodState(data);
}

class _ShowFoodState extends State<ShowFood> {
  List data;
  _ShowFoodState(this.data);

  @override
  void initState() { 
    super.initState();
  }

  Future loadRecipe() async{
    try {
      http.Response responseRecipe = await http.get('http://3.23.131.0:3002/api/getRecipe?idRecipe='+data[0].toString()+'&idUser=1');
      if(responseRecipe.statusCode == HttpStatus.ok){
        var result = (responseRecipe.body);
        return result;
      }
    } on SocketException {
      throw Failure("No internet connection");
    } on HttpException {
      throw Failure("No internet connection");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: loadRecipe(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              var recipe = jsonDecode(snapshot.data)["message"];
              bool liked = jsonDecode(snapshot.data)["liked"];
              Recipe recipeInformation = Recipe(idRecipe: recipe["idRecipe"],description: recipe["description"],title: recipe["title"],aproxTime: recipe["approximateTime"],difficulty: recipe["difficulty"]);
              List recipeSteps = recipe["recipe_steps"];
              List recipeIngredients = recipe["recipe_ingredients"];
              List recipeComments = recipe["recipe_comments"];
              List allImages = [];
              List recipeImages = recipe["recipe_images"];
              for (var ingredient in recipeIngredients) {
                allImages.add(ingredient["ingredient"]["routeImage"]);
              }
              for (var recipeImage in recipe["recipe_images"]) {
                allImages.add(recipeImage["route"]);
              }
              return ShowFoodChild(data: data,recipe: recipeInformation,recipeSteps: recipeSteps,recipeIngredients: recipeIngredients,recipeComments: recipeComments,allImages: allImages,recipeImages: recipeImages,liked: liked,);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      )
    );
  }
}

class Failure {
  // Use something like "int code;" if you want to translate error messages
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}