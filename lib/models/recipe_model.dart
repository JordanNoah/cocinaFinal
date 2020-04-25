class Recipe{
  int idRecipe;
  String title;
  String description;

  Recipe({this.idRecipe, this.title, this.description});

  Map<String,dynamic> toMap() => {
    "idRecipe":idRecipe,
    "title":title,
    "description":description
  };

  Recipe.fromMap(Map<String,dynamic> map){
    idRecipe=map["idRecipe"];
    title=map["title"];
    description=map["description"];
  }
}