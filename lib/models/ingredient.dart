class Ingredient{
  int idIngredient;
  String name;
  String routeImage;

  Ingredient({this.idIngredient,this.name,this.routeImage});

  Map<String,dynamic> toMap() => {
    "idIngredient":idIngredient,
    "name":name,
    "routeImage":routeImage
  };

  factory Ingredient.fromMap(Map<String,dynamic> json) => new Ingredient(
    idIngredient:json["idIngredient"],
    name:json["name"],
    routeImage:json["routeImage"]
  );
}