import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

class AddCommentary extends StatefulWidget {
  final int idUser;
  final int idRecipe;
  AddCommentary({Key key,@required this.idUser,@required this.idRecipe}) : super(key: key);

  @override
  _AddCommentaryState createState() => _AddCommentaryState(idUser,idRecipe);
}

class _AddCommentaryState extends State<AddCommentary> {
  int idUser;
  int idRecipe;
  _AddCommentaryState(this.idUser,this.idRecipe);
  double assessment = 0.0;
  final commentary = TextEditingController();
  bool sendIt = false;
  var infoResponse;

  @override
  void initState() { 
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0,
      child: sendIt?childDialogSendIt():childDialogNoSenIt()
    ); 
  }

  Widget childDialogSendIt(){
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
                Container(
                  margin: EdgeInsets.only(top:10,bottom: 10),
                  child: Text(infoResponse["message"].toString())
                ),
                SizedBox(height: 24.0),
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
              child: CircleAvatar(
                radius: 40,
                backgroundImage: infoResponse["status"]=="success" ? AssetImage("assets/images/check.gif"):AssetImage("assets/images/error.gif"),
              ),
            ),
          )
        ),
      ],
    );
  }

  Widget childDialogNoSenIt(){
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
                SmoothStarRating(
                  allowHalfRating: true,
                  onRatingChanged: (v) {
                    assessment = v;
                    setState(() {});
                  },
                  starCount: 5,
                  rating: assessment,
                  size: 40.0,
                  filledIconData: Icons.star,
                  halfFilledIconData: Icons.star_half,
                  color: Colors.green,
                  borderColor: Colors.green,
                  spacing:5.0
                ),
                SizedBox(height: 15,),
                TextField(
                  controller: commentary,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Send us your commentary",
                    hintText: "Remember to give a comment that helps other users, you can also vote without commenting",
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    )
                  ),
                ),
                SizedBox(height: 24.0),
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
                          var respones = sendComentary(assessment,commentary.text,idUser,idRecipe); // To close the dialog
                          print(respones);
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
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage("assets/images/saladSend.gif"),
              ),
            ),
          )
        ),
      ],
    );
  }

  sendComentary(assessment,commentary,idUser,idRecipe) async {
    try {
      final http.Response response = await http.post(
        'http://192.168.100.54:3002/api/addCommentRecipe',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'assessment': assessment,
          'commentary': commentary,
          'idUser': idUser,
          'idRecipe': idRecipe
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          infoResponse = (json.decode(response.body));
          sendIt = true;
        });
      }
    } on Exception catch (e) {
      if(e.toString().contains('SocketException')){
        setState(() {
          infoResponse = null;
        });
      }
    }
  }
}



class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 40.0;
}
