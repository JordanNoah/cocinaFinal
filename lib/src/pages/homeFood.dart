import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/widgets/categorieList.dart';
import 'package:food_size/src/widgets/mostVotedRecipe.dart';
import 'package:food_size/src/widgets/newRecipe.dart';
import 'package:food_size/src/widgets/randomRecipe.dart';
import 'package:food_size/src/widgets/recipeDemo.dart';
import 'package:http/http.dart' as http;

class HomeFood extends StatefulWidget {
  HomeFood({Key key}) : super(key: key);

  @override
  _HomeFoodState createState() => _HomeFoodState();
}

class _HomeFoodState extends State<HomeFood> {
  int indexSelected = 0;
  final categoryFood = ["Vegan","Vegetarian"];
  List newRecipes = [];
  List randomRecipe = [];
  List liked=[];

  @override
  void initState() { 
    super.initState();
    getIdsLikedRecipe();
  }

  Future getIdsLikedRecipe() async{
    try {
      http.Response responseLiked = await http.get('http://3.23.131.0:3002/api/getIdsLikedRecipe?idUser=1');
      if(responseLiked.statusCode == HttpStatus.ok){
        var ids=jsonDecode(responseLiked.body)["message"];
        for(var idrecipe in ids){
          liked.add(idrecipe["idRecipe"]);
        }
        setState(() {});
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          randomRecipe = null;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                indexSelected !=0 ? setState(() {
                  indexSelected=0;
                }):null;
              },
              color: indexSelected != 0 ? Colors.black : Colors.grey
            ),
            Text(categoryFood[indexSelected],style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (){
                indexSelected ==1 ? null : setState(() {
                  indexSelected=1;
                });
              },
              color: indexSelected == 1 ? Colors.grey : Colors.black,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  NewRecipe(liked: liked,),
                  MostVotedRecipe(),
                  CategorieList(),
                  RandomRecipe(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}