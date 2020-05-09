import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:food_size/src/icons/darts/list_fooddart_icons.dart';
import 'package:http/http.dart' as http;
import 'package:random_color/random_color.dart';

class HomeFood extends StatefulWidget {
  HomeFood({Key key}) : super(key: key);

  @override
  _HomeFoodState createState() => _HomeFoodState();
}

class _HomeFoodState extends State<HomeFood> {
  int indexSelected = 0;
  final categoryFood = ["Vegan","Vegetarian"];
  List newRecipes = [];
  List mostVotedRecipe = [];
  List randomRecipe = [];
  List likedNew = [];
  RandomColor _randomColor = RandomColor();

  @override
  void initState() { 
    super.initState();
    randomRecipes();
  }


  Future loadNewRecipes() async{
    try {
      http.Response responseNewRecipe = await http.get('http://192.168.100.54:3002/api/getLastsRecipe?idUser=1');
      if(responseNewRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseNewRecipe.body)["message"];
        return result;
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          newRecipes = null;
        });
      }
    }
  }

  Future mostVotedRecipes() async{
    try {
      http.Response responseMostVotedRecipe = await http.get('http://192.168.100.54:3002/api/getLikedRecipe');
      if(responseMostVotedRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseMostVotedRecipe.body)["message"];
        return result;
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          mostVotedRecipe = null;
        });
      }
    }
  }

  Future randomRecipes() async{
    try {
      http.Response responseRandomRecipe = await http.get('http://192.168.100.54:3002/api/getRandomRecipe?idExisting=[]');
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

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(bottom: 0),
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    child: Row(
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
                                onTap: (){Navigator.pushNamed(context, '/categorie',arguments: ["New recipes"]);},
                                child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 245,
                          child: newRecipes != null ? 
                            FutureBuilder(
                              future: loadNewRecipes(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error'));
                                }
                                if (snapshot.connectionState == ConnectionState.done) {
                                  var recipe = snapshot.data;
                                  return Swiper(
                                    itemCount: snapshot.data.length,
                                    viewportFraction: 0.73,
                                    scale: 0.80,
                                    itemBuilder: (BuildContext context,int index){
                                      return Center(
                                        child: ClipRRect(
                                          child: GestureDetector(
                                            onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipe[index]['idRecipe'],true]);},
                                            child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0),
                                            ),
                                            child: Container(
                                              child: Stack(
                                                children: <Widget>[
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: <Widget>[
                                                      Flexible(
                                                        flex: 2,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(20),
                                                            topRight: Radius.circular(20)
                                                          ),
                                                          child: CachedNetworkImage(
                                                            imageUrl: "http://192.168.100.54:3002/"+(recipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
                                                            progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                              Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                                            errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(19)
                                                          ),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Flexible(
                                                                flex: 5,
                                                                child: Container(
                                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      Flexible(
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          children: <Widget>[
                                                                            Text(recipe[index]['title'],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 14),),
                                                                            Text(recipe[index]["description"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.grey,fontSize: 12.9),)
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  )
                                                                ),
                                                              ),
                                                              Flexible(
                                                                flex: 4,
                                                                child: Container(
                                                                  padding: EdgeInsets.all(2),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: <Widget>[
                                                                      Row(
                                                                        children: <Widget>[
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.grey,
                                                                              borderRadius: BorderRadius.circular(40.0)
                                                                            ),
                                                                            child: Row(
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  height: 10,
                                                                                  width: 16.66,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.orange,
                                                                                    borderRadius: BorderRadius.only(
                                                                                      topLeft: Radius.circular(40.0),
                                                                                      bottomLeft:Radius.circular(40.0), 
                                                                                    )
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 10,
                                                                                  width: 16.66,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.orange,
                                                                                    borderRadius: BorderRadius.only(
                                                                                      topRight: Radius.circular(40.0),
                                                                                      bottomRight:Radius.circular(40.0), 
                                                                                    )
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 10,
                                                                                  width: 16.66,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.transparent,
                                                                                    borderRadius: BorderRadius.only(
                                                                                      topRight: Radius.circular(40.0),
                                                                                      bottomRight:Radius.circular(40.0), 
                                                                                    )
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 10,),
                                                                          Container(
                                                                            child: Text("Hard",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,letterSpacing: 1),),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Icon(Icons.timer,color: Colors.grey,),
                                                                          Flexible(
                                                                            child: Text(recipe[index]["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  )
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ),
                                          ),
                                        )
                                      );
                                    },
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
                          onTap: (){Navigator.pushNamed(context, '/categorie',arguments: ["Most voted"]);},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:10),
                    height: 210,
                    child: mostVotedRecipe!=null ? 
                      FutureBuilder(
                        future: mostVotedRecipes(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState == ConnectionState.done) {
                            var recipe = snapshot.data;
                            return ListView.builder(
                              itemCount: recipe.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipe[index]['idRecipe'],true]);},
                                          child: Container(
                                            margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                                            width: 105,
                                            height: 170,
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  height: MediaQuery.of(context).size.height,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: CachedNetworkImage(
                                                      imageUrl: "http://192.168.100.54:3002/"+(recipe[index]["recipe"]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
                                                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                        Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                      width: 105,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 5,),
                                          Text(recipe[index]["recipe"]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.timer,color: Colors.grey,size: 11,),
                                              SizedBox(width: 5,),
                                              Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                );
                              },
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
                            "Refresh most voted",
                            style: TextStyle(fontSize: 30,),textAlign: TextAlign.center,
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: (){mostVotedRecipes();},
                            iconSize: 50,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20,left: 15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                        GestureDetector(
                          onTap: (){Navigator.pushNamed(context, '/categorie',arguments: ["Categories"]);},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Wrap(
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
                          onTap: (){Navigator.pushNamed(context, '/categorie',arguments: ["Random"]);},
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
                                              imageUrl: "http://192.168.100.54:3002/"+(randomRecipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
                                              progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                              errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
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
                                        Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
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
                    childAspectRatio: 0.8
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
      onTap: (){Navigator.pushNamed(context, '/categorie',arguments: [categoriesName]);},
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