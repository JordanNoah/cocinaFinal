import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ShowRate extends StatefulWidget {
  final totalAssessment;
  final countOfReview;
  const ShowRate({Key key,@required this.totalAssessment,@required this.countOfReview}) : super(key: key);

  @override
  _ShowRateState createState() => _ShowRateState(this.totalAssessment,this.countOfReview);
}

class _ShowRateState extends State<ShowRate> {
  final totalAssessment;
  final countOfReview;

  _ShowRateState(this.totalAssessment,this.countOfReview);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SmoothStarRating(
            allowHalfRating: true,
            starCount: 5,
            rating: countOfReview==0?0.00: totalAssessment,
            size: 11.0,
            filledIconData: Icons.star,
            halfFilledIconData: Icons.star_half,
            color: Colors.yellow,
            borderColor: Colors.black,
            spacing:0.0
          ),
          SizedBox(width: 5),
          Text(countOfReview==0?"0.00":totalAssessment.toString(),style: TextStyle(fontSize: 9),),
          SizedBox(width: 5,),
          countOfReview>99
            ?
              Text("(+99 reviews)",style: TextStyle(fontSize: 9),)
                :
                  Text("("+countOfReview.toString()+" reviews)",style: TextStyle(fontSize: 9),)
        ],
      ),
    );
  }
}