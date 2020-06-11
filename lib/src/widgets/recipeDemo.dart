import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_size/src/widgets/favoriteRecipe.dart';

class RecipeDemo extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final String urlImage;
  final String aproxTime;
  final int idRecipe;
  const RecipeDemo({Key key,@required this.title,@required this.isFavorite,@required this.urlImage,@required this.aproxTime,@required this.idRecipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){Navigator.of(context).pushNamed("/showfood",arguments: [idRecipe,true]);}, 
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 5,top: 5),                            
                child: Container(
                  margin: EdgeInsets.all(6),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height:MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: "http://3.23.131.0:3002/"+(urlImage).replaceAll(r"\",'/'),
                            progressIndicatorBuilder: (context, url, downloadProgress) => 
                              Center(child: CircularProgressIndicator(value: downloadProgress.progress),),
                            errorWidget: (context, url, error) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.error),Text("Not found")],),),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)
                          ),
                          gradient: LinearGradient(
                            stops: [
                              0.1,
                              0.3
                            ],
                            colors:[
                              Colors.black26,
                              Colors.transparent
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft
                          )
                        ),
                        child:Container(
                          alignment: Alignment.topRight,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)
                            ),
                            color: Colors.white,
                            child:FavoriteRecipe(liked: isFavorite,idRecipe: idRecipe,)
                          )
                        )
                      ),
                    ],
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
                  Text(title,overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500,fontSize: 12),),
                  Row(
                    children: <Widget>[
                      Icon(Icons.timer,color: Colors.grey,size: 11,),
                      SizedBox(width: 5,),
                      Text(aproxTime,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 10),),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}