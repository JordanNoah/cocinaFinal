import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/models/stepsRecipe_model.dart';
import 'package:food_size/src/widgets/addCommentary.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:random_color/random_color.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ShowFood extends StatefulWidget {
  final List data;
  ShowFood({Key key,@required this.data}) : super(key: key);

  @override
  _ShowFoodState createState() => _ShowFoodState(data);
}

class _ShowFoodState extends State<ShowFood> {

  RandomColor _randomColor = RandomColor();
  Color _color;
  List data;
  bool itsDownloaded = false;
  _ShowFoodState(this.data);
  Directory extDirec;
  bool checkConnection = false;
  bool titleWarped = false;

  var recipe;
  List imagesRecipe=[];
  List recipeIngredients = [];
  List stepsRecipe = [];
  List randomRecipe = [];
  int cantDishes=1;
  List selectedIngredients=[];
  List selectedSteps=[];
  List comentaries = [];

  double rating = 0;
  
  List menuList = [];

  @override
  void initState() { 
    super.initState();
    loadRecipe();
    _color = _randomColor.randomColor();
  }

  void _onIngredientSelected(bool selected,ingredientId){
    if (selected) {
        selectedIngredients.add(ingredientId);
    } else {
        selectedIngredients.remove(ingredientId);
    }
    setState(() {});
  }

  void _onStepSelected(bool selected,stepId){
    if(selected){
        selectedSteps.add(stepId);
    }else{
        selectedSteps.remove(stepId);
    }
    setState(() {});
  }
  
  Future loadRecipe() async{
    if (data[1]) {
      try {
        http.Response responseRecipe = await http.get('http://192.168.100.54:3002/api/getRecipe?idRecipe='+data[0].toString());
        String resRecipe = responseRecipe.body;
        final jsonRecipe = jsonDecode(resRecipe)["message"];
        http.Response responseComentaries = await http.get('http://192.168.100.54:3002/api/getCommentRecipe');
        String resComentaries = responseComentaries.body;
        final jsonCommentaries = jsonDecode(resComentaries);
        setState(() {
          recipe=jsonRecipe;
          recipeIngredients=recipe["recipe_ingredients"];
          stepsRecipe = recipe["step_recipes"];
          imagesRecipe = recipe["image_recipes"];
          comentaries = jsonCommentaries;
        });
        print("http://192.168.100.54:3002/"+(imagesRecipe[0]["route"]));
      } catch (e) {
      }
    } else {
      var recipeDatabase = await ClientDatabaseProvider.db.getRecipeWithId(data[0]);
      Recipe recipeClass=recipeDatabase;
      var imageRecipeDatabase = await ClientDatabaseProvider.db.getImage(data[0]);
      setState(() {
        imagesRecipe=imageRecipeDatabase;
      });
      var stepsDatabase = await ClientDatabaseProvider.db.getStepsRecipeWithId(data[0]);
      for(var steps in stepsDatabase){
        StepsRecipe step = steps;
        stepsRecipe.add({
          "idStep":step.idStep,
          "description":step.description,
          "stepNumber":step.stepNumber,
          "idRecipe":step.idRecipe
        });
      }
      var ingredientsDatabase = await ClientDatabaseProvider.db.getIngredientsRecipeWithId(data[0]);
      for(var ingredient in ingredientsDatabase){
        recipeIngredients.add({
          "idRecipeIngredient":ingredient["idRecipeIngredient"],
          "quantity":ingredient["quantity"],
          "optional":ingredient["optional"]==0?false:true,
          "moreOptions":ingredient["moreOptions"],
          "idIngredient":ingredient["idIngredient"],
          "idRecipe":ingredient["idRecipe"],
          "ingredient":{
            "idIngredient":ingredient["idIngredient"],
            "name":ingredient["name"],
            "routeImage":ingredient["routeImage"]
          }
        });
      }
      final Directory extDir = await getExternalStorageDirectory();
      bool actualStateConnection = await DataConnectionChecker().hasConnection;
      setState(() {
        extDirec = extDir;
        checkConnection=actualStateConnection;
        recipe={"idRecipe":(recipeClass.idRecipe),"description":recipeClass.description,"title":recipeClass.title,"difficulty":recipeClass.difficulty,"approximateTime":recipeClass.aproxTime};
      });
    }

    recipeInside();
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: recipe==null?Center(child: Text("Cargando"),):NotificationListener<ScrollUpdateNotification>(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              // floating: true,
              pinned: true,
              backgroundColor: _color,
              flexibleSpace: FlexibleSpaceBar(
                title: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 200
                  ),
                  child: Text(recipe["title"],overflow: titleWarped?TextOverflow.ellipsis:TextOverflow.visible,),
                ),
                background: Container(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 280,
                        child: data[1]
                          ?
                            CachedNetworkImage(
                              imageUrl:("http://192.168.100.54:3002/"+(imagesRecipe[0]["route"]).replaceAll(r"\",'/')),
                              progressIndicatorBuilder: (context, url, downloadProgress) => 
                                Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                              errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                              fit: BoxFit.cover,
                            )
                              :
                                FutureBuilder(
                                  future: ClientDatabaseProvider.db.getImgProfileRecipe(recipe["idRecipe"]),
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    var image = snapshot.data!=null ? File(extDirec.path+'/recipes/recipe/${snapshot.data}'):null;
                                    return image == null ? Center(child: CircularProgressIndicator(),): Image.file(image,fit: BoxFit.cover,);
                                  },
                                ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:[
                              Colors.transparent,
                              Colors.black87
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter
                          )
                        ),
                      )
                    ],
                  ),
                )
              ),
              actions: <Widget>[
                    PopupMenuButton(
                      itemBuilder: (_) => <PopupMenuItem<dynamic>>[

                        new PopupMenuItem<dynamic>(
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 3),
                                child: Icon(Icons.play_circle_outline,color: Colors.black,)
                              ),
                              Text('Play recipe')
                            ],
                          ), 
                          value: 'play'
                        ),
                        new PopupMenuItem<dynamic>(
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 3),
                                child: itsDownloaded?Icon(Icons.delete_outline, color: Colors.black,):Icon(Icons.cloud_download,color: Colors.black,),
                              ),
                              Text(itsDownloaded?'Remove':'Download')
                            ],
                          ), value: itsDownloaded?'remove':'download'
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'play' : 
                            Navigator.of(context).pushNamed("/playRecipie",arguments: recipe);
                            break;
                          case 'download':
                          downloadRecipe();
                            break;
                          case 'remove':
                            removeDownload();
                            break;
                          default:
                          recipeInside();
                        }
                      }
                    )
              ],
              elevation: 0,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  margin: EdgeInsets.all(15),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10),
                              child: Text("Descripción",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                            ),
                            Container(
                              child:Text(recipe["description"],style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600,letterSpacing: 1),),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text("Approximate time",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,letterSpacing: 1)),
                                SizedBox(height: 10,),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.av_timer,color: Colors.grey,),
                                    SizedBox(width: 2.0,),
                                    Text(recipe["approximateTime"],style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: <Widget>[
                                Text("Difficulty",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,letterSpacing: 1)),
                                SizedBox(height: 10,),
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
                                              color: recipe["difficulty"]=="Medium"||recipe["difficulty"]=="Hard"?Colors.orange:Colors.transparent,
                                            ),
                                          ),
                                          Container(
                                            height: 10,
                                            width: 16.66,
                                            decoration: BoxDecoration(
                                              color:recipe["difficulty"]=="Hard" ? Colors.orange : Colors.transparent,
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
                                      child: Text(recipe["difficulty"],style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,letterSpacing: 1),),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(top:15),
                      //   child: Text("Number of dishes",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                      // ),
                      // Container(
                      //   margin: EdgeInsets.only(top: 20),
                      //   child: Column(
                      //     children: <Widget>[
                      //       Container(
                      //         height: 60,
                      //         width: MediaQuery.of(context).size.width,
                      //         decoration: BoxDecoration(
                      //           color: Colors.blue.withOpacity(0.2),
                      //           borderRadius: BorderRadius.circular(40)
                      //         ),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //           children: <Widget>[
                      //             Container(
                      //               margin: EdgeInsets.only(left: 15),
                      //               child: IconButton(
                      //                 color: cantDishes!=1?Colors.black:Colors.grey,
                      //                 icon: Icon(Icons.remove),
                      //                 onPressed: (){
                      //                   setState(() {
                      //                     if (cantDishes>1) {
                      //                       cantDishes=cantDishes-1;
                      //                     }
                      //                   });
                      //                 },
                      //               ),
                      //             ),
                      //             Container(
                      //               height: 60,
                      //               width: 60,
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(40),
                      //                 color: Colors.white,
                      //               ),
                      //               child: Center(
                      //                 child: Text(cantDishes.toString() ,style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20,letterSpacing: 1),),
                      //               ),
                      //             ),
                      //             Container(
                      //               margin: EdgeInsets.only(right: 15),
                      //               child: IconButton(
                      //                 icon: Icon(Icons.plus_one),
                      //                 color: cantDishes!=16?Colors.black:Colors.grey,
                      //                 onPressed: (){
                      //                   setState(() {
                      //                     if(cantDishes<16){
                      //                       cantDishes=cantDishes+1;
                      //                     }
                      //                   });
                      //                 },
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text("Ingredientes",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                )
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context,index){
                  return InkWell(
                    onTap: (){
                      moreInformation(recipeIngredients[index]);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                      height: 65,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Container(
                        margin: EdgeInsets.all(7),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: data[1]
                                  ?
                                    CachedNetworkImage(
                                      imageUrl:("http://192.168.100.54:3002/"+(recipeIngredients[index]["ingredient"]["routeImage"]).replaceAll(r"\",'/')),
                                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                                        Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                      fit: BoxFit.cover,
                                    )
                                      :
                                        Image.file(File(extDirec.path+'/recipes/ingredient/'+recipeIngredients[index]["ingredient"]["routeImage"]),fit: BoxFit.cover,)
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(recipeIngredients[index]["ingredient"]["name"],overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                    Text((recipeIngredients[index]["quantity"]).toString(),overflow: TextOverflow.ellipsis,)
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Checkbox(
                                value: selectedIngredients.contains(recipeIngredients[index]["idRecipeIngredient"]),
                                onChanged: (bool value){
                                  _onIngredientSelected(value,recipeIngredients[index]["idRecipeIngredient"]);
                                },
                              ),
                            )
                          ],
                        ),
                      )
                    ),
                  );
                },
                childCount: recipeIngredients.length
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text("Pasos",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                  )
                )
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context,index){
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    width: MediaQuery.of(context).size.width,
                    child:Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Center(
                                child: Text((index+1).toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                            ),
                            Container(
                              child: Checkbox(
                                value: selectedSteps.contains(stepsRecipe[index]["idStep"]), 
                                onChanged: (bool value){
                                  _onStepSelected(value,stepsRecipe[index]["idStep"]);
                                }
                              ),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          child: Text(stepsRecipe[index]["description"],style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600,letterSpacing: 1),),
                        )
                      ],
                    )
                  );
                },
                childCount: stepsRecipe.length
              ),
            ),
            ///////////comentaries
            data[1]
              ?
                SliverList(
                  delegate: SliverChildListDelegate([
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text("Comentaries",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                      )
                    )
                  ]),

                )
                  :
                    SliverList(delegate: SliverChildListDelegate([]),),
            data[1]
              ?
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context,index){
                      return Card(
                        child: Container(
                          margin: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(vertical: (12)),
                                child: CircleAvatar(
                                  radius: 25,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        child: Text(comentaries[index]["user"]["names"])
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: SmoothStarRating(
                                          allowHalfRating: true,
                                          starCount: 5,
                                          rating: comentaries[index]["assessment"].toDouble(),
                                          size: 20.0,
                                          filledIconData: Icons.star,
                                          halfFilledIconData: Icons.star_half,
                                          color: Colors.green,
                                          borderColor: Colors.green,
                                          spacing:0.0
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 5),
                                        child: Text(comentaries[index]["commentary"].toString())
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                child: GestureDetector(
                                  onTap: (){print("report");},
                                  child: Icon(Icons.flag),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: comentaries.length
                  ),
                )
                  :
                    SliverList(delegate: SliverChildListDelegate([]),),
            data[1] ? SliverList(delegate: SliverChildListDelegate([
              Row(
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(Icons.add_comment),
                    label: Text("Write your review"),
                    onPressed: (){
                      showDialog(
                        context: context,
                        builder: (_){
                          return AddCommentary(idUser: 1, idRecipe: recipe["idRecipe"]);
                        }
                      );
                    },
                  )
                ],
              )
            ]),):SliverList(delegate: SliverChildListDelegate([]),),
            ////////////////
          ],
        ),
        onNotification: (notification) {
          // print(notification.scrollDelta);
          if(notification.metrics.pixels>182){
            if(!titleWarped){
              setState(() {
                titleWarped = true;
              });
            }
          }else{
            if(titleWarped){
              setState(() {
                titleWarped = false;
              });
            }
          }
        },
      ),
    );
  }
  void removeDownload(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Remove download"),
          elevation: 5,
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("¿Would you like to remove this recipe?"),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text("Cancelar",style: TextStyle(color: Colors.red),),
              onPressed: (){Navigator.of(context).pop();},
            ),
            MaterialButton(
              child: Text("Remove",style: TextStyle(color: Colors.green),),
              onPressed: (){removeRecipe();},
            ),
          ],
        );
      }
    );
  }

  void recipeInside() async {
    var getRecipe=Recipe(idRecipe: recipe["idRecipe"],description: recipe["description"],title: recipe["title"],aproxTime: recipe["approximateTime"],difficulty: recipe["difficulty"]);
    var response = await ClientDatabaseProvider.db.getRecipeWithId(getRecipe.idRecipe);
    if (response==null) {
      setState(() {
        itsDownloaded=false;
      });
    } else {
      setState(() {
        itsDownloaded=true;
      });
    }
  }

  void moreInformation(ingredient){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(ingredient["ingredient"]["name"].toString()),
          elevation: 5,
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 230,
                    width: MediaQuery.of(context).size.width,
                    child: data[1]
                      ?
                        Image.network("http://192.168.100.54:3002/"+(ingredient["ingredient"]["routeImage"]).replaceAll(r"\",'/').toString(),fit: BoxFit.cover,)
                          :
                            Image.file(File(extDirec.path+'/recipes/ingredient/'+ingredient["ingredient"]["routeImage"])),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text(newCant(ingredient["quantity"]).toString()),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void removeRecipe() async {
    var recipes = Recipe(idRecipe: recipe["idRecipe"],description: recipe["description"],title: recipe["title"],aproxTime: recipe["approximateTime"],difficulty: recipe["difficulty"]);
    var removed = await ClientDatabaseProvider.db.removeRecipe(recipes);
    // 1 means success, 2 means error while remove, 3 means reicipe dont exist in database
    if(removed==1 || removed==3){
      Navigator.of(context).pop();
      if(!data[1]){
        Navigator.pushNamed(context, '/');
      }else{
        setState(() {
          itsDownloaded=false;
        });
      }
    }
  }

  newCant(String descIngredient){
    var split = descIngredient.split(" ");
    var concatenate = StringBuffer();
    for(int i=0;i<split.length;i++){
      var isNumber = (split[i].startsWith(RegExp(r'[0-9]')));
      if(isNumber){
        split[i]=(int.parse(split[i])*cantDishes).toString();
      }
    }
    split.forEach((item){
      concatenate.write(item+" ");  
    });
    return concatenate;
  }

  void downloadRecipe() async {
    var recipeObj = Recipe(idRecipe: recipe["idRecipe"],description: recipe["description"],title: recipe["title"],aproxTime: recipe["approximateTime"],difficulty: recipe["difficulty"]);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context){
        return Dialog(
          backgroundColor: Colors.transparent,
          child: itsDownloaded
            ?
              Center(
                child: CircularProgressIndicator(),
              )
                :
                  Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                          top: Consts.avatarRadius + Consts.padding,
                          bottom: Consts.padding,
                          left: Consts.padding,
                          right: Consts.padding,
                        ),
                        margin: EdgeInsets.only(top: Consts.avatarRadius),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(Consts.padding),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: const Offset(0.0, 10.0),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // To make the card compact
                            children: <Widget>[
                              Text("La descarga ha finalizado correctamente",style: TextStyle(fontSize: 20,letterSpacing: 1),),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // To close the dialog
                                      },
                                      child: Text("Close",style: TextStyle(color: Colors.red),),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: Consts.padding,
                        right: Consts.padding,
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 45,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage("assets/images/downloadDone.gif"),
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
        );
      }
    );
    var existRecipe = await ClientDatabaseProvider.db.getRecipeWithId(recipeObj.idRecipe);
    print(existRecipe);
    if (existRecipe==null) {
      var response = await ClientDatabaseProvider.db.addRecipeToDatabase(recipeObj,stepsRecipe,imagesRecipe,recipeIngredients,true);
      if (response==1) {
        setState(() {
          itsDownloaded = true;
        });
      }else{
        setState(() {
          itsDownloaded = true;
        });
      }
    }
  }
}