class ImageRecipe{
  int idImage;
  int principal;
  String route;
  int idRecipe;

  ImageRecipe({this.idImage,this.principal,this.route,this.idRecipe});

  Map<String,dynamic> toMap() => {
    "idImage":idImage,
    "principal":principal,
    "route":route,
    "idRecipe":idRecipe
  };

  factory ImageRecipe.fromMap(Map<String,dynamic> json) => new ImageRecipe(
    idImage:json["idImage"],
    principal:json["principal"],
    route:json["route"],
    idRecipe:json["idRecipe"]
  );
}