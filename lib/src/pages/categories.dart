import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:http/http.dart' as http;


List<StaggeredTile> _generateRandomTiles(List categories) {
  return List.generate(categories.length,
      (i) => StaggeredTile.count(
        categories[i]["name"].length>15
          ?
            categories[i]["name"].length < 26 ? 3 : 4
              :
                2,
        1
      ));
}

class Categories extends StatefulWidget {
  Categories({Key key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  List<StaggeredTile> _tiles;

  List categories=[];

  Future loadCategories() async{
    try {
      http.Response responseCategorie = await http.get("http://3.23.131.0:3002/api/getCategories");
      if(responseCategorie.statusCode == HttpStatus.ok){
        var result = jsonDecode(responseCategorie.body)["message"];
        setState(() {
          categories=result;
          _tiles = _generateRandomTiles(categories).toList();
        });
      }
    } catch (e) {
      return e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Categories',style: TextStyle(color: Colors.black),),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.black,),
            onPressed: (){Navigator.pushNamed(context, "/");}
          ),
        ),
          body: new StaggeredGridView.countBuilder(
            primary: false,
            crossAxisCount: 4,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            staggeredTileBuilder: _getTile,
            itemBuilder: _getChild,
            itemCount: categories.length,
          ));
  }

  StaggeredTile _getTile(int index) => _tiles[index];

  Widget _getChild(BuildContext context, int index) {
    return GestureDetector(
      onTap: (){Navigator.pushNamed(context, '/listFood',arguments: [categories[index]["name"]]);},
      child: Container(
        key: ObjectKey('$index'),
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(5),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30,
                  child: CachedNetworkImage(
                    imageUrl: "http://3.23.131.0:3002/"+(categories[index]["icon"]).replaceAll(r"\",'/'),
                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                      Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                    errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    categories[index]["name"],
                    style: TextStyle(fontWeight: FontWeight.bold,),
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
