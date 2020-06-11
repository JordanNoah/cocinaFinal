import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategorieList extends StatefulWidget {
  CategorieList({Key key}) : super(key: key);

  @override
  _CategorieListState createState() => _CategorieListState();
}

Future loadCategories() async{
  try {
    http.Response responseCategorie = await http.get("http://3.23.131.0:3002/api/getCategories");
    if(responseCategorie.statusCode == HttpStatus.ok){
      var result = jsonDecode(responseCategorie.body)["message"];
      return result;
    }
  } catch (e) {
    return e;
  }
}

class _CategorieListState extends State<CategorieList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: FutureBuilder(
        future: loadCategories(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasError){
            return Center(child: Text('Error'),);
          }
          if(snapshot.connectionState == ConnectionState.done){
            List categories = snapshot.data;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 5,
                margin: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: (){Navigator.pushNamed(context, '/listFood',arguments: [categories[index]["name"]]);},
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
                            categories[index]["name"][0].toString().toUpperCase()+categories[index]["name"].toString().substring(1),
                            style: TextStyle(fontWeight: FontWeight.bold,),
                          ),
                        )
                      ],
                    )
                  ),
                ),
              );
             },
            );
          }else{
            return Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }
}