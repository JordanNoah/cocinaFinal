import 'package:circular_menu/circular_menu.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_size/src/pages/downloads.dart';
import 'package:food_size/src/pages/favorites.dart';
import 'package:food_size/src/pages/homeFood.dart';

class Foods extends StatefulWidget {
  Foods({Key key}) : super(key: key);

  @override
  _FoodsState createState() => _FoodsState();
}

class _FoodsState extends State<Foods> {
  PageController _controller = PageController(initialPage: 0);
  bool checkConnection = false;
  @override
  void initState(){
    super.initState();
    connectionState();
  }

  Future connectionState() async {
    bool actualStateConnection = await DataConnectionChecker().hasConnection;
    setState((){
      checkConnection = actualStateConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          checkConnection?HomeFood():notConnection(),
          Download(),
          checkConnection?Favorites():notConnection()
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){},
        backgroundColor: Colors.orange.shade900,
        child: Container(
          height: 40.0,
          width: 40.0,
          child: Container(
            child: Stack(
              children: <Widget>[
                SvgPicture.asset('assets/images/ensalada.svg'),
                CircularMenu(
                alignment: Alignment.bottomCenter,
                radius: 100,
                toggleButtonMargin: 0.0,
                toggleButtonPadding: 0.0,
                toggleButtonElevation: 0,
                toggleButtonIconColor: Colors.transparent,
                toggleButtonColor: Colors.transparent,
                items: [
                    MenuItem(
                      iconSize: 20.0,
                      icon: Icons.supervised_user_circle,
                      color: Colors.green,
                      onTap: () {},
                      margin: 0,
                      padding: 0,
                    ),
                    MenuItem(
                      iconSize: 20.0,
                      icon: Icons.fastfood,
                      color: Colors.blue,
                      onTap: () {},
                      margin: 0,
                      padding: 0,
                    ),
                    MenuItem(
                      iconSize: 20.0,
                      icon: Icons.restaurant_menu,
                      color: Colors.orange,
                      onTap: () {},
                      margin: 0,
                      padding: 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                    IconButton(
                      icon: Icon(Icons.home,color: Color(0xFFEF7532)), 
                      onPressed: (){
                        _controller.jumpToPage(0);
                      }
                    ),
                    IconButton(
                      icon: Icon(Icons.search,color: Color(0xFF676E79)), 
                      onPressed: (){
                        showSearch(context: context, delegate: DataSearch());
                      },
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.file_download, color: Color(0xFFEF7532),),
                      onPressed: (){
                        _controller.jumpToPage(1);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border,color: Colors.red),
                      onPressed: (){
                        _controller.jumpToPage(2);
                      },
                    )
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
  ///
  
}

Widget notConnection(){
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.signal_wifi_off,color: Colors.black54,),
        Text("Not network connection"),
        SizedBox(height: 20,),
        IconButton(
          onPressed: (){},
          icon: Icon(Icons.network_check),
        )
      ],
    ),
  );
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