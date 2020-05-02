import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_size/src/pages/downloads.dart';
import 'package:food_size/src/pages/favorites.dart';
import 'package:food_size/src/pages/homeFood.dart';
import 'package:http/http.dart' as http;
import 'package:full_screen_menu/full_screen_menu.dart';

class Foods extends StatefulWidget {
  Foods({Key key}) : super(key: key);

  @override
  _FoodsState createState() => _FoodsState();
}

class _FoodsState extends State<Foods> {
  bool checkConnection = false;
  PageController _controller = PageController(initialPage:0);
  List recipes = [];
  @override
  void initState(){
    super.initState();
    connectionState();
  }

  Future connectionState() async {
    bool actualStateConnection = await DataConnectionChecker().hasConnection;
    setState((){
      checkConnection = actualStateConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          PageView(
            scrollDirection: Axis.horizontal,
            controller: _controller,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              checkConnection?HomeFood():notConnection(),
              Download(),
              checkConnection?Favorites():notConnection()
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){menuFullScreen();},
        child: Container(
          padding: EdgeInsets.all(8),
          child: SvgPicture.asset('assets/images/ensalada.svg'),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color:Colors.transparent,
        elevation: 9.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0)
            ),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.home,color: Color(0xFFEF7532)), 
                      onPressed: (){
                        _controller.jumpToPage(0);
                      }
                    ),
                    IconButton(
                      icon: Icon(Icons.search,color: Color(0xFF676E79)), 
                      onPressed: (){
                        showSearch(context: context, delegate: DataSearch());
                      },
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.file_download, color: Color(0xFFEF7532),),
                      onPressed: (){
                        _controller.jumpToPage(1);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border,color: Colors.red),
                      onPressed: (){
                        _controller.jumpToPage(2);
                      },
                    )
                  ],
                ),
              )    
            ],
          ),
        ),
      ),
    );
  }
  ////////////////////////////////////////////////////
  ///
  menuFullScreen(){
    return FullScreenMenu.show(
      context,
      backgroundColor: Colors.black87,
      items: [
        FSMenuItem(
          icon: Icon(Icons.recent_actors, color: Colors.white),
          text: Text('Social Media',style: TextStyle(color: Colors.white),),
        ),
        FSMenuItem(
          icon: Icon(Icons.view_carousel, color: Colors.white),
          text: Text('Recipes',style: TextStyle(color: Colors.white),),
        ),
        FSMenuItem(
          icon: Icon(Icons.restaurant_menu, color: Colors.white),
          text: Text('Restaurants',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}

Widget notConnection(){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.signal_wifi_off,color: Colors.black54,),
        Text("Not network connection"),
        SizedBox(height: 20,),
        IconButton(
          onPressed: (){},
          icon: Icon(Icons.network_check),
        )
      ],
    ),
  );
}
class DataSearch extends SearchDelegate<String>{

  Future<List> getRecipe() async {
    var result;
    try {
      http.Response responseRandomRecipe = await http.get('http://192.168.100.54:3002/api/getRandomRecipe?idExisting=[]');
      if(responseRandomRecipe.statusCode == HttpStatus.ok){
        result = jsonDecode(responseRandomRecipe.body);
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        result = e.toString();
      }
    }
    return result;
  }

  Future<List> getSearchRecipe( String query ) async {
    var result;
    try {
      http.Response responseRecipe = await http.get('http://192.168.100.54:3002/api/searchRecipe?querySearch=$query');
      if(responseRecipe.statusCode == HttpStatus.ok){
        result = jsonDecode(responseRecipe.body)["message"];
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        result = e.toString();
      }
    }
    return result;
  }

  final cities =[
    "guayas",
    "quevedo",
    "manta",
    "quito",
    "cuenca",
    "new delhi",
    "nodia",
    "thane",
    "howrad",
    "thane",
    "guayas",
    "quevedo",
    "manta"
  ];

  final recentCities = [
    "nodia",
    "thane",
    "howrad",
    "thane"
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    // acciones para el app bar
    return [
      IconButton(icon: Icon(Icons.clear),onPressed: (){
        query = "";
      },)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // iconos para el appbar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ), 
      onPressed: (){close(context, null);}
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // mostrar resultados basados en  la seleccion
    return Container(
      height: 100.0,
      width: 100.0,
      child: Card(
        color: Colors.red,
        
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // muestras cuando alguien busca algo
    final suggestionList = query.isEmpty?getRecipe():getSearchRecipe(query);
    print(query);
    return FutureBuilder(
      future: suggestionList,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasError){
          return Center(child: Text('Error'));
        }
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasData){
            List recipes = snapshot.data;
            final orientation = MediaQuery.of(context).orientation;
            return GridView.builder(
              itemCount: recipes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
              itemBuilder: (BuildContext context,int index){
                return Container(
                  child: Card(
                    child: GestureDetector(
                      onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipes[index]['idRecipe'],true]);}, 
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
                                          child: CachedNetworkImage(
                                            imageUrl: "http://192.168.100.54:3002/"+(recipes[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
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
                              margin: EdgeInsets.only(left: 10,right: 5,top: 10,bottom: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(recipes[index]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
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
                    ),
                  ),
                );
              },
            );
          }else{
            return Center(
              child: Text("Not found"),
            );
          }
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}