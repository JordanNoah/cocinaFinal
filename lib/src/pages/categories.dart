import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Categories extends StatefulWidget {
  Categories({Key key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  
  Future loadCategories() async{
    try {
      http.Response responseCategories = await http.get("http://3.23.131.0:3002/api/getCategories");
      if(responseCategories.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseCategories.body)["message"];
        return result;
      }
    } on Exception catch (e) {
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories"),
      ),
      body: Container(
        child:FutureBuilder(
          future: loadCategories(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasError){
              return Center(child: Text("Error"),);
            }
            if (snapshot.connectionState == ConnectionState.done) {
              List categories = snapshot.data;
              print(categories);
              return GridView.builder(
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: (){},
                    child: Card(
                      elevation: 0,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height,
                            child: CachedNetworkImage(
                              imageUrl: ("http://3.23.131.0:3002/"+categories[index]["routeImage"]).replaceAll(r"\",'/'),
                              progressIndicatorBuilder: (context, url, downloadProgress) => 
                                Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                              errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            color: Colors.black54,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: 51,
                                  height: 51,
                                  child: CachedNetworkImage(
                                    imageUrl: ("http://3.23.131.0:3002/"+categories[index]["icon"]).replaceAll(r"\",'/'),
                                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                                      Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                                    errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(categories[index]["name"].toUpperCase(),style: TextStyle(color: Colors.white,letterSpacing: 1,fontWeight: FontWeight.bold,fontSize: 17),)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ), 
      )
    );
  }
}




