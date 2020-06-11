import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Favorites extends StatefulWidget {
  Favorites({Key key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List myFavorite = [];

  @override
  void initState() { 
    super.initState();
    loadFavoriteRecipes();
  }
  
  Future loadFavoriteRecipes() async {
    http.Response  responseFavRecipe= await http.get('http://3.23.131.0:3002/api/getMyfavorites?idUser=1');
    String respFavRecipes = responseFavRecipe.body;
    final jsonFavRecipe = jsonDecode(respFavRecipes)["message"];
    setState(() {
      myFavorite = jsonFavRecipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text("Favorites"),
            centerTitle: true,
            backgroundColor: Colors.red,
          ),
          SliverGrid(
            delegate:SliverChildBuilderDelegate(
              (BuildContext context,index){
                return GestureDetector(
                  onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [myFavorite[index]["idRecipe"],true,"myFavorite"]);},
                  child: Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl:("http://3.23.131.0:3002/"+(myFavorite[index]["recipe"]["image_recipes"][0]["route"]).replaceAll(r"\",'/')),
                                progressIndicatorBuilder: (context, url, downloadProgress) => 
                                  Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                fit: BoxFit.cover,
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
                              Text(myFavorite[index]["recipe"]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.timer,color: Colors.grey,size: 11,),
                                  SizedBox(width: 5,),
                                  Text(myFavorite[index]["recipe"]["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
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
              childCount: myFavorite.length
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 4,
              childAspectRatio: 0.8
            )
          )
        ],
      ),
    );
  }
}