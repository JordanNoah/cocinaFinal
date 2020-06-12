import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/widgets/categorieList.dart';
import 'package:food_size/src/widgets/favoriteRecipe.dart';
import 'package:food_size/src/widgets/mostVotedRecipe.dart';
import 'package:food_size/src/widgets/recipeDemo.dart';
import 'package:food_size/src/widgets/recipeDifficulty.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

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
    randomRecipes();
    getIdsLikedRecipe();
  }



  Future loadNewRecipes() async{
    try {
      http.Response responseNewRecipe = await http.get('http://3.23.131.0:3002/api/getLastsRecipe');
      if(responseNewRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseNewRecipe.body)["message"];
        return result;
      }
    } on Exception catch (e) {
      return e;
    }
  }

  Future randomRecipes() async{
    try {
      http.Response responseRandomRecipe = await http.get('http://3.23.131.0:3002/api/getRandomRecipe?idExisting=[]');
      if(responseRandomRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseRandomRecipe.body);
        setState(() {
          randomRecipe=result;
        });
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          randomRecipe = null;
        });
      }
    }
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
                  Container(
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
                                onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["New recipes",indexSelected]);},
                                child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 280,
                          width: MediaQuery.of(context).size.width,
                          child: newRecipes != null ? 
                            FutureBuilder(
                              future: loadNewRecipes(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error'));
                                }
                                if (snapshot.connectionState == ConnectionState.done) {
                                  List recipe = snapshot.data;
                                  return CarouselSlider.builder(
                                    itemCount: recipe.length,
                                    itemBuilder: (BuildContext context, int index) =>
                                      Container(
                                        padding: EdgeInsets.all(10),
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
                                                  children: <Widget>[
                                                    Container(
                                                      width: MediaQuery.of(context).size.width*0.60,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(recipe[index]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,letterSpacing: 1),),
                                                          Row(
                                                            children: <Widget>[
                                                              SmoothStarRating(
                                                                allowHalfRating: true,
                                                                starCount: 5,
                                                                rating: recipe[index]["recipe_comments"][0]["totalAssessment"],
                                                                size: 15.0,
                                                                filledIconData: Icons.star,
                                                                halfFilledIconData: Icons.star_half,
                                                                color: Colors.yellow,
                                                                borderColor: Colors.black,
                                                                spacing:0.0
                                                              ),
                                                              SizedBox(width: 5),
                                                              Text(recipe[index]["recipe_comments"][0]["totalAssessment"].toString(),style: TextStyle(fontSize: 12),),
                                                              SizedBox(width: 6,),
                                                              recipe[index]['recipe_comments'][0]['countOfReview']>99
                                                                ?
                                                                  Text("(+99 reviews)",style: TextStyle(fontSize: 12),)
                                                                    :
                                                                      Text("("+recipe[index]["recipe_comments"][0]["countOfReview"].toString()+" reviews)",style: TextStyle(fontSize: 12),)
                                                            ],
                                                          ),
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
                                  );
                                } else {
                                  return Center(child: CircularProgressIndicator());
                                }
                              }
                            )
                          :Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Refresh new recipes",
                                  style: TextStyle(fontSize: 30,),textAlign: TextAlign.center,
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: (){randomRecipes();},
                                  iconSize: 50,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  MostVotedRecipe(),
                  Container(
                    margin: EdgeInsets.only(top: 20,left: 15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                        GestureDetector(
                          onTap: (){Navigator.pushNamed(context, '/categories');},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                  CategorieList(),
                  Container(
                    margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Random",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                        GestureDetector(
                          onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["Random"]);},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                ]),
              ),
              randomRecipe!=null ? 
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, index){
                      return RecipeDemo(title: randomRecipe[index]["title"],isFavorite: liked.contains(randomRecipe[index]["idRecipe"]),urlImage: randomRecipe[index]["recipe_images"][0][    "route"],aproxTime: randomRecipe[index]["approximateTime"],idRecipe: randomRecipe[index]["idRecipe"],);
                    },
                    childCount: randomRecipe.length
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.7
                  )
                )
              :SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Refresh random",
                            style: TextStyle(fontSize: 30,),textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: (){loadNewRecipes();},
                            iconSize: 50,
                          )
                        ],
                      ),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}