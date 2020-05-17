import 'package:flutter/material.dart';

class RecipeDifficulty extends StatelessWidget {
  final String difficulty;
  RecipeDifficulty(this.difficulty);

  @override
  Widget build(BuildContext context) {
    // return Text(difficulty);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(40.0)
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 10,
                width: 16.66,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    bottomLeft:Radius.circular(40.0),
                    topRight: Radius.circular(difficulty=="Easy"?40.0:0),
                    bottomRight:Radius.circular(difficulty=="Easy"?40.0:0), 
                  )
                ),
              ),
              Container(
                height: 10,
                width: 16.66,
                decoration: BoxDecoration(
                  color: difficulty=="Medium"||difficulty=="Hard"?Colors.orange:Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(difficulty=="Medium"?40.0:0),
                    bottomRight:Radius.circular(difficulty=="Medium"?40.0:0),
                  )
                ),
              ),
              Container(
                height: 10,
                width: 16.66,
                decoration: BoxDecoration(
                  color:difficulty=="Hard" ? Colors.orange : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40.0),
                    bottomRight:Radius.circular(40.0), 
                  )
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10,),
        Container(
          width: 60,
          child: Text(difficulty,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,letterSpacing: 1),overflow: TextOverflow.ellipsis,),
        ),
      ],
    );
  }
}