import 'package:flutter/material.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/src/widgets/progressDownload.dart';

class MenuRecipe extends StatefulWidget {
  final Recipe recipeInformation;
  final List recipeSteps;
  final List recipeIngredients;
  final List allImages;
  final List recipeImages;
  MenuRecipe({Key key,@required this.recipeInformation,@required this.recipeSteps,@required this.recipeIngredients,@required this.allImages,@required this.recipeImages}) : super(key: key);

  @override
  _MenuRecipeState createState() => _MenuRecipeState(this.recipeInformation,this.recipeSteps,this.recipeIngredients,this.allImages,this.recipeImages);
}

class _MenuRecipeState extends State<MenuRecipe> {
  Recipe recipeInformation;
  List recipeSteps;
  List recipeIngredients;
  List allImages;
  List recipeImages;
  _MenuRecipeState(this.recipeInformation,this.recipeSteps,this.recipeIngredients,this.allImages,this.recipeImages);

  bool itsDownloaded = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: (){existRecipe();},
    );
  }

  void _showPopupMenu(existRecipe) async {
    var selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 75, 0, 100),
      items: [
        PopupMenuItem(
          child: Builder(builder: (BuildContext context){
            if(existRecipe==null){
              return Row(
                children: <Widget>[
                  Icon(Icons.file_download,color: Colors.black,),
                  Text("Descargar"),
                ],
              );
            }else{
              return Row(
                children: <Widget>[
                  Icon(Icons.delete,color: Colors.black),
                  Text("Eliminar"),
                ],
              );
            }
          }),
          value: existRecipe==null?"descargar":"eliminar",
        ),
      ],
      elevation: 8.0,
    );
    if(selected=="descargar"){
      showDownload();
    }
    if (selected=="eliminar") {
      removeDownload();
    }
  }

  void showDownload(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Consts.padding),
          ),      
          elevation: 0.0,
          backgroundColor: Colors.white,
          child: Center(
            child: PogressDownload(recipe: this.recipeInformation,recipeImages: this.recipeImages,allImages: this.allImages,allIngredients: this.recipeIngredients,allSteps: this.recipeSteps,)
          )
        );
      } 
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
              child: Text("Cancel",style: TextStyle(color: Colors.red),),
              onPressed: (){Navigator.of(context).pop();},
            ),
            MaterialButton(
              child: Text("Remove",style: TextStyle(color: Colors.green),),
              onPressed: (){removeRecipe(); Navigator.of(context).pop();},
            ),
          ],
        );
      }
    );
  }

  Future existRecipe() async{
    try {
      var response = await ClientDatabaseProvider.db.getRecipeWithId(recipeInformation.idRecipe);
      _showPopupMenu(response);
    } catch (e) {
    }
  }
  
  void removeRecipe() async {
    var response = await ClientDatabaseProvider.db.removeRecipe(recipeInformation.idRecipe);
    // // 1 means success, 2 means error while remove, 3 means reicipe dont exist in database
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          elevation: 5,
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text("Recipe removed"),
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              child: Text("Close",style: TextStyle(color: Colors.red),),
              onPressed: (){Navigator.of(context).pop();},
            ),
          ],
        );
      }
    );
    print(response);
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

// insertImage(String route) async{
//     var arrayRoute =route.replaceAll(r"\",'/').split("/");
//     var type = arrayRoute[arrayRoute.length-2];
//     if(type!="ingredient"){
//       type="recipe";
//     }
//     String nameImage = arrayRoute.last;
//       //////
//       ///
//       //
//       try {
//         // Saved with this method.
//         final Directory extDir = await getExternalStorageDirectory();
//         var direcImage = File(extDir.path+'/recipes/$type/$nameImage');
//         var exist = await direcImage.exists();
//         if (!exist) {
//           await ImageDownloader.downloadImage("http://3.23.131.0:3002/"+route.replaceAll(r"\",'/'),destination: AndroidDestinationType.custom(directory: "/recipes")..inExternalFilesDir()..subDirectory("$type/$nameImage"));
//         }
//       } catch (error) {
//       }
//       ///
//   }


// if(images){
//             await insertImage(multiRecipeIngredientObj["ingredient"]["routeImage"]);
//           }

// if (images) {
//             await insertImage(imageRecipeObj["route"]);
//           }