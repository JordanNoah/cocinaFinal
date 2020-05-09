import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';

class DownloadRecipe extends StatefulWidget {
  final Recipe recipe;
  final List multiSteps;
  final List imageRecipe;
  final List multiRecipeIngredient;
  DownloadRecipe({Key key,@required this.recipe,@required this.multiSteps,@required this.imageRecipe,@required this.multiRecipeIngredient}) : super(key: key);

  @override
  _DownloadRecipeState createState() => _DownloadRecipeState(recipe,multiSteps,imageRecipe,multiRecipeIngredient);
}

class _DownloadRecipeState extends State<DownloadRecipe> {
  bool withImages = false;
  Recipe recipe;
  List multiSteps;
  List imageRecipe;
  List multiRecipeIngredient;
  bool hasDownloaded = false;
  bool startDownload = false;
  _DownloadRecipeState(this.recipe,this.multiSteps,this.imageRecipe,this.multiRecipeIngredient);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0,
      child:hasDownloaded?childDialogDownloaded():childDialogNoDownloaded()
    );
  }

  Widget childDialogDownloaded(){
    return Stack(
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
              child: startDownload ? Center(
                child: CircularProgressIndicator(),
              ) : CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/downloadDone.gif"),
              ),
            ),
          )
        ),
      ],
    );
  }

  Widget childDialogNoDownloaded(){
    return Stack(
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
            child: startDownload 
              ?
                Center(
                  child: CircularProgressIndicator(),
                )
                  :
                    Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[
                SizedBox(height: 15,),
                Text("Would you like to download the images also this will occupy an extra space on your cell phone"),
                SizedBox(height: 24.0),
                Row(
                  children: <Widget>[
                    withImages?Text("With images"):Text("Only information"),
                    CupertinoSwitch(
                      value: withImages,
                      onChanged: (value){
                        setState(() {
                          withImages=value;
                        });
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // To close the dialog
                        },
                        child: Text("Cancel",style: TextStyle(color: Colors.red),),
                      ),
                      FlatButton(
                        onPressed: () {
                          saveRecipe(context);
                        },
                        child: Text("Save",style: TextStyle(color: Colors.green),),
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
              child: startDownload ? Center(
                child: CircularProgressIndicator(),
              ) : CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/donwloadNotInit.gif"),
              ),
            ),
          )
        ),
      ],
    );
  }

  saveRecipe(BuildContext context) async {
    setState(() {
      startDownload=true;
    });
    var existRecipe = await ClientDatabaseProvider.db.getRecipeWithId(recipe.idRecipe);
    print(existRecipe);
    if (existRecipe==null) {
      var response = await ClientDatabaseProvider.db.addRecipeToDatabase(recipe,multiSteps,imageRecipe,multiRecipeIngredient,withImages);
      print(response);
      if (response==1) {
        setState(() {
          hasDownloaded=true;
          startDownload=false;
        });
      } else {
        setState(() {
          hasDownloaded=true;
          startDownload=false;
        });
      }
    }else{
      setState(() {
        startDownload=false;
      });
    }
  }

}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 40.0;
}