import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_size/src/widgets/showRate.dart';
import 'package:http/http.dart' as http;

class RandomRecipe extends StatefulWidget {
  RandomRecipe({Key key}) : super(key: key);

  @override
  _RandomRecipeState createState() => _RandomRecipeState();
}

class _RandomRecipeState extends State<RandomRecipe> {
  Future randomRecipes() async{
    try {
      http.Response responseRandomRecipe = await http.get('http://3.23.131.0:3002/api/getRandomRecipe?idExisting=[]');
      if(responseRandomRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseRandomRecipe.body);
        // setState(() {
        //   _tiles = _generateRandomTiles(result).toList();
        // });
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
      future: randomRecipes(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.only(left: 15,right: 15,bottom: 15),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Random",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                  ],
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
            List randomRecipe = snapshot.data;
            List<StaggeredTile> _tiles = _generateRandomTiles(randomRecipe).toList();
            StaggeredTile _getTile(int index) => _tiles[index];

            Widget _getChild(BuildContext context, int index) {
              return GestureDetector(
                onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [randomRecipe[index]["idRecipe"],true]);},
                child: Container(
                  key: ObjectKey('$index'),
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.all(5),
                    child: Column(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: "http://3.23.131.0:3002/"+(randomRecipe[index]["recipe_images"][0]["route"]).replaceAll(r"\",'/'),
                          progressIndicatorBuilder: (context, url, downloadProgress) => 
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                          errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                          fit: BoxFit.cover,
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(randomRecipe[index]["title"],textAlign: TextAlign.left,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              SizedBox(height: 5,),
                              ShowRate(countOfReview: randomRecipe[index]["countOfReview"],totalAssessment: randomRecipe[index]["totalAssessment"],)
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                ),
              );
            }

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Random",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                        GestureDetector(
                          onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["Random",1]);},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                  StaggeredGridView.countBuilder(
                    primary: false,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    addRepaintBoundaries: true,
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: _getChild,
                    staggeredTileBuilder: _getTile,
                    itemCount: randomRecipe.length,
                  ),
                ],
              ),
            );
        } else {
          return Container(
            margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Random",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                  ],
                ),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          );
        }
      }
    );
  }
}

List<StaggeredTile> _generateRandomTiles(List recipes) {
  return List.generate(recipes.length,
      (i) => StaggeredTile.fit(2));
}

class Failure {
  // Use something like "int code;" if you want to translate error messages
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

// Container(
//                     margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Text("Random",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
//                         GestureDetector(
//                           onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["Random"]);},
//                           child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
//                         )
//                       ],
//                     ),
//                   ),

// randomRecipe!=null ? 
//                 SliverGrid(
//                   delegate: SliverChildBuilderDelegate(
//                     (BuildContext context, index){
//                       return RecipeDemo(title: randomRecipe[index]["title"],isFavorite: liked.contains(randomRecipe[index]["idRecipe"]),urlImage: randomRecipe[index]["recipe_images"][0][    "route"],aproxTime: randomRecipe[index]["approximateTime"],idRecipe: randomRecipe[index]["idRecipe"],);
//                     },
//                     childCount: randomRecipe.length
//                   ),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 10,
//                     crossAxisSpacing: 4,
//                     childAspectRatio: 0.7
//                   )
//                 )
//               :SliverList(
//                 delegate: SliverChildListDelegate([
//                   Container(
//                     height: 200,
//                     width: MediaQuery.of(context).size.width,
//                     child: Center(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Text(
//                             "Refresh random",
//                             style: TextStyle(fontSize: 30,),textAlign: TextAlign.center,
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.refresh),
//                             onPressed: (){},
//                             iconSize: 50,
//                           )
//                         ],
//                       ),
//                     ),
//                   )
//                 ]),
//               )