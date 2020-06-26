import 'package:connectivity/connectivity.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/pages/downloads.dart';
import 'package:food_size/src/pages/favorites.dart';
import 'package:food_size/src/pages/homeFood.dart';
import 'package:food_size/src/pages/search.dart';
import 'package:full_screen_menu/full_screen_menu.dart';

class Foods extends StatefulWidget {
  Foods({Key key}) : super(key: key);

  @override
  _FoodsState createState() => _FoodsState();
}

class _FoodsState extends State<Foods> {
  PageController _controller = PageController(initialPage:0);
  List recipes = [];
  @override
  void initState(){
    super.initState();
  }

  Future connectionState() async {
    var result = await Connectivity().checkConnectivity();
    bool actualStateConnection;
    if (result == ConnectivityResult.none) {
      actualStateConnection=false;
    } else if(result == ConnectivityResult.mobile) {
      actualStateConnection=true;
    }else if(result == ConnectivityResult.wifi){
      actualStateConnection=true;
    }
    return actualStateConnection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: connectionState(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          bool checkConnection = snapshot.data;
          if(checkConnection==null){
            return Center(
              child: CircularProgressIndicator(),
            );
          }else{
            return Stack(
              children: <Widget>[
                PageView(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    checkConnection?HomeFood():notConnection(),
                    checkConnection?Search():notConnection(),
                    Download(),
                    checkConnection?Favorites():notConnection()
                  ],
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){menuFullScreen();},
        child: Container(
          padding: EdgeInsets.all(8),
          child: FlareActor('assets/animations/salad.flr',),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 0.0,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0)
            ),
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
                        _controller.jumpToPage(1);
                        // showSearch(context: context, delegate: DataSearch());
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
                        _controller.jumpToPage(2);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_border,color: Colors.red),
                      onPressed: (){
                        _controller.jumpToPage(3);
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
  menuFullScreen(){
    return FullScreenMenu.show(
      context,
      backgroundColor: Colors.black87,
      items: [
        FSMenuItem(
          icon: Icon(Icons.recent_actors, color: Colors.white),
          text: Text('Social Media',style: TextStyle(color: Colors.white),),
        ),
        FSMenuItem(
          icon: Icon(Icons.view_carousel, color: Colors.white),
          text: Text('Recipes',style: TextStyle(color: Colors.white),),
        ),
        FSMenuItem(
          icon: Icon(Icons.restaurant_menu, color: Colors.white),
          text: Text('Restaurants',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
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