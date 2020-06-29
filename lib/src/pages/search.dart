import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_size/src/widgets/showRate.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var _textController = TextEditingController();
  List searchRecipes = [];
  bool checkConnection = true;
  String textSearch = "";

  List<StaggeredTile> _tiles;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool reachFinalRecipe = false;

  bool hasLetter = false;

  @override
  void initState() {
    super.initState();
    searchRecipe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Container(
            child: Card(
              elevation: 9,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      autocorrect: false,
                      onChanged: (text) {
                        if (text.length != 0) {
                          hasLetter = true;
                        } else {
                          hasLetter = false;
                        }
                        if (mounted) {
                          setState(() {
                            textSearch = text;
                          });
                        }
                        searchRecipe();
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.transparent, width: 1.0),
                        ),
                        hintText: "Search recipes",
                      ),
                    ),
                  ),
                  Builder(builder: (BuildContext context) {
                    if (hasLetter) {
                      return IconButton(
                          onPressed: () {
                            _textController.clear();
                            if (mounted) {
                              setState(() {
                                hasLetter = false;
                                textSearch = "";
                              });
                            }
                            searchRecipe();
                          },
                          icon: Icon(Icons.close));
                    } else {
                      return IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.search),
                      );
                    }
                  })
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropHeader(),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = reachFinalRecipe
                            ? Text("Has reach the final")
                            : Text("pull up load");
                      } else if (mode == LoadStatus.loading) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = Text("Load Failed!Click retry!");
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text("release to load more");
                      } else {
                        body = Text("No more Data");
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: StaggeredGridView.countBuilder(
                    primary: false,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    addRepaintBoundaries: true,
                    crossAxisCount: 4,
                    itemBuilder: _getChild,
                    staggeredTileBuilder: _getTile,
                    itemCount: searchRecipes.length,
                  )),
            ),
          ),
        ],
      )),
    );
  }

  StaggeredTile _getTile(int index) => _tiles[index];

  Widget _getChild(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed("/showfood",
            arguments: [searchRecipes[index]["idRecipe"], true]);
      },
      child: Container(
        key: ObjectKey('$index'),
        child: Card(
            elevation: 5,
            margin: EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: "http://3.23.131.0:3002/" +
                      (searchRecipes[index]["recipe_images"][0]["route"])
                          .replaceAll(r"\", '/'),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Icon(Icons.error), Text("Not found")],
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        searchRecipes[index]["title"],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ShowRate(
                        countOfReview: searchRecipes[index]["countOfReview"],
                        totalAssessment: searchRecipes[index]
                            ["totalAssessment"],
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  Future searchRecipe() async {
    try {
      http.Response responseRecipe = await http.get(
          'http://3.23.131.0:3002/api/searchRecipe?querySearch=$textSearch');
      if (responseRecipe.statusCode == HttpStatus.ok) {
        searchRecipes = jsonDecode(responseRecipe.body)["message"];
        _tiles = _generateRandomTiles(searchRecipes).toList();
      }
    } on Exception catch (e) {
      if (e.toString().contains('SocketException')) {}
    }
    setState(() {});
  }

  void _onRefresh() async {
    // monitor network fetch
    if (hasLetter) {
      searchRecipe();
    } else {
      searchRecipe();
    }
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    try {
      http.Response responseRecipe;
      responseRecipe = await http.get(
          'http://3.23.131.0:3002/api/searchRecipe?querySearch=$textSearch');
      String resRecipe = responseRecipe.body;
      final List jsonRecipe = jsonDecode(resRecipe)["message"];
      if (jsonRecipe.length == 0) {
        reachFinalRecipe = true;
        searchRecipes.addAll(jsonRecipe);
      }
      setState(() {
        _tiles = _generateRandomTiles(searchRecipes).toList();
      });
      _refreshController.loadComplete();
    } catch (e) {
      _refreshController.loadFailed();
    }
    // if failed,use loadFailed(),if no data return,use LoadNodata()
  }
}

List<StaggeredTile> _generateRandomTiles(List recipes) {
  return List.generate(recipes.length, (i) => StaggeredTile.fit(2));
}
