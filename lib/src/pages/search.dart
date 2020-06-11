import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/widgets/favoriteRecipe.dart';
import 'package:http/http.dart' as http;

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var _textController = TextEditingController();
  List searchRecipes = [];
  List liked = [];

  bool hasLetter = false;

  @override
  void initState() { 
    super.initState();
    randomRecipes();
  }
  
  Future searchRecipe(String query) async{
    try {
      http.Response responseRecipe = await http.get('http://3.23.131.0:3002/api/searchRecipe?querySearch=$query');
      if(responseRecipe.statusCode == HttpStatus.ok){
        searchRecipes = jsonDecode(responseRecipe.body)["message"];
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        
      }
    }
    setState(() {});
  }

  Future randomRecipes() async{
    try {
      http.Response responseRandomRecipe = await http.get('http://3.23.131.0:3002/api/getRandomRecipe?idExisting=[]');
      if(responseRandomRecipe.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseRandomRecipe.body);
        setState(() {
          searchRecipes=result;
        });
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          searchRecipes = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Card(
                elevation: 9,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        autocorrect: false,
                        onChanged: (text){
                          searchRecipe(text);
                          if(text.length!=0){
                            hasLetter = true;
                          }else{
                            hasLetter = false;
                          }
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 1.0),
                            ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 1.0),
                            ),
                          hintText: "Search recipes",
                        ),
                      ),
                    ),
                    hasLetter?IconButton( 
                      onPressed: (){
                        _textController.clear();
                        setState(() {
                          hasLetter = false;
                        });
                        randomRecipes();
                      },
                      icon: Icon(Icons.close)
                    ):IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.search),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: GridView.builder(
                    itemCount: searchRecipes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                        childAspectRatio: 0.78  
                      ),
                      itemBuilder: (BuildContext context, int index){
                        return Card(
                          color: Colors.transparent,
                          elevation: 0,
                          child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(                      
                                  child: Container(
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          height:MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: CachedNetworkImage(
                                              imageUrl: "http://3.23.131.0:3002/"+(searchRecipes[index]["recipe_images"][0]["route"]).replaceAll(r"\",'/'),
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
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(5)
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
                                              child:FavoriteRecipe(liked: liked.contains(searchRecipes[index]["idRecipe"]),idRecipe: searchRecipes[index]["idRecipe"],)
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
                                    Text(searchRecipes[index]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.timer,color: Colors.grey,size: 11,),
                                        SizedBox(width: 5,),
                                        Text(searchRecipes[index]["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                        );
                      },
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}