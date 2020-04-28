import 'dart:convert';

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
  Color _color;

  @override
  void initState() { 
    super.initState();
    loadAllLists();
  }

  loadAllLists(){
    loadNewRecipes();
    mostVotedRecipes();
    randomRecipes();
  }

  Future loadNewRecipes() async{
    try {
      http.Response  responseNewRecipe= await http.get('http://192.168.100.54:3002/api/getLastsRecipe?idUser=1');
      String respNewRecipes = responseNewRecipe.body;
      final jsonNewRecipe = jsonDecode(respNewRecipes)["message"];
      print(jsonNewRecipe);
      setState(() {
        newRecipes = jsonNewRecipe;
      });
      for (var i = 0; i < newRecipes.length; i++) {
        if(newRecipes[i]["liked_recipes"].length!=0){
          likedNew.add(newRecipes[i]["idRecipe"]);
        }
      }
      print(likedNew);
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          newRecipes=null;
        });
      }
    }
  }

  Future mostVotedRecipes() async{
    try {
      http.Response responseMostVotedRecipe = await http.get('http://192.168.100.54:3002/api/getLikedRecipe?idUser=1');
      String respMostVotedRecipe = responseMostVotedRecipe.body;
      final jsonMostVotedRecipe = jsonDecode(respMostVotedRecipe)["message"];
      setState(() {
        mostVotedRecipe = jsonMostVotedRecipe;
      });
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
      http.Response responseRandomRecipe = await http.get('http://192.168.100.54:3002/api/getLikedRecipe?idUser=1');
      String respRandomRecipe = responseRandomRecipe.body;
      final jsonRandomRecipe = jsonDecode(respRandomRecipe)["message"];
      setState(() {
        randomRecipe=jsonRandomRecipe;
      });
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          randomRecipe = null;
        });
      }
    }
  }

  Future setLiked(idrecipe,actualState) async {
    http.Response resposeLiked = await http.post(
      'http://192.168.100.54:3002/api/updateLikedRecipe',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,dynamic>{
        'idRecipe':idrecipe,
        'idUser':1,
        'actualState':actualState
      }),
    );
    String respSetLiked = resposeLiked.body;
    final jsonSetLiked =jsonDecode(respSetLiked)["status"];
    print(respSetLiked);
    if(jsonSetLiked=="success"){
      if (actualState) {
          likedNew.remove(idrecipe);
      } else {
          likedNew.add(idrecipe);
      }
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){setState(() {
                indexSelected=0;
              });},
              color: indexSelected != 0 ? Colors.black : Colors.grey
            ),
            Text(categoryFood[indexSelected],style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (){setState(() {
                indexSelected=1;
              });},
              color: indexSelected == 1 ? Colors.grey : Colors.black,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: 0),
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
                            Text("Show all",style: TextStyle(color: Colors.blueAccent),)
                          ],
                        ),
                      ),
                      Container(
                        height: 245,
                        child: newRecipes != null ? Swiper(
                          itemCount: newRecipes.length,
                          viewportFraction: 0.73,
                          scale: 0.80,
                          itemBuilder: (BuildContext context,int index){
                            return ClipRRect(
                              child: GestureDetector(
                                onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [newRecipes[index]['idRecipe'],true]);},
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
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(19),
                                                  image: DecorationImage(
                                                    image: NetworkImage("http://192.168.100.54:3002/"+(newRecipes[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/')),
                                                    fit: BoxFit.cover
                                                  )
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
                                                                  Text(newRecipes[index]['title'],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 14),),
                                                                  Text(newRecipes[index]["description"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.grey,fontSize: 12.9),)
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
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Icon(Icons.timer,color: Colors.grey,),
                                                            Flexible(
                                                              child: Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(7),
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: (){setLiked(newRecipes[index]["idRecipe"],likedNew.contains(newRecipes[index]["idRecipe"]));},
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Icon(likedNew.contains(newRecipes[index]["idRecipe"])?Icons.favorite:Icons.favorite_border,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ),
                              ),
                            );
                          },
                        ):Center(
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
                      Text("Show all",style: TextStyle(color: Colors.blueAccent),)
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  height: 210,
                  child: mostVotedRecipe!=null ? ListView.builder(
                    itemCount: mostVotedRecipe.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                                width: 105,
                                height: 170,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage("http://192.168.100.54:3002/"+(mostVotedRecipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/')),
                                    fit: BoxFit.cover
                                  )
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.favorite_border,color: Colors.red,),
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
                                Text(mostVotedRecipe[index]['title'],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
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
                  ):Center(
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
                      Text("Show all",style: TextStyle(color: Colors.blueAccent),)
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
                      Text("Show all",style: TextStyle(color: Colors.blueAccent),),
                    ],
                  ),
                ),
              ]),
            ),
            randomRecipe!=null ? SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, index){
                  return Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage("http://192.168.100.54:3002/"+(randomRecipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/')),
                                fit: BoxFit.cover
                              )
                            ),
                            child: Container(
                              margin: EdgeInsets.all(6),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(Icons.favorite_border,color: Colors.red,),
                                  ],
                                )
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
            ):SliverList(
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
    );
  }

  Widget category(categoriesName ,Icon iconName){
    _color = _randomColor.randomColor();
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