import 'package:flutter/material.dart';

class RecipeDifficulty extends StatelessWidget {
  final String difficulty;
  RecipeDifficulty(this.difficulty);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(40.0)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                  SizedBox(width: 5,),
                  Container(
                    child: Text(difficulty,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,letterSpacing: 1),overflow: TextOverflow.ellipsis,textAlign: TextAlign.end,),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}