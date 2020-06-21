import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/widgets/favoriteRecipe.dart';
import 'package:food_size/src/widgets/recipeDifficulty.dart';
import 'package:food_size/src/widgets/showRate.dart';
import 'package:http/http.dart' as http;

class NewRecipe extends StatefulWidget {
  final List liked;
  NewRecipe({Key key,@required this.liked}) : super(key: key);

  @override
  _NewRecipeState createState() => _NewRecipeState(this.liked);
}

class _NewRecipeState extends State<NewRecipe> {
  List liked;
  _NewRecipeState(this.liked);

  Future loadNewRecipes() async{
    try {
      http.Response responseNewRecipe = await http.get('http://3.23.131.0:3002/api/getLastsRecipe');
      if(responseNewRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseNewRecipe.body)["message"];
        return result;
      }
    } on SocketException {
      throw Failure("No internet connection");
    } on HttpException {
      throw Failure("Couldn't find the post");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadNewRecipes(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 15,right: 15,bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("New recipes",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),)
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: (){
                          setState(() {});
                        },
                      )
                    ],
                  ) 
                )
              ],
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          List recipe = snapshot.data;
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("New recipes",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                      GestureDetector(
                        onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["New recipes",1]);},
                        child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 260,
                  width: MediaQuery.of(context).size.width,
                  child: CarouselSlider.builder(
                    itemCount: recipe.length,
                    itemBuilder: (BuildContext context, int index) =>
                      Container(
                        padding: EdgeInsets.symmetric(horizontal:10),
                        width: MediaQuery.of(context).size.width,
                        child: GestureDetector(
                          onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipe[index]["idRecipe"],true]);},
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 200,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: "http://3.23.131.0:3002/"+(recipe[index]["recipe_images"][0]["route"]).replaceAll(r"\",'/'),
                                          progressIndicatorBuilder: (context, url, downloadProgress) => 
                                            Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                          errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(40)
                                        ),
                                        color: Colors.white,
                                        child: FavoriteRecipe(liked: liked.contains(recipe[index]["idRecipe"]),idRecipe: recipe[index]["idRecipe"],),
                                      )
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 60,
                                padding: EdgeInsets.only(top:5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.60,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(recipe[index]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 1),),
                                          ShowRate(totalAssessment: recipe[index]["totalAssessment"], countOfReview: recipe[index]["countOfReview"])
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            child: RecipeDifficulty(recipe[index]["difficulty"]),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Icon(Icons.timer,color: Colors.grey,size: 14,),
                                              SizedBox(width: 5,),
                                              Text(recipe[index]["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 14),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      aspectRatio: 0.1,
                      initialPage: 0,
                      autoPlayInterval: Duration(seconds: 5),
                      autoPlayAnimationDuration: Duration(seconds: 2),
                    ),
                  )
                )
              ],
            ),
          );

        } else {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("New recipes",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),)
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CircularProgressIndicator()
                  )
                )
              ],
            ),
          );
        }
      }
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

// List recipe = snapshot.data;
//                       return 

