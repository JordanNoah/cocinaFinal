import 'dart:io';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/imagesRecipe.dart';
import 'package:food_size/models/ingredient.dart';
import 'package:food_size/models/ingredientsRecipe_model.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/models/stepsRecipe_model.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sqflite/sqflite.dart';

class PogressDownload extends StatefulWidget {
  final Recipe recipe;
  final List recipeImages;
  final List allImages;
  final List allSteps;
  final List allIngredients;
  PogressDownload({Key key,@required this.recipe ,@required this.recipeImages,@required this.allImages,@required this.allSteps,@required this.allIngredients}) : super(key: key);

  @override
  _PogressDownloadState createState() => _PogressDownloadState(this.recipe,this.recipeImages,this.allImages,this.allSteps,this.allIngredients);
}

class _PogressDownloadState extends State<PogressDownload> {
  Database db;
  Recipe recipe;
  List recipeImages;
  List allImages;
  List allSteps;
  List allIngredients;
  _PogressDownloadState(this.recipe,this.recipeImages,this.allImages,this.allSteps,this.allIngredients);
  List _multipleFiles = [];
  List _multipleSteps = [];
  List _multipleIngredients = [];
  bool existRecipe = false;
  double percent = 0.00;

  List _objectsDone = [];

  bool _controllerFiles = false;
  bool _controllerSteps = false;
  bool _controllerIngredients = false;
  @override
  void initState() { 
    super.initState();
    getDatabase();
    downloadImages();
  }
  
  Future getDatabase() async{
    final database = await ClientDatabaseProvider.db.database;
    if (mounted) {
      setState(() {
        db = database;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClientDatabaseProvider.db.getRecipeWithId(recipe.idRecipe),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data!=null) {
          return SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: Consts.avatarRadius + Consts.padding,
                  ),
                  margin: EdgeInsets.only(top: Consts.avatarRadius),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                          ),
                          Container(
                            child: Text("Imagenes"),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                          ),
                          Container(
                            child: Text("Receta"),
                          )
                        ],
                      ),
                      Container(
                      margin: EdgeInsets.only(left: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                            ),
                            Container(
                              child: Text("Ingredientes"),
                            )
                          ],
                        ),
                      ),
                      Container(
                      margin: EdgeInsets.only(left: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                            ),
                            Container(
                              child: Text("Pasos"),
                            )
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: (){Navigator.of(context).pop();},
                        child: Text("Close"),
                        color: Colors.transparent,
                        elevation: 0,
                        textColor: Colors.green,
                      )
                    ],
                  )
                ),
                Positioned(
                  left: Consts.padding,
                  right: Consts.padding,
                  child: CircularPercentIndicator(
                    radius: 130.0,
                    animation: true,
                    animateFromLastPercent: true,
                    animationDuration: 1200,
                    lineWidth: 15.0,
                    percent: 1.0,
                    center: new Text(
                      "100 %",
                      style:
                          new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: Colors.yellow,
                    progressColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: Consts.avatarRadius + Consts.padding,
                  ),
                  margin: EdgeInsets.only(top: Consts.avatarRadius),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Builder(builder: (BuildContext context){
                            if(_controllerFiles){
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator()
                              );
                            }else{
                              if(_multipleFiles.length==allImages.length){
                                return Container(
                                  height: 50,
                                  width: 50,
                                  child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                                );
                              }else{
                                return Container(
                                  height: 50,
                                  width: 50,
                                  child: FlareActor('assets/animations/error.flr',fit: BoxFit.contain,animation: 'action')
                                );
                              }
                            }
                          }),
                          Container(
                            child: Text("Imagenes"),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Builder(builder: (BuildContext context){
                            if(_controllerIngredients && _controllerSteps){
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator()
                              );
                            }else{
                              if(_multipleFiles.length==allImages.length){
                                return Container(
                                  height: 50,
                                  width: 50,
                                  child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                                );
                              }else{
                                return Container(
                                  height: 50,
                                  width: 50,
                                  child: FlareActor('assets/animations/error.flr',fit: BoxFit.contain,animation: 'action')
                                );
                              }
                            }
                          }),
                          Container(
                            child: Text("Receta"),
                          )
                        ],
                      ),
                      Container(
                      margin: EdgeInsets.only(left: 20),
                        child: Row(
                          children: <Widget>[
                            Builder(builder: (BuildContext context){
                              if(_controllerIngredients){
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()
                                );
                              }else{
                                if(_multipleIngredients.length==allIngredients.length){
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                                  );
                                }else{
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor('assets/animations/error.flr',fit: BoxFit.contain,animation: 'action')
                                  );
                                }
                              }
                            }),
                            Container(
                              child: Text("Ingredientes"),
                            )
                          ],
                        ),
                      ),
                      Container(
                      margin: EdgeInsets.only(left: 20),
                        child: Row(
                          children: <Widget>[
                            Builder(builder: (BuildContext context){
                              if (_controllerSteps) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()
                                );
                              } else {
                                if(_multipleSteps.length==allSteps.length){
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor('assets/animations/success.flr',fit: BoxFit.contain,animation: 'Untitled')
                                  );
                                }else{
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor('assets/animations/error.flr',fit: BoxFit.contain,animation: 'action')
                                  );
                                }
                              }
                            }),
                            Container(
                              child: Text("Pasos"),
                            )
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: null,
                        child: Text("Downloading ..."),
                        color: Colors.transparent,
                        elevation: 0,
                        textColor: Colors.grey,
                      )
                    ],
                  )
                ),
                Positioned(
                  left: Consts.padding,
                  right: Consts.padding,
                  child: CircularPercentIndicator(
                    radius: 130.0,
                    animation: true,
                    animateFromLastPercent: true,
                    animationDuration: 1200,
                    lineWidth: 15.0,
                    percent: percent,
                    center: new Text(
                      (percent*100).toInt().toString()+" %",
                      style:
                          new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    circularStrokeCap: CircularStrokeCap.butt,
                    backgroundColor: Colors.yellow,
                    progressColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
  Future downloadImages() async {
    var existRecipe = await ClientDatabaseProvider.db.getRecipeWithId(this.recipe.idRecipe);
    if (existRecipe==null) {
      if (mounted) {
        setState(() {
          this._controllerFiles = true;
        });
      }
      List<File> files = [];
      for (var url in allImages) {
        try {
          var arrayRoute =url.replaceAll(r"\",'/').split("/");
          var type = arrayRoute[arrayRoute.length-2];
          if(type!="ingredient"){
            type="recipe";
          }
          String nameImage = arrayRoute.last;
          final Directory extDir = await getExternalStorageDirectory();
          var direcImage = File(extDir.path+'/recipes/$type/$nameImage');
          var exist = await direcImage.exists();
          if (!exist) {
            var imageId = await ImageDownloader.downloadImage("http://3.23.131.0:3002/"+url.replaceAll(r"\",'/'),destination: AndroidDestinationType.custom(directory: "/recipes")..inExternalFilesDir()..subDirectory("$type/$nameImage"));
            ImageDownloader.callback(onProgressUpdate: (String imageId, int progress){});
            var path = await ImageDownloader.findPath(imageId);
            files.add(File(path));
          }else{
            files.add(direcImage);
          }
          if (mounted) {
            setState(() {
              _multipleFiles.add(files);
              _objectsDone.add(files);
              percent = _objectsDone.length/(allImages.length+allSteps.length+allIngredients.length);
            });
          }
          print("************************ESTA ES LA MULTI FILES***********************************");
          print(percent);
        } catch (error) {
          print(error);
        }
      }
      for (var item in this.recipeImages) {
        List arrayRoute = item["route"].replaceAll(r"\",'/').split("/");
        var route = arrayRoute.last;
        var recipeImage = ImageRecipe(
          idImage: item["idImage"],
          principal: item["principal"],
          route: route,
          idRecipe: item["idRecipe"]
        );
        var result = await db.insert('image_recipes',recipeImage.toMap());
        print(result);
      }
      await new Future.delayed(const Duration(seconds : 2));
      if (mounted) {
        setState(() {
          this._controllerFiles = false;
        });
      }
      saveRecipe();
    }else{
      if (mounted) {
        setState(() {
          this.existRecipe = true;
        });
      }
    }
  }
  
  void saveRecipe() async {
    var responseRecipe = await db.insert("recipes", recipe.toMap());
    if(responseRecipe!=null){
      await new Future.delayed(const Duration(seconds : 2));
      await saveIngredients();
    } 
  }
  
  Future saveIngredients() async {
    if (mounted) {
      setState(() {
        this._controllerIngredients = true;
      });
    }
    for (var ingredients in allIngredients) {
      var recipeIngredient = IngredientsRecipe(
        idRecipeIngredient: ingredients["idRecipeIngredient"],
        quantity: ingredients["quantity"],
        optional: ingredients["optional"]?1:0,
        moreOptions: ingredients["moreOptions"],
        idIngredient: ingredients["idIngredient"],
        idRecipe: ingredients["idRecipe"]
      );
      var ingredient = Ingredient(
        idIngredient: ingredients["ingredient"]["idIngredient"],
        name: ingredients["ingredient"]["name"],
        routeImage: ingredients["ingredient"]["routeImage"].replaceAll(r"\",'/').split("/").last,
      );
      var existIngredient = await db.query("ingredients",where: "idIngredient = ?", whereArgs: [ingredient.idIngredient]);
      if(existIngredient.isEmpty){
        await db.insert("ingredients", ingredient.toMap());
      }
      var responseRecipeIngre = await db.insert("recipe_ingredients", recipeIngredient.toMap());
      if(responseRecipeIngre != null){
        if (mounted) {
          setState(() {
            _multipleIngredients.add(responseRecipeIngre);
            _objectsDone.add(responseRecipeIngre);
            percent = _objectsDone.length/(allImages.length+allSteps.length+allIngredients.length);
          });
        }
      }
    }
    await new Future.delayed(const Duration(seconds : 2));
    if (mounted) {
      setState(() {
        this._controllerIngredients = false;
      });
    }
    await saveSteps();
  }

  Future saveSteps() async {
    if (mounted) {
      setState(() {
        this._controllerSteps = true;
      });
    }
    for (var steps in allSteps) {
      var step = StepsRecipe(
        idStep:steps["idStep"],
        description: steps["description"],
        stepNumber: steps["stepNumber"],
        idRecipe: steps["idRecipe"]
      );
      var responseStep = await db.insert("steps_recipes", step.toMap());
      if(responseStep!=null){
        if (mounted) {
          setState(() {
            _multipleSteps.add(responseStep);
            _objectsDone.add(responseStep);
            percent = _objectsDone.length/(allImages.length+allSteps.length+allIngredients.length);
          });
        }
      }
      if (mounted) {
        setState(() {
          this._controllerSteps = false;
        });
      }
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}