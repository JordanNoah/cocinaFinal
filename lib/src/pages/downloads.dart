import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_size/core/database.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:path_provider/path_provider.dart';

class Download extends StatefulWidget {
  Download({Key key}) : super(key: key);

  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  List<Recipe> getRecipes;
  Directory extDirec;
  @override
  void initState() { 
    super.initState();
    callDownloadedRecipe();
  }
  @override
  void dispose() {
    super.dispose();
  }
  void callDownloadedRecipe() async{
    var response = await ClientDatabaseProvider.db.getAllRecipes();
    final Directory extDir = await getExternalStorageDirectory();
    setState(() {
      extDirec = extDir;
      getRecipes=response;
    });
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
              return GridView.builder(
                itemCount: snapshot.data.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 10,mainAxisSpacing: 10), 
                itemBuilder: (BuildContext context,index) {
                  Recipe item = snapshot.data[index];
                  return GestureDetector(
                    onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [item.idRecipe,false]);},
                    child: Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FutureBuilder(
                                future: ClientDatabaseProvider.db.getImgProfileRecipe(item.idRecipe),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  var image = snapshot.data!=null ? File(extDirec.path+'/recipes/recipe/${snapshot.data}'):null;
                                  return image == null ?Center(child: CircularProgressIndicator(),) : Image.file(image,fit: BoxFit.cover,);
                                },
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10,right: 10,top:5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(item.title,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
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
                  );
                }
              );
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
}
