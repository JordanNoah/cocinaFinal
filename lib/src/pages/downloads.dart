import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Download extends StatefulWidget {
  Download({Key key}) : super(key: key);

  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  List recipes = [];
  List idRecipes = [];
  Directory extDirec;
  List<StaggeredTile> _tiles;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool reachFinalRecipe = false;

  @override
  void initState() { 
    super.initState();
    getDirectory();
    getRecipes();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future getDirectory() async{
    final Directory extDir = await getExternalStorageDirectory();
    if (mounted) {
      extDirec = extDir;
    }
  }

  Future getRecipes() async{
    idRecipes.clear();
    try {
      var response = await ClientDatabaseProvider.db.getAllRecipes();
      if(mounted){
        recipes=response;
        _tiles = _generateRandomTiles(recipes).toList();
      }
    } on Exception catch (e) {
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
        centerTitle: true,
        elevation: 0,
      ),
      body:Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: ClientDatabaseProvider.db.getAllRecipes(),
          builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot){
            if(snapshot.hasData){
              if(snapshot.data.length!=0){
                List recipes = snapshot.data;
                return Container(
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
                );
              }else{
                return Center(
                  child: Text("No posee descargas"),
                );
              }
            }else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
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
     
      _refreshController.loadComplete();
    } catch (e) {
      _refreshController.loadFailed();
    }
    // if failed,use loadFailed(),if no data return,use LoadNodata()
  }

  StaggeredTile _getTile(int index) => _tiles[index];

  Widget _getChild(BuildContext context, int index) {
    Recipe recipeObj = this.recipes[index];
    return GestureDetector(
      onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipeObj.idRecipe ,false]);},
      child: Container(
        key: ObjectKey('$index'),
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FutureBuilder(
                future: ClientDatabaseProvider.db.getImgProfileRecipe(recipeObj.idRecipe),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  var image = snapshot.data!=null ? File(extDirec.path+'/recipes/recipe/${snapshot.data}'):null;
                  return image == null ?Center(child: CircularProgressIndicator(),) : Image.file(image,fit: BoxFit.cover,);
                },
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(recipeObj.title,textAlign: TextAlign.left,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(children: <Widget>[
                            Icon(Icons.timer,size: 15,),Text(recipeObj.aproxTime,textAlign: TextAlign.right,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10),),
                          ],),
                        ),
                        Container(
                          child: Text(recipeObj.difficulty,textAlign: TextAlign.right,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10),),
                        )
                      ],
                    )
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
// FutureBuilder(
//                 future: ClientDatabaseProvider.db.getImgProfileRecipe(recipeObj.idRecipe),
//                 builder: (BuildContext context, AsyncSnapshot snapshot) {
//                   var image = snapshot.data!=null ? File(extDirec.path+'/recipes/recipe/${snapshot.data}'):Column(children: <Widget>[Icon(Icons.warning),Text("Image not founded")],);
//                   return image == null ?Center(child: CircularProgressIndicator(),) : Image.file(image,fit: BoxFit.cover,);
//                 },
//               ),
List<StaggeredTile> _generateRandomTiles(List recipes) {
  return List.generate(recipes.length,
      (i) => StaggeredTile.fit(2));
}