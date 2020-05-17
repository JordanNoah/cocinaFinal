import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  Categories({Key key}) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final data = [
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
    {"title":"comida"},
  ];
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
       appBar: AppBar(
         title: Text("Categories"),
       ),
       body: GridView.builder(
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
        itemBuilder: (BuildContext context, int index) {
          return Text(data[index].toString());
        },
      )
    );
  }
}