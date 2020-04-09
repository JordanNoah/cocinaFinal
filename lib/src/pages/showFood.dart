import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:random_color/random_color.dart';

class ShowFood extends StatefulWidget {
  ShowFood({Key key}) : super(key: key);

  @override
  _ShowFoodState createState() => _ShowFoodState();
}

class _ShowFoodState extends State<ShowFood> {
  @override
  RandomColor _randomColor = RandomColor();

  Widget build(BuildContext context) {
    Color _color = _randomColor.randomColor();
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            // floating: true,
            pinned: true,
            backgroundColor: _color,
            flexibleSpace: FlexibleSpaceBar(
              title: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 160
                ),
                child: Text("Arroz bien rico Alv"),
              ),
              background: Image.asset("assets/images/food0.jpg",fit: BoxFit.cover,),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.play_circle_outline),
                onPressed: (){
                  Navigator.pushNamed(context, "playRecipie");
                },
              ),
              IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: (){},
              ),
            ],
            elevation: 0,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(10),
                            child: Text("Descripción",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                          ),
                          Container(
                            child:Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed interdum enim finibus justo rhoncus lobortis. Fusce nisl lacus, fermentum quis mattis condimentum, eleifend sed neque. Donec eleifend sapien a mauris semper, quis laoreet lectus porta. Praesent nec malesuada erat. Morbi aliquet non velit in scelerisque. Vestibulum id rhoncus dui. Aliquam nibh nisl, gravida in malesuada eu, vestibulum non arcu. Pellentesque ornare porttitor semper.",style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600,letterSpacing: 1),),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 15),
                                  child: IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: (){},
                                  ),
                                ),
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Text("15",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20,letterSpacing: 1),),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 15),
                                  child: IconButton(
                                    icon: Icon(Icons.plus_one),
                                    onPressed: (){},
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text("Ingredientes",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              )
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context,index){
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  height: 65,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Container(
                    margin: EdgeInsets.all(7),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage("assets/images/food1.jpg"),
                                fit: BoxFit.cover
                              )
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Champiñón",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                Text("100 gramos")
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Checkbox(
                            value: false,
                            onChanged: (bool value){
                              print(value);
                            },
                          ),
                        )
                      ],
                    ),
                  )
                );
              },
              childCount: 10
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text("Pasos",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                )
              )
            ]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context,index){
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: MediaQuery.of(context).size.width,
                  child:Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Center(
                              child: Text((index+1).toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          ),
                          Container(
                            child: Checkbox(
                              value: false, 
                              onChanged: (bool value){
                                print(value);
                              }
                            ),
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed interdum enim finibus justo rhoncus lobortis. Fusce nisl lacus, fermentum quis mattis condimentum, eleifend sed neque. Donec eleifend sapien a mauris semper, quis laoreet lectus porta. Praesent nec malesuada erat. Morbi aliquet non velit in scelerisque. Vestibulum id rhoncus dui. Aliquam nibh nisl, gravida in malesuada eu, vestibulum non arcu. Pellentesque ornare porttitor semper.",style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w600,letterSpacing: 1),),
                      )
                    ],
                  )
                );
              },
              childCount: 9
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text("Mas recetas",style: TextStyle(color: Colors.grey,fontSize: 24,fontWeight: FontWeight.w600,letterSpacing: 1),),
                )
              ),
              Container(
                margin: EdgeInsets.only(top:10),
                height: 245,
                width: MediaQuery.of(context).size.width,
                child: Swiper(
                  itemCount: 3,
                  viewportFraction: 0.75,
                  scale: 1,
                  itemBuilder: (BuildContext context,int index){
                    return ClipRRect(
                      child: GestureDetector(
                        onTap: (){Navigator.pushNamed(context, "showfood");},
                        child: Card(
                          elevation:0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(19),
                                          image: DecorationImage(
                                            image: AssetImage("assets/images/food$index.jpg"),fit: BoxFit.cover
                                          )
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(19)
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Flexible(
                                              flex: 5,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                                child: Row(
                                                  children: <Widget>[
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                        children: <Widget>[
                                                          Text("Arroz bien rico ALV",overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 14),),
                                                          Text("Datasa",overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.grey,fontSize: 12.9),)
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ),
                                            ),
                                            Flexible(
                                              flex: 4,
                                              child: Container(
                                                padding: EdgeInsets.all(2),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(Icons.timer,color: Colors.grey,),
                                                    Flexible(
                                                      child: Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.all(7),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Icon(Icons.favorite_border,color: Colors.red,),
                                      ],
                                    )
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}