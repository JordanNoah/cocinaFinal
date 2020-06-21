import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

class MostVotedRecipe extends StatefulWidget {
  MostVotedRecipe({Key key}) : super(key: key);

  @override
  _MostVotedRecipe createState() => _MostVotedRecipe();
}

class _MostVotedRecipe extends State<MostVotedRecipe> {
  Future mostVotedRecipes(List existingId) async{
    try {
      http.Response responseMostVotedRecipe = await http.get('http://3.23.131.0:3002/api/getLikedRecipe?idsRecipes=$existingId');
      if(responseMostVotedRecipe.statusCode == HttpStatus.ok){
        var result=jsonDecode(responseMostVotedRecipe.body)["message"];
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
    List existingId;
    return FutureBuilder(
      future: mostVotedRecipes(existingId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
            return Center(child: Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.done) {
            List mostVotedRecipe = snapshot.data;
            RefreshController _mostVotedController = RefreshController();
            if(mostVotedRecipe.length>0){
              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(15),
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
                  Container(
                    height: 240,
                    width: MediaQuery.of(context).size.width,
                    child: SmartRefresher(
                      enablePullDown: false,
                      enablePullUp: true,
                      scrollDirection: Axis.horizontal,
                      footer: CustomFooter(
                        builder: (BuildContext context,LoadStatus mode){
                          Widget body ;
                          if(mode==LoadStatus.idle){
                            body = Center(
                              child: GestureDetector(
                                onTap: (){Navigator.pushNamed(context, '/listFood',arguments: ["Most voted"]);},
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.arrow_forward_ios,size: 14),
                                    Text("See more",style: TextStyle(fontSize: 10,))
                                  ],
                                ),
                              ),
                            );
                          }
                          else if(mode==LoadStatus.loading){
                            body =  Container(
                              padding: EdgeInsets.only(left: 15),
                              width: 105,
                              height: 170,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: CupertinoActivityIndicator()
                              )
                            );
                          }
                          else if(mode == LoadStatus.failed){
                            body = Text("Load Failed!Click retry!");
                          }
                          else if(mode == LoadStatus.canLoading){
                              body = Text("");
                          }
                          else{
                            body = Text("No more Data");
                          }
                          return Container(
                            height: 55.0,
                            child: Center(child:body),
                          );
                        },
                      ),
                      controller: _mostVotedController,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 222,
                            margin: EdgeInsets.symmetric(horizontal: 15),
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              itemCount: mostVotedRecipe.length,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [mostVotedRecipe[index]['idRecipe'],true]);},
                                            child: Container(
                                              width: 145,
                                              height: 190,
                                              child: Stack(
                                                children: <Widget>[
                                                  Container(
                                                    height: MediaQuery.of(context).size.height,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: CachedNetworkImage(
                                                        imageUrl: "http://3.23.131.0:3002/"+(mostVotedRecipe[index]["recipe"]["recipe_images"][0]["route"]).replaceAll(r"\",'/'),
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
                                                        topLeft: Radius.circular(20),
                                                        topRight: Radius.circular(20)
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 135,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(height: 5,),
                                            Text(mostVotedRecipe[index]["recipe"]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.timer,color: Colors.grey,size: 11,),
                                                SizedBox(width: 5,),
                                                Text(mostVotedRecipe[index]["recipe"]["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    ),
                  ),
                ],
              );
            }else{
              return Container();
            }
        } else {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Most voted",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
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

class Failure {
  // Use something like "int code;" if you want to translate error messages
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

// RefreshController _mostVotedController = RefreshController();
//   List liked = [];
//   List mostVotedRecipe = [];
//   bool reachFinal = false;
//   List existingId=[];

//   List favorites=[];

//   @override
//   void initState() {
//     super.initState();
//     getIdsLikedRecipe();
//     mostVotedRecipes();
//   }

//   Future getIdsLikedRecipe() async{
//     try {
//       http.Response responseLiked = await http.get('http://3.23.131.0:3002/api/getIdsLikedRecipe?idUser=1');
//       if(responseLiked.statusCode == HttpStatus.ok){
//         var ids=jsonDecode(responseLiked.body)["message"];
//         for(var idrecipe in ids){
//           favorites.add(idrecipe["idRecipe"]);
//         }
//         setState(() {});
//       }
//     } on Exception catch (e) {
//       if(e.toString().contains('SocketException')){
//         setState(() {
//         });
//       }
//     }
//   }

//   void mostVotedRecipes() async{
//     try {
//       if(!reachFinal){
//         http.Response responseMostVotedRecipe = await http.get('http://3.23.131.0:3002/api/getLikedRecipe?idsRecipes=$existingId');
//         if(responseMostVotedRecipe.statusCode == HttpStatus.ok){
//           final List result = jsonDecode(responseMostVotedRecipe.body)["message"];
//           for(var recipe in result){
//             mostVotedRecipe.add(recipe);
//             existingId.add(recipe["idRecipe"]);
//           }
//           if(result.length==0){reachFinal=true;}
//           if(mostVotedRecipe.length>10){
//             reachFinal=true;
//           }
//         }
//       }
//     } on Exception catch (e) {
//       if(e.toString().contains('SocketException')){
//         setState(() {
//           mostVotedRecipe=null;
//         });
//       }
//     }
//     setState(() {});
//     _mostVotedController.loadComplete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if(mostVotedRecipe!=null){
//       if(mostVotedRecipe.length!=0){
//         return Container(
//           height: 200,
//           child: 
//         );
//       }else{
//         return Container();
//       }
//     }else{
//       return Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               "Refresh most voted",
//               style: TextStyle(fontSize: 30,),textAlign: TextAlign.center,
//             ),
//             IconButton(
//               icon: Icon(Icons.refresh),
//               onPressed: (){mostVotedRecipes();},
//               iconSize: 50,
//             )
//           ],
//         ),
//       );
//     }
//   }


// 