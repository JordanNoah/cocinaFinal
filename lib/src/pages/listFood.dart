import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_size/src/widgets/showRate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:http/http.dart' as http;

class ListFood extends StatefulWidget {
  final List data;
  ListFood({Key key,@required this.data}) : super(key: key);

  @override
  _ListFoodState createState() => _ListFoodState(data);
}

class _ListFoodState extends State<ListFood> {
  List data;
  _ListFoodState(this.data);
  bool checkConnection = true;


  List recipes = [];
  List idRecipes = [];
  List<StaggeredTile> _tiles;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool reachFinalRecipe = false;

  @override
  void initState() { 
    super.initState();
    // connectionState();
    getRecipes();
  }

  // Future connectionState() async {
  //   bool actualStateConnection = await DataConnectionChecker().hasConnection;
  //   setState((){
  //     checkConnection = actualStateConnection;
  //   });
  // }

  Future getRecipes() async{
    idRecipes.clear();
    try {
      http.Response responseRecipe;
      responseRecipe = await http.get("http://3.23.131.0:3002/api/getRecipePerFilter?filter="+data[0]+"&idRecipes="+idRecipes.toString());
      String resRecipe = responseRecipe.body;
      final jsonRecipe = jsonDecode(resRecipe)["message"];
      setState(() {
        recipes=jsonRecipe;
        _tiles = _generateRandomTiles(recipes).toList();
      });
      for (var recipe in recipes) {
        idRecipes.add(recipe["idRecipe"]);
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          checkConnection = true;
        });
      }
    }
  }

  void _onRefresh() async{
    // monitor network fetch
    await getRecipes();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    try {
      http.Response responseRecipe;
      responseRecipe = await http.get("http://3.23.131.0:3002/api/getRecipePerFilter?filter="+data[0]+"&idRecipes="+idRecipes.toString());
      String resRecipe = responseRecipe.body;
      final List jsonRecipe = jsonDecode(resRecipe)["message"];
      if(jsonRecipe.length==0){reachFinalRecipe=true;}
      for (var recipe in jsonRecipe) {
        idRecipes.add(recipe["idRecipe"]);
        recipes.add(recipe);
      }
      setState(() {
        _tiles = _generateRandomTiles(recipes).toList();
      });
      _refreshController.loadComplete();
    } catch (e) {
      print(e);
      _refreshController.loadFailed();
    }
    // if failed,use loadFailed(),if no data return,use LoadNodata()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data[0],style: TextStyle(color: Colors.grey,)),
        backgroundColor: Colors.white10,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.grey,),
          onPressed: (){Navigator.pushNamed(context, "/");},
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            color: Colors.grey,
            onPressed: (){},
          )
        ],
      ),
      body:Container(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context,LoadStatus mode){
              Widget body ;
              if(mode==LoadStatus.idle){
                body =  reachFinalRecipe ? Text("Has reach the final") : Text("pull up load");
              }
              else if(mode==LoadStatus.loading){
                body =  CupertinoActivityIndicator();
              }
              else if(mode == LoadStatus.failed){
                body = Text("Load Failed!Click retry!");
              }
              else if(mode == LoadStatus.canLoading){
                  body = Text("release to load more");
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
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: StaggeredGridView.countBuilder(
            primary: false,
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            addRepaintBoundaries: true,
            crossAxisCount: 4,
            itemBuilder: _getChild,
            staggeredTileBuilder: _getTile,
            itemCount: recipes.length,
          )
        ),
      ),
    );
  }
  StaggeredTile _getTile(int index) => _tiles[index];

  Widget _getChild(BuildContext context, int index) {
    return GestureDetector(
      onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipes[index]["idRecipe"],true]);},
      child: Container(
        key: ObjectKey('$index'),
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: "http://3.23.131.0:3002/"+(recipes[index]["recipe_images"][0]["route"]).replaceAll(r"\",'/'),
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
                    Text(recipes[index]["title"],textAlign: TextAlign.left,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    SizedBox(height: 5,),
                    ShowRate(countOfReview: recipes[index]["countOfReview"],totalAssessment: recipes[index]["totalAssessment"],)
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}
List<StaggeredTile> _generateRandomTiles(List recipes) {
  return List.generate(recipes.length,
      (i) => StaggeredTile.fit(2));
}