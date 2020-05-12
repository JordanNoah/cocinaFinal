class Recipe{
  int idRecipe;
  String title;
  String description;
  String difficulty;
  String aproxTime;

  Recipe({this.idRecipe, this.title, this.description, this.difficulty, this.aproxTime});

  Map<String,dynamic> toMap() => {
    "idRecipe":idRecipe,
    "title":title,
    "description":description,
    "difficulty":difficulty,
    "aproxTime":aproxTime
  };

  Recipe.fromMap(Map<String,dynamic> map){
    idRecipe=map["idRecipe"];
    title=map["title"];
    description=map["description"];
    difficulty=map["difficulty"];
    aproxTime=map["aproxTime"];
  }
}