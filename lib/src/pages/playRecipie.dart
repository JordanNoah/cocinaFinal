import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:random_color/random_color.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter_tts/flutter_tts.dart';


class PlayRecipie extends StatefulWidget {
  PlayRecipie({Key key}) : super(key: key);

  @override
  _PlayRecipieState createState() => _PlayRecipieState();
}

class _PlayRecipieState extends State<PlayRecipie> {
  final steps = [
    {
      "step":"1",
      "description":"Cook pasta per pkg. directions, adding asparagus during last 2 minutes of cooking.",
      "kind":"cooking"
    },
    {
      "step":"2",
      "description":"Meanwhile, in a large skillet, heat 2 Tbsp oil with garlic, leek, thyme, red pepper flakes, and 1/4 tsp salt on medium-low and cook, stirring occasionally, until very tender, 12 to 15 minutes.",
      "kind":"preparation"
    },
    {
      "step":"3",
      "description":"Reserve 1 cup pasta cooking water, then drain pasta and asparagus and add to leek mixture. Add lemon juice, remaining 2 Tbsp oil, and 1/4 cup reserved cooking water, tossing to coat. Fold in half of Parmesan, adding more cooking water if pasta seems dry. Top with lemon zest and remaining Parmesan.",
      "kind":"showend"
    }
  ];
  FlutterTts flutterTts = FlutterTts();
  final PageController _pageController = new PageController(
    initialPage: 0
  );
  int actualpage;
  DateTime alert;
  RandomColor _randomColor = RandomColor();
  final givenTime = 200;
  var remaining;
  var passTime;
  String descriptionStep;
  @override
  void initState() {
    // valores iniciales
    super.initState();
    actualpage = 1;
    alert = DateTime.now().add(Duration(seconds: givenTime));
    descriptionStep = steps[0]["description"];
  }
  @override
  Widget build(BuildContext context) {
    Color _color = _randomColor.randomColor();
    var staticRandomColor = _color;
    return Scaffold(
      body: Container(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      StepProgressIndicator(
                        totalSteps: steps.length,
                        currentStep: actualpage,
                        size: 6,
                        padding: 0,
                        selectedColor: staticRandomColor,
                        unselectedColor: Colors.white,
                      ),
                      Expanded(
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: steps.length,
                          controller: _pageController,
                          onPageChanged: (value){setState(() {
                            actualpage = value + 1;
                            descriptionStep=steps[value]["description"];
                          });},
                          itemBuilder: (BuildContext context , index){
                            return Container(
                              decoration: decorationPage(steps[index]["kind"]),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("Arroz bien rico alv",style: TextStyle(color: Colors.white60,fontWeight: FontWeight.w500,fontSize: 15)),
                                          IconButton(
                                            icon: Icon(Icons.refresh),
                                            color: Colors.white,
                                            onPressed: () {
                                              setState(() {
                                                alert = DateTime.now().add(Duration(seconds: givenTime));
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(                            
                                      margin: EdgeInsets.only(top:10,bottom: 10,left: 15,right: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              child: Center(
                                                child: Text(
                                                  "Preparation",
                                                  style: TextStyle(
                                                    color: steps[index]["kind"]=="preparation"?Colors.white:Colors.grey,
                                                    decoration: TextDecoration.underline,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Center(
                                                child: Text(
                                                  actualpage.toString()+".",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 40
                                                  ),
                                                )
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Center(
                                                child: Text(
                                                  "Cooking",
                                                  style: TextStyle(
                                                    color: steps[index]["kind"]=="cooking"?Colors.white:Colors.grey,
                                                    decoration: TextDecoration.underline,
                                                    fontSize: 18
                                                  ),
                                                )
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 15),
                                      child: Column(
                                        children: <Widget>[
                                          Text("Scroll at bottom for more description",style: TextStyle(color: Colors.white),),
                                          Icon(Icons.keyboard_arrow_down,color: Colors.white,)
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  decoration: decorationStep(steps[index]["kind"]),
                                                  child: TimerBuilder.scheduled(
                                                    [alert], 
                                                    builder: (context){
                                                      var now = DateTime.now();
                                                      var reached = now.compareTo(alert) >= 0;
                                                      return Center(
                                                        child: columnCounter(reached,steps[index]["kind"])
                                                      );
                                                    }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            );
                          },
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(                
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black87,
                ),
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: (){speak();},
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(descriptionStep,style: TextStyle(color: Colors.white),)
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget cooking (passTime,remaining){
    return Container(
        child: Stack(
          children: <Widget>[
            CircularPercentIndicator(
              radius: 330.0,
              lineWidth: 3,
              percent: passTime,
              center: Text(""),
              backgroundColor: Colors.grey,
              progressColor: Colors.white,
            ),
          ],
        ),
      );
  }
  Widget cookingFinish (){
    return Center(
      child: CircularPercentIndicator(
        radius: 330.0,
        lineWidth: 3,
        percent: 1,
        center: new Text(""),
        progressColor: Colors.white
      ),
    );
  }

  Column columnCounter(reached,kind){
    if(kind=="cooking"){
      return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        !reached ?
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TimerBuilder.periodic(
                    Duration(seconds: 1),
                    alignment: Duration.zero,
                    builder: (context) {
                      // This function will be called every second until the alert time
                      var now = DateTime.now();
                      remaining = alert.difference(now);
                      passTime = formatDoubleTime( remaining.inSeconds, givenTime );
                      return Expanded(
                        child: Container(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: cooking(passTime,remaining),
                              ),
                              Container(
                                margin: EdgeInsets.all(20),
                                alignment: Alignment.bottomCenter,
                                child: Text(formatDuration(remaining),style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 25,letterSpacing: 6),),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            )
          )
          :
          Expanded(
            child: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: cooking(passTime,remaining),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    alignment: Alignment.bottomCenter,
                    child: Text("00:00",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 25,letterSpacing: 6),),
                  )
                ],
              ),
            ),
          )
      ],
    );
    }else{

    }
  }

  BoxDecoration decorationStep(kind){
    if(kind!="showend"){
      if(kind=="preparation"){
        
      }else{
        return BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/sarten.png"),
            fit: BoxFit.cover,
          )
        );
      }
    }else{
      return BoxDecoration(
        color: Colors.transparent
      );
    }
  }

  BoxDecoration decorationPage(kind){
    if(kind=="showend"){
      return BoxDecoration(
        color: Colors.black87,
        image: DecorationImage(
          image: AssetImage("assets/images/finishFood.jpg"),
          fit: BoxFit.cover
        )
      );
    }else{
      if(kind=="preparation"){
        return BoxDecoration(
          color: Colors.black87,
          image: DecorationImage(
            image: AssetImage("assets/images/tabla.jpg"),
            fit: BoxFit.cover
          )
        );
      }else{
        return BoxDecoration(
          color: Colors.black87,
          image: DecorationImage(
            image: AssetImage("assets/images/fondoCocina.jpg"),
            fit: BoxFit.cover
          )
        );
      }
    }
  }
  speak() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(descriptionStep);
  }
}

formatDoubleTime( time ,givenTime){
  final doubleTime = (givenTime - time)/givenTime ;
  return doubleTime;
}

String formatDuration(Duration d) {
  String f(int n) {
    return n.toString().padLeft(2, '0');
  }
  // We want to round up the remaining time to the nearest second
  d += Duration(microseconds: 999999);
  return "${f(d.inMinutes)}:${f(d.inSeconds%60)}";
}