import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/widgets/recipeDifficulty.dart';
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
      http.Response responseRecipe = await http.get("http://3.23.131.0:3002/api/getRandomRecipe?idExisting=$idRecipes");
      String resRecipe = responseRecipe.body;
      final jsonRecipe = jsonDecode(resRecipe);
      setState(() {
        recipes=jsonRecipe;
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
      http.Response responseRecipe = await http.get("http://3.23.131.0:3002/api/getRandomRecipe?idExisting=$idRecipes");
      String resRecipe = responseRecipe.body;
      final List jsonRecipe = jsonDecode(resRecipe);
      if(jsonRecipe.length==0){reachFinalRecipe=true;}
      for (var recipe in jsonRecipe) {
        idRecipes.add(recipe["idRecipe"]);
        recipes.add(recipe);
      }
    } catch (e) {
      print(e);
    }
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if(mounted)
    setState(() {

    });
    _refreshController.loadComplete();
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
      body: SafeArea(
        child: checkConnection?SmartRefresher(
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
          child: ListView.builder(
            itemBuilder: (c, i) => Container(
              margin: EdgeInsets.all(10),
              child: GestureDetector(
                onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [recipes[i]['idRecipe'],true]);},
                child: AnimatedContainer(
                  curve: Curves.elasticIn,
                  duration: Duration(milliseconds: 4000000),
                  child: Card(
                    elevation: 1,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            // color: Colors.red,
                            height: MediaQuery.of(context).size.height,
                            margin: EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: "http://3.23.131.0:3002/"+(recipes[i]["image_recipes"][0]["route"]).replaceAll(r"\",'/'),
                                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                                    Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                  errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          )
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: ClipRRect(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(recipes[i]["title"].toString(),style: TextStyle(fontWeight: FontWeight.bold,letterSpacing: 1,fontSize: 18),overflow: TextOverflow.ellipsis,),
                                  Text(recipes[i]["description"].toString(),overflow: TextOverflow.ellipsis,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.av_timer,color: Colors.grey,),
                                          SizedBox(width: 2.0,),
                                          Text(recipes[i]["approximateTime"].toString(),style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                        ],
                                      ),
                                      RecipeDifficulty(recipes[i]["difficulty"]),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                        )
                      ],
                    )
                  ),
                ),
              ),
            ),
            itemExtent: 130.0,
            itemCount: recipes.length,
          ),
        ):Center(child: Text("Not connection"),),
      ),
    );
  }
}
