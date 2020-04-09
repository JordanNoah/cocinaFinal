import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:food_size/src/icons/darts/list_fooddart_icons.dart';
import 'package:random_color/random_color.dart';

class Foods extends StatefulWidget {
  Foods({Key key}) : super(key: key);

  @override
  _FoodsState createState() => _FoodsState();
}

class _FoodsState extends State<Foods> {
  int indexSelected = 0;
  final categoryFood = ["Vegan","Vegetarian"];
  RandomColor _randomColor = RandomColor();

  List<String> dogImages = new List();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){setState(() {
                indexSelected=0;
              });},
              color: indexSelected != 0 ? Colors.black : Colors.grey
            ),
            Text(categoryFood[indexSelected],style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (){setState(() {
                indexSelected=1;
              });},
              color: indexSelected == 1 ? Colors.grey : Colors.black,
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search), 
            onPressed: (){
              showSearch(context: context, delegate: DataSearch());
            },
            color: Colors.black,
          )
        ],
      ),
      
      body: Container(
        margin: EdgeInsets.only(bottom: 15),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("New recipes",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                            Text("Show all",style: TextStyle(color: Colors.blueAccent),)
                          ],
                        ),
                      ),
                      Container(
                        height: 245,
                        child: Swiper(
                          itemCount: 3,
                          viewportFraction: 0.73,
                          scale: 0.80,
                          itemBuilder: (BuildContext context,int index){
                            return ClipRRect(
                              child: GestureDetector(
                                onTap: (){Navigator.pushNamed(context, "showfood");},
                                child: Card(
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
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20,left: 15,right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Most voted",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                      Text("Show all",style: TextStyle(color: Colors.blueAccent),)
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:10),
                  height: 210,
                  child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                                width: 105,
                                height: 170,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: AssetImage("assets/images/food0.jpg"),
                                    fit: BoxFit.cover
                                  )
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(4),
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.favorite_border,color: Colors.red,),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            width: 105,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Arroz bien rico aaaaaaALV",overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.timer,color: Colors.grey,size: 11,),
                                    SizedBox(width: 5,),
                                    Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20,left: 15,right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Categories",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                      Text("Show all",style: TextStyle(color: Colors.blueAccent),)
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: Wrap(
                    children: <Widget>[
                      category("Breakfast",Icon(Icons.free_breakfast,color: Colors.white,)),
                      category("Lunch",Icon(List_fooddart.lunch,color: Colors.white,)),
                      category("Dinner",Icon(Icons.local_dining,color: Colors.white,)),
                      category("Pizzas",Icon(Icons.local_pizza,color: Colors.white,)),
                      category("Juices",Icon(Icons.local_drink,color: Colors.white,)),
                      category("Salads",Icon(List_fooddart.salad,color: Colors.white,)),
                      category("Rices",Icon(List_fooddart.rice,color: Colors.white,)),
                      category("Fitness",Icon(Icons.fitness_center,color: Colors.white,)),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 15,left: 15,right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Random",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueGrey,fontSize: 16),),
                      Text("Show all",style: TextStyle(color: Colors.blueAccent),)
                    ],
                  ),
                ),
              ]),
            ),
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, index){
                  return Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage("assets/images/food2.jpg"),
                                fit: BoxFit.cover
                              )
                            ),
                            child: Container(
                              margin: EdgeInsets.all(6),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(Icons.favorite_border,color: Colors.red,),
                                  ],
                                )
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10,right: 10,top:5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Arroz bien rico aaaaaaALV",overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                              Row(
                                children: <Widget>[
                                  Icon(Icons.timer,color: Colors.grey,size: 11,),
                                  SizedBox(width: 5,),
                                  Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
                childCount: 10
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 4,
                childAspectRatio: 0.8
              )
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){},
        backgroundColor: Colors.orange.shade900,
        child: Container(
          height: 40.0,
          width: 40.0,
          child: SvgPicture.asset('assets/images/ensalada.svg'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color:Colors.transparent,
        elevation: 9.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0)
            ),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.home, color: Color(0xFFEF7532),),
                    Icon(Icons.person_outline,color: Color(0xFF676E79),)
                  ],
                ),
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.file_download, color: Color(0xFFEF7532),),
                    Icon(Icons.favorite_border,color: Colors.red)
                  ],
                ),
              )    
            ],
          ),
        ),
      ),
    );
  }
  ////////////////////////////////////////////////////
  Widget category(categoriesName ,Icon iconName){
    Color _color = _randomColor.randomColor();

    return Container(
      margin: EdgeInsets.all(5),
      width: 75,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40)
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: _color,
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.black45,
                  ),
                ),
                Center(
                  child: iconName,
                ),
              ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:5),
            child: Center(
              child: Text(categoriesName,overflow: TextOverflow.ellipsis,),
            ),
          )
        ],
      )
    );
  }
}

class DataSearch extends SearchDelegate<String>{
  
  final cities =[
    "guayas",
    "quevedo",
    "manta",
    "quito",
    "cuenca",
    "new delhi",
    "nodia",
    "thane",
    "howrad",
    "thane",
    "guayas",
    "quevedo",
    "manta"
  ];

  final recentCities = [
    "nodia",
    "thane",
    "howrad",
    "thane"
  ];

  @override
  List<Widget> buildActions(BuildContext context) {
    // acciones para el app bar
    return [
      IconButton(icon: Icon(Icons.clear),onPressed: (){
        query = "";
      },)
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // iconos para el appbar
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ), 
      onPressed: (){close(context, null);}
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // mostrar resultados basados en  la seleccion
    return Container(
      height: 100.0,
      width: 100.0,
      child: Card(
        color: Colors.red,
        
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // muestras cuando alguien busca algo
    final suggestionList = query.isEmpty?recentCities:cities.where((p)=>p.startsWith(query)).toList();
    return GridView.builder(
      itemCount: suggestionList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (BuildContext context, index){
        return Container(
          margin: EdgeInsets.only(bottom: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10,right: 5,top: 5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage("assets/images/food0.jpg"),
                      fit: BoxFit.cover
                    )
                  ),
                  child: Container(
                    margin: EdgeInsets.all(6),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.favorite_border,color: Colors.red,),
                        ],
                      )
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10,right: 10,top:5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(suggestionList[index],overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                    Row(
                      children: <Widget>[
                        Icon(Icons.timer,color: Colors.grey,size: 11,),
                        SizedBox(width: 5,),
                        Text("30~40 min",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

}