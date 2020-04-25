class IngredientsRecipe{
  int idRecipeIngredient;
  String quantity;
  int optional;
  String moreOptions;
  int idIngredient;
  int idRecipe;

  IngredientsRecipe({this.idRecipeIngredient,this.quantity,this.optional,this.moreOptions,this.idIngredient,this.idRecipe});

  Map<String,dynamic> toMap() => {
    "idRecipeIngredient":idRecipeIngredient,
    "quantity":quantity,
    "optional":optional,
    "moreOptions":moreOptions,
    "idIngredient":idIngredient,
    "idRecipe":idRecipe
  };

  factory IngredientsRecipe.fromMap(Map<String,dynamic> json) => new IngredientsRecipe(
    idRecipeIngredient:json["idRecipeIngredient"],
    quantity:json["quantity"],
    optional:json["optional"],
    moreOptions:json["moreOptions"],
    idIngredient:json["idIngredient"],
    idRecipe:json["idRecipe"],
  );
}