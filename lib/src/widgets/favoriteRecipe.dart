import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:http/http.dart' as http;

class FavoriteRecipe extends StatefulWidget {
  final bool liked;
  final int idRecipe;
  FavoriteRecipe({Key key,@required this.liked,@required this.idRecipe}) : super(key: key);

  @override
  _FavoriteRecipeState createState() => _FavoriteRecipeState(liked,idRecipe);
}

class _FavoriteRecipeState extends State<FavoriteRecipe> {
  bool liked;
  int idRecipe;
  _FavoriteRecipeState(this.liked,this.idRecipe);

  @override
  void initState() {
    super.initState();
  }

  Future modifieFavoriteRecipe(controller) async{
    try {
      final http.Response response = await http.post(
        'http://3.23.131.0:3002/api/updateFavoriteRecipe',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "actualState":liked,
          "idRecipe":idRecipe,
          "idUser":1
        }),
      );

      if (response.statusCode == 200) {
        var responseDecode = jsonDecode(response.body);
        if(responseDecode["status"]=="success"){
          var messageDecode = jsonDecode(responseDecode["message"]);
          if(messageDecode["case"]=="destroy"||messageDecode["case"]=="destroyed"){
            setState(() {liked=false;});
          }
          if(messageDecode["case"]=="created"||messageDecode["case"]=="existed"){
            setState(() {liked=true;});
          }
          controller.forward(from:0.0);
        }else{
          print(responseDecode);
        }
        setState(() {});
      }else{
        print(response);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PimpedButton(
      particle: DemoParticle(),
      pimpedWidgetBuilder: (context, controller){
        return IconButton(
          onPressed: (){modifieFavoriteRecipe(controller);},
          icon: Icon(liked?Icons.favorite:Icons.favorite_border,color: Colors.red,)
        );
      }
    );
  }
}