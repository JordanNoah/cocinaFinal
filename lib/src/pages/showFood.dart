import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/models/stepsRecipe_model.dart';
import 'package:image_downloader/image_downloader.dart';
// import 'package:food_size/models/recipe_model.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:random_color/random_color.dart';
import 'package:http/http.dart' as http;

class ShowFood extends StatefulWidget {
  final List data;
  ShowFood({Key key,@required this.data}) : super(key: key);

  @override
  _ShowFoodState createState() => _ShowFoodState(data);
}

class _ShowFoodState extends State<ShowFood> {
  @override
  RandomColor _randomColor = RandomColor();
  Color _color;
  List data;
  bool itsDownloaded = false;
  bool downloadImg = false;
  _ShowFoodState(this.data);

  var recipe;
  List imagesRecipe=[];
  List recipeIngredients = [];
  List stepsRecipe = [];
  List randomRecipe = [];
  int cantDishes=1;
  List selectedIngredients=[];
  List selectedSteps=[];
  

  @override
  void initState() { 
    super.initState();
    loadRecipe();
    randomRecipes();
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
      http.Response responseRecipe = await http.get('http://192.168.100.54:3002/api/getRecipe?idRecipe='+data[0].toString());
      String resRecipe = responseRecipe.body;
      final jsonRecipe = jsonDecode(resRecipe)["message"];
      setState(() {
        recipe=jsonRecipe;
        recipeIngredients=recipe["recipe_ingredients"];
        stepsRecipe = recipe["step_recipes"];
        imagesRecipe = recipe["image_recipes"];
      });
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
      setState(() {
        recipe={"idRecipe":(recipeClass.idRecipe),"description":recipeClass.description,"title":recipeClass.title};
      });
    }

    recipeInside();
  }
  
  Future randomRecipes() async{
    if(data[1]){
      http.Response responseRandomRecipe = await http.get('http://192.168.100.54:3002/api/getLikedRecipe');
      String respRandomRecipe = responseRandomRecipe.body;
      final jsonRandomRecipe = jsonDecode(respRandomRecipe)["message"];
      setState(() {
        randomRecipe=jsonRandomRecipe;
      });
    }else{
      setState(() {
        randomRecipe=[];
      });
    }
  }

  downloadImages(){

  }

  Widget build(BuildContext context) {

    return Scaffold(
      body: recipe==null?Center(child: Text("Cargando"),):CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            // floating: true,
            pinned: true,
            backgroundColor: _color,
            flexibleSpace: FlexibleSpaceBar(
              title: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 160
                ),
                child: Text(recipe["title"]),
              ),
              background: Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 280,
                      child: Image.network("http://192.168.100.54:3002/"+(imagesRecipe[0]["route"]).replaceAll(r"\",'/'),fit: BoxFit.cover,),
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
              IconButton(
                icon: Icon(Icons.play_circle_outline),
                onPressed: (){
                  Navigator.of(context).pushNamed("/playRecipie",arguments: recipe);
                },
              ),
              PimpedButton(
                particle: DemoParticle(),
                pimpedWidgetBuilder: (context,controller){
                  return IconButton(
                    icon: itsDownloaded?Icon(Icons.check_circle):Icon(Icons.cloud_download),
                    onPressed: (){itsDownloaded?removeDownload(controller):downloadRecipe(controller);},
                  );
                },
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
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: IconButton(
                                    color: cantDishes!=1?Colors.black:Colors.grey,
                                    icon: Icon(Icons.remove),
                                    onPressed: (){
                                      setState(() {
                                        if (cantDishes>1) {
                                          cantDishes=cantDishes-1;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text(cantDishes.toString() ,style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20,letterSpacing: 1),),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 15),
                                  child: IconButton(
                                    icon: Icon(Icons.plus_one),
                                    color: cantDishes!=16?Colors.black:Colors.grey,
                                    onPressed: (){
                                      setState(() {
                                        if(cantDishes<16){
                                          cantDishes=cantDishes+1;
                                        }
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
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
                                image: DecorationImage(
                                  image: NetworkImage("http://192.168.100.54:3002/"+(recipeIngredients[index]["ingredient"]["routeImage"]).replaceAll(r"\",'/')),
                                  fit: BoxFit.cover
                                )
                              ),
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
                                  Text(newCant(recipeIngredients[index]["quantity"]).toString(),overflow: TextOverflow.ellipsis,)
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
          SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text("Mas recetas",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                )
              ),
              Container(
                margin: EdgeInsets.only(top:10),
                height: 245,
                width: MediaQuery.of(context).size.width,
                child: Swiper(
                  itemCount: randomRecipe.length,
                  viewportFraction: 0.75,
                  scale: 1,
                  itemBuilder: (BuildContext context,int index){
                    return ClipRRect(
                      child: GestureDetector(
                        onTap: (){Navigator.pushNamed(context, "showfood");},
                        child: Card(
                          elevation:0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(19),
                                          image: DecorationImage(
                                            image: NetworkImage("http://192.168.100.54:3002/"+(randomRecipe[index]["image_recipes"][0]["route"]).replaceAll(r"\",'/')),
                                            fit: BoxFit.cover
                                          )
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(19)
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Flexible(
                                              flex: 5,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          Text(randomRecipe[index]["title"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 14),),
                                                          Text(randomRecipe[index]["description"],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.grey,fontSize: 12.9),)
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ),
                                            ),
                                            Flexible(
                                              flex: 4,
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(Icons.timer,color: Colors.grey,),
                                                    Flexible(
                                                      child: Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.all(7),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Icon(Icons.favorite_border,color: Colors.red,),
                                      ],
                                    )
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void downloadRecipe(controller){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text("Download"),
          elevation: 5,
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("Would you like to download the images also this will occupy an extra space on your cell phone"),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Text("With images",style: TextStyle(color: Colors.black54),),
                    Switch(
                      value: downloadImg, 
                      onChanged: (bool value){
                        setState(() {
                          downloadImg=value;
                        });
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text("Cancelar",style: TextStyle(color: Colors.red),),
              onPressed: (){Navigator.of(context).pop();},
            ),
            MaterialButton(
              child: Text("Guardar",style: TextStyle(color: Colors.green),),
              onPressed: (){saveRecipe(context,controller);},
            ),
          ],
        );
      }
    );
  }

  void removeDownload(controller){
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
              onPressed: (){removeRecipe(controller);},
            ),
          ],
        );
      }
    );
  }

  void recipeInside() async {
    var getRecipe=Recipe(idRecipe:recipe["idRecipe"],title: recipe["title"],description: recipe["description"]);
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
                    child: Image.network("http://192.168.100.54:3002/"+(ingredient["ingredient"]["routeImage"]).replaceAll(r"\",'/').toString(),fit: BoxFit.cover,),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Text(ingredient["quantity"].toString()),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  void removeRecipe(controller) async {
    var recipes = Recipe(
      idRecipe: recipe["idRecipe"],
      title: recipe["title"],
      description: recipe["description"]
    );
    var removed = await ClientDatabaseProvider.db.removeRecipe(recipes);
    // 1 means success, 2 means error while remove, 3 means reicipe dont exist in database
    if(removed==1 || removed==3){
      setState(() {
        itsDownloaded=false;
      });
      Navigator.of(context).pop();
    }
  }

  // Future<File> getImages(String filename){
    
  // }

  saveRecipe(BuildContext context,controller) async {
    try {
    // Saved with this method.
    var imageId = await ImageDownloader.downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png");
    print(imageId);
    if (imageId == null) {
      return;
    }

    // Below is a method of obtaining saved image information.
    var fileName = await ImageDownloader.findName(imageId);
    var path = await ImageDownloader.findPath(imageId);
    var size = await ImageDownloader.findByteSize(imageId);
    var mimeType = await ImageDownloader.findMimeType(imageId);
    print(fileName);
    print(path);
    print(size);
    print(mimeType);
  } catch (error) {
    print(error);
  }



    // var recipes = Recipe(
    //   idRecipe: recipe["idRecipe"],
    //   title: recipe["title"],
    //   description: recipe["description"]
    // );

    // var existRecipe = await ClientDatabaseProvider.db.getRecipeWithId(recipes.idRecipe);
    // if (existRecipe==null) {
    //   List multiSteps = recipe["step_recipes"];
    //   List multiRecipeIngredient = recipe["recipe_ingredients"];
    //   List imageRecipe = recipe["image_recipes"];
    //   var response = await ClientDatabaseProvider.db.addRecipeToDatabase(recipes,multiSteps,imageRecipe,multiRecipeIngredient);
      
    //   if (response==1) {
    //     setState(() {
    //       itsDownloaded=true;
    //     });
    //     controller.forward(from: 0.0);
    //     Navigator.of(context).pop();
    //   } else {
    //     setState(() {
    //       itsDownloaded=true;
    //     });
    //     controller.forward(from: 0.0);
    //     Navigator.of(context).pop();
    //   }
    // }  
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
}