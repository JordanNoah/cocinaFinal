class StepsRecipe{
  int idStep;
  String description;
  int stepNumber;
  int idRecipe;

  StepsRecipe({this.idStep,this.description,this.stepNumber,this.idRecipe});
  
  Map<String,dynamic> toMap() => {
    "idStep":idStep,
    "description":description,
    "stepNumber":stepNumber,
    "idRecipe":idRecipe
  };

  factory StepsRecipe.fromMap(Map<String,dynamic> json) => new StepsRecipe(
    idStep:json["idStep"],
    description:json["description"],
    stepNumber:json["stepNumber"],
    idRecipe:json["idRecipe"]
  );
}