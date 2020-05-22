import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/icons/darts/list_fooddart_icons.dart';
import 'package:food_size/src/widgets/favoriteRecipe.dart';
import 'package:food_size/src/widgets/horizontalListFood.dart';
import 'package:food_size/src/widgets/recipeDifficulty.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';
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
  RandomColor _randomColor = RandomColor();
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
                                onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["New recipes"]);},
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
                                                          imageUrl: "http://3.23.131.0:3002/"+(recipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
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
                                                                rating: 4.0,
                                                                size: 15.0,
                                                                filledIconData: Icons.star,
                                                                halfFilledIconData: Icons.star_half,
                                                                color: Colors.yellow,
                                                                borderColor: Colors.green,
                                                                spacing:0.0
                                                              ),
                                                              SizedBox(width: 5),
                                                              Text("4.0",style: TextStyle(fontSize: 12),),
                                                              SizedBox(width: 6,),
                                                              Text("(+99 reviews)",style: TextStyle(fontSize: 12),),
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
                  Container(
                    margin: EdgeInsets.only(top: 20,left: 15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Most voted",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                        GestureDetector(
                          onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["Most voted"]);},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                  HorizontalListFood(),
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
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: <Widget>[
                        category("Breakfast",Icon(Icons.free_breakfast,color: Colors.white,)),
                        category("Lunch",Icon(List_fooddart.lunch,color: Colors.white,)),
                        category("Dinner",Icon(Icons.local_dining,color: Colors.white,)),
                        category("Pizzas",Icon(Icons.local_pizza,color: Colors.white,)),
                        category("Juices",Icon(Icons.local_drink,color: Colors.white,)),
                        category("Salads",Icon(List_fooddart.salad,color: Colors.white,)),
                        category("Rices",Icon(List_fooddart.rice,color: Colors.white,)),
                        category("Fitness",Icon(Icons.fitness_center,color: Colors.white,)),
                      ],
                    ),
                  ),
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
                      return GestureDetector(
                        onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [randomRecipe[index]['idRecipe'],true]);}, 
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 5,top: 5),                            
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height:MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: CachedNetworkImage(
                                              imageUrl: "http://3.23.131.0:3002/"+(randomRecipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
                                              progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                              errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)
                                            ),
                                            gradient: LinearGradient(
                                              stops: [
                                                0.1,
                                                0.3
                                              ],
                                              colors:[
                                                Colors.black26,
                                                Colors.transparent
                                              ],
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft
                                            )
                                          ),
                                          child:Container(
                                            alignment: Alignment.topRight,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(40)
                                              ),
                                              color: Colors.white,
                                              child:FavoriteRecipe(liked: liked.contains(randomRecipe[index]["idRecipe"]),idRecipe: randomRecipe[index]["idRecipe"],)
                                            )
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10,right: 10,top:5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(randomRecipe[index]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.timer,color: Colors.grey,size: 11,),
                                        SizedBox(width: 5,),
                                        Text(randomRecipe[index]["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
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

  Widget category(categoriesName ,Icon iconName){
    Color _color = _randomColor.randomColor(
      colorHue: ColorHue.multiple(colorHues:[ColorHue.red, ColorHue.blue]),
      colorBrightness: ColorBrightness.light
    );
    return GestureDetector(
      onTap: (){Navigator.pushNamed(context, '/listFood',arguments: [categoriesName]);},
      child: Container(
        margin: EdgeInsets.all(5),
        width: 75,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40)
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: _color,
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.black45,
                    ),
                  ),
                  Center(
                    child: iconName,
                  ),
                ],
              )
            ),
            Container(
              margin: EdgeInsets.only(top:5),
              child: Center(
                child: Text(categoriesName,overflow: TextOverflow.ellipsis,),
              ),
            )
          ],
        )
      ),
    );
  }
}