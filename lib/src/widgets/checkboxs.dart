import 'package:flutter/material.dart';

class Checkboxs extends StatefulWidget {
  Checkboxs({Key key}) : super(key: key);

  @override
  _CheckboxsState createState() => _CheckboxsState();
}

class _CheckboxsState extends State<Checkboxs> {
  bool selected = false;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: selected,
      onChanged: (bool value){
        _onIngredientSelected(value);
      },
    );
  }
  void _onIngredientSelected(bool value){
    setState(() {
      selected = !selected;
    });
  }
}