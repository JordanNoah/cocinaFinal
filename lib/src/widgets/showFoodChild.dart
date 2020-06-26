import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/src/widgets/addCommentary.dart';
import 'package:food_size/src/widgets/checkboxs.dart';
import 'package:food_size/src/widgets/favoriteRecipe.dart';
import 'package:food_size/src/widgets/menuRecipe.dart';
import 'package:food_size/src/widgets/recipeDifficulty.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_color/random_color.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ShowFoodChild extends StatefulWidget {
  final List data;
  final Recipe recipe;
  final List recipeSteps;
  final List recipeIngredients;
  final List recipeComments;
  final List allImages;
  final List recipeImages;
  final bool liked;
  ShowFoodChild({Key key,@required this.data,@required this.recipe,@required this.recipeSteps,@required this.recipeIngredients, this.recipeComments, this.allImages, @required this.recipeImages, this.liked}) : super(key: key);

  @override
  _ShowFoodChildState createState() => _ShowFoodChildState(this.data,this.recipe,this.recipeSteps,this.recipeIngredients,this.recipeComments,this.allImages,this.recipeImages,this.liked);
}

class _ShowFoodChildState extends State<ShowFoodChild> {
  List data;
  Recipe recipe;
  List recipeSteps;
  List recipeIngredients;
  List recipeComments;
  List allImages;
  List recipeImages;
  bool liked;
  _ShowFoodChildState(this.data,this.recipe,this.recipeSteps,this.recipeIngredients,this.recipeComments,this.allImages,this.recipeImages,this.liked);

  bool titleWarped = false;
  
  Directory extDirec;

  @override
  void initState() { 
    super.initState();
    getDirectory();
  }

  Future getDirectory() async {
    final Directory extDir = await getExternalStorageDirectory();
    if(mounted){
      setState(() {
        extDirec = extDir;
      });
    }
    print(extDirec);
  }

  @override
  Widget build(BuildContext context) {
    RandomColor _randomColor = RandomColor();
    Color _color = _randomColor.randomColor();
    return NotificationListener<ScrollUpdateNotification>(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: _color,
            flexibleSpace: FlexibleSpaceBar(
              title: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 200
                ),
                child: Text(recipe.title,overflow: titleWarped?TextOverflow.ellipsis:TextOverflow.visible,),
              ),
              background: Builder(builder: (BuildContext context) {
                if (data[1]) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl:("http://3.23.131.0:3002/"+(recipeImages[0]["route"]).replaceAll(r"\",'/')),
                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                        Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                      errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                      fit: BoxFit.cover,
                    ),
                  );
                }else{
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    child: FutureBuilder(
                      future: ClientDatabaseProvider.db.getImgProfileRecipe(recipe.idRecipe),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        var image = snapshot.data!=null ? File(extDirec.path+'/recipes/recipe/${snapshot.data}'):null;
                        return image == null ? Center(child: CircularProgressIndicator(),): Image.file(image,fit: BoxFit.cover,);
                      },
                    ),
                  );
                }
              }),
            ),
            actions: <Widget>[
              Builder(builder: (BuildContext context){
                if(data[1]){
                  return FavoriteRecipe(liked: liked,idRecipe: recipe.idRecipe,);
                }else{
                  return Container();
                }
              }),
              MenuRecipe(recipeInformation: recipe,recipeSteps: recipeSteps,recipeIngredients: recipeIngredients,allImages: allImages,recipeImages: recipeImages,)
            ],
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
                            child:Text(recipe.description,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600,letterSpacing: 1),),
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
                                  Text(recipe.aproxTime,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text("Difficulty",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,letterSpacing: 1)),
                              SizedBox(height: 10,),
                              RecipeDifficulty(recipe.difficulty)
                            ],
                          )
                        ],
                      ),
                    ),
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
                              child: Builder(builder: (BuildContext context) {
                                if(data[1]){
                                  return CachedNetworkImage(
                                    imageUrl:("http://3.23.131.0:3002/"+(recipeIngredients[index]["ingredient"]["routeImage"]).replaceAll(r"\",'/')),
                                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                                      Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                    errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                                    fit: BoxFit.cover,
                                  );
                                }else{
                                  return FutureBuilder(
                                    future: ClientDatabaseProvider.db.getImgIngredient(recipeIngredients[index]["idIngredient"]),
                                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                                      var image = snapshot.data!=null ? File(extDirec.path+'/recipes/ingredient/${snapshot.data}'):null;
                                      return image == null ? Center(child: CircularProgressIndicator(),): Image.file(image,fit: BoxFit.cover,);
                                    },
                                  );
                                  // return Image.file(File(extDirec.path+'/recipes/ingredient/'+recipeIngredients[index]["routeImage"]),fit: BoxFit.cover,);
                                }
                              })
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
                                  Text(data[1]?recipeIngredients[index]["ingredient"]["name"]:recipeIngredients[index]["name"].toString(),overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                  Text((recipeIngredients[index]["quantity"]).toString(),overflow: TextOverflow.ellipsis,)
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Checkboxs()
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
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 30),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text("Steps",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                    ),
                  ],
                ),
              )
            ])
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
                            child: Checkboxs()
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text(recipeSteps[index]["description"],style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600,letterSpacing: 1),),
                      )
                    ],
                  )
                );
              },
              childCount: recipeSteps.length
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Builder(builder: (BuildContext context) {
                if(data[1]){
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 30),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text("Comentarios",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                        ),
                      ],
                    ),
                  );
                }else{
                  return Container();
                }
              },)
            ])
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Builder(builder: (BuildContext context){
                if(data[1]){
                  return Container(
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recipeComments.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index){
                        return Card(
                          elevation: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: CircleAvatar(
                                    radius: 25,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Text(recipeComments[index]["users"][0]["names"].toString())
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: SmoothStarRating(
                                            allowHalfRating: true,
                                            starCount: 5,
                                            rating: recipeComments[index]["assessment"].toDouble(),
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
                                          child: Text(recipeComments[index]["commentary"].toString())
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: GestureDetector(
                                    onTap: (){},
                                    child: Icon(Icons.flag),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }else{
                  return Container();
                }
              })
            ]),
          ),
          SliverList(delegate: SliverChildListDelegate([
            Builder(builder: (BuildContext context){
              if(data[1]){
                return Row(
                  children: <Widget>[
                    FlatButton.icon(
                      icon: Icon(Icons.add_comment),
                      label: Text("Write your review"),
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (_){
                            return AddCommentary(idUser: 1, idRecipe: recipe.idRecipe);
                          }
                        );
                      },
                    )
                  ],
                );
              }else{
                return Container();
              }
            })
          ]),)
        ],
      ),
      onNotification: (notification) {
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
    );
  }
  void moreInformation(ingredient){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: data[1]?Text(ingredient["ingredient"]["name"].toString()):Text(ingredient["name"].toString()),
          elevation: 5,
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 230,
                    width: MediaQuery.of(context).size.width,
                    child: Builder(builder: (BuildContext context) {
                      if(data[1]){
                        return CachedNetworkImage(
                          imageUrl:("http://3.23.131.0:3002/"+(ingredient["ingredient"]["routeImage"]).replaceAll(r"\",'/').toString()),
                          progressIndicatorBuilder: (context, url, downloadProgress) => 
                            Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.error),),
                          fit: BoxFit.cover,
                        );
                      }else{
                        return Image.file(File(extDirec.path+'/recipes/ingredient/'+ingredient["routeImage"]),fit: BoxFit.cover,);
                      }
                    })
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text(ingredient["quantity"]),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}