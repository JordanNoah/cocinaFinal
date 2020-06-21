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
  }on SocketException {
    throw Failure("No internet connection");
  } on HttpException {
    throw Failure("Couldn't find the post");
  }
}

class _CategorieListState extends State<CategorieList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadCategories(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
            return Container(
              margin: EdgeInsets.only(top: 20,left: 15,right: 15),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                    ],
                  ),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: (){
                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
            );
        }
        if (snapshot.connectionState == ConnectionState.done) {
            List categories = snapshot.data;
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 5,left: 15,right: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                        GestureDetector(
                          onTap: (){Navigator.pushNamed(context, '/categories');},
                          child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    child: ListView.builder(
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
                    ),
                  )
                ],
              ),
            );
        } else {
          return Container(
            margin: EdgeInsets.only(top: 20,left: 15,right: 15),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                  ],
                ),
                Center(
                  child: CircularProgressIndicator()
                )
              ],
            ),
          );
        }
      }
    );
  }
}

class Failure {
  // Use something like "int code;" if you want to translate error messages
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

//  Container(
//                     margin: EdgeInsets.only(top: 20,left: 15,right: 15),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
//                         GestureDetector(
//                           onTap: (){Navigator.pushNamed(context, '/categories');},
//                           child: Text("Show more",style: TextStyle(color: Colors.blueAccent),),
//                         )
//                       ],
//                     ),
//                   ),


// Container(
//       height: 80,
//       child: FutureBuilder(
//         future: loadCategories(),
//         builder: (BuildContext context, AsyncSnapshot snapshot) {
//           if(snapshot.hasError){
//             return Center(child: Text('Error'),);
//           }
//           if(snapshot.connectionState == ConnectionState.done){
//             List categories = snapshot.data;
//             return 
//           }else{
//             return Center(child: CircularProgressIndicator(),);
//           }
//         },
//       ),
//     );