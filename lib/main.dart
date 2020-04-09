import 'package:flutter/material.dart';
import 'package:food_size/src/pages/foods.dart';
import 'package:food_size/src/pages/playRecipie.dart';
import 'package:food_size/src/pages/showFood.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocina',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        "/":(BuildContext context)=>Foods(),
        "showfood":(BuildContext context)=>ShowFood(),
        "playRecipie":(BuildContext context)=>PlayRecipie()
      },
    );
  }
}


// Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   crossAxisAlignment: CrossAxisAlignment.center,
//   children: <Widget>[
//     !reached ?
//       Expanded(
//         child: Container(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               TimerBuilder.periodic(
//                 Duration(seconds: 1),
//                 alignment: Duration.zero,
//                 builder: (context) {
//                   // This function will be called every second until the alert time
//                   var now = DateTime.now();
//                   remaining = alert.difference(now);
//                   passTime = formatDoubleTime( remaining.inSeconds, givenTime );
//                   return Expanded(
//                     child: Container(
//                       child: Stack(
//                         children: <Widget>[
//                           Container(
//                             alignment: Alignment.center,
//                             child: cooking(passTime,remaining),
//                           ),
//                           Container(
//                             margin: EdgeInsets.all(20),
//                             alignment: Alignment.bottomCenter,
//                             child: Text(formatDuration(remaining),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 25,letterSpacing: 6),),
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//               ),
//             ],
//           ),
//         )
//       )
//       :
//       Expanded(
//         child: Container(
//           child: Stack(
//             children: <Widget>[
//               Container(
//                 alignment: Alignment.center,
//                 child: cooking(passTime,remaining),
//               ),
//               Container(
//                 margin: EdgeInsets.all(20),
//                 alignment: Alignment.bottomCenter,
//                 child: Text("00:00",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 25,letterSpacing: 6),),
//               )
//             ],
//           ),
//         ),
//       )
//   ],
// ),