import 'dart:io';
import 'package:food_size/models/imagesRecipe.dart';
import 'package:food_size/models/ingredient.dart';
import 'package:food_size/models/ingredientsRecipe_model.dart';
import 'package:food_size/models/recipe_model.dart';
import 'package:food_size/models/stepsRecipe_model.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class ClientDatabaseProvider{
  ClientDatabaseProvider._();

  static final ClientDatabaseProvider db = ClientDatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "recipes.db");
    return await openDatabase(path,version:1,
      onCreate: (Database db,int version) async {
        await db.execute("CREATE TABLE recipes("
        "idRecipe integer,"
        "title text,"
        "description text,"
        "difficulty text,"
        "aproxTime text"
        ")");
        await db.execute("CREATE TABLE steps_recipes("
        "idStep integer,"
        "description text,"
        "stepNumber integer,"
        "idRecipe integer,"
        "FOREIGN KEY(idRecipe) REFERENCES recipes(idRecipe) ON DELETE CASCADE"
        ")");
        await db.execute("CREATE TABLE ingredients("
        "idIngredient integer,"
        "name text,"
        "routeImage text"
        ")");
        await db.execute("CREATE TABLE recipe_ingredients("
        "idRecipeIngredient integer,"
        "quantity text,"
        "optional integer,"
        "moreOptions text,"
        "idIngredient integer,"
        "idRecipe integer,"
        "FOREIGN KEY(idIngredient) REFERENCES ingredient(idIngredient),"
        "FOREIGN KEY(idRecipe) REFERENCES recipes(idRecipe) ON DELETE CASCADE"
        ")");
        await db.execute("CREATE TABLE image_recipes("
        "idImage integer,"
        "principal integer,"
        "route text,"
        "idRecipe integer,"
        "FOREIGN KEY(idRecipe) REFERENCES recipes(idRecipe) ON DELETE CASCADE"
        ")");
      }
    );
  }

  //lista de querys
  //Todas las recetas 
  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    List<Map<String,dynamic>> response = await db.query('recipes');
    return response.map((f)=>Recipe.fromMap(f)).toList();
  }

  //receta especifica
  Future<Recipe> getRecipeWithId(int id) async {
    final db = await database;
    var responseRecipe = await db.query("recipes", where: "idRecipe = ?", whereArgs: [id]);
    return responseRecipe.isNotEmpty ? Recipe.fromMap(responseRecipe.first) : null;
  }
  
  Future<List<StepsRecipe>> getStepsRecipeWithId(int id) async {
    final db = await database;
    List<Map<String,dynamic>> responseSteps = await db.query("steps_recipes",where:"idRecipe = ?",whereArgs: [id]);
    return responseSteps.map((f)=>StepsRecipe.fromMap(f)).toList();
  }

  Future <List> getIngredientsRecipeWithId(int id) async {
    final db = await database;
    List responseIngredients = await db.rawQuery("SELECT * from recipe_ingredients INNER JOIN ingredients on ingredients.idIngredient=recipe_ingredients.idIngredient WHERE idRecipe = $id");
    return responseIngredients;
  }

  getImage(int id) async {
    final db = await database;
    List responseImages = await db.rawQuery("SELECT * from image_recipes where idRecipe=$id");
    return responseImages;
  }

  getImgProfileRecipe(int id) async{
    final db = await database;
    List responseImages = await db.rawQuery("SELECT route FROM image_recipes where principal = 1 AND idRecipe = $id LIMIT 1");
    print(responseImages.length);
    return responseImages.length==0?null:responseImages[0]["route"];
  }

  addRecipeToDatabase (Recipe recipe,List steps,List imageRecipe,List multiRecipeIngredient, bool images) async {
    final db = await database;
    //recipe ya pasa como modelo
    var insert = await db.transaction((trc) async {
      var existRecipe = await trc.query("recipes",where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
      if(existRecipe.isEmpty){
        var responseRecipe = await trc.insert("recipes",recipe.toMap());
        var responseStep;
        var responseImg;

        var responseRecipeIngre;
        for(final stepObj in steps){
          var step = StepsRecipe(
            idStep:stepObj["idStep"],
            description: stepObj["description"],
            stepNumber: stepObj["stepNumber"],
            idRecipe: stepObj["idRecipe"]
          );
          responseStep = await trc.insert("steps_recipes", step.toMap());
        }

        for(final imageRecipeObj in imageRecipe){
          var imgRecipe = ImageRecipe(
            idImage: imageRecipeObj["idImage"],
            principal: imageRecipeObj["principal"],
            route: imageRecipeObj["route"].replaceAll(r"\",'/').split("/").last,
            idRecipe: imageRecipeObj["idRecipe"]
          );
          responseImg = await trc.insert("image_recipes", imgRecipe.toMap());
          ///
          if (images) {
            await insertImage(imageRecipeObj["route"]);
          }
          ///
        }

        for(final multiRecipeIngredientObj in multiRecipeIngredient){
          var recipeIngredient = IngredientsRecipe(
            idRecipeIngredient: multiRecipeIngredientObj["idRecipeIngredient"],
            quantity: multiRecipeIngredientObj["quantity"],
            optional: multiRecipeIngredientObj["optional"]?1:0,
            moreOptions: multiRecipeIngredientObj["moreOptions"],
            idIngredient: multiRecipeIngredientObj["idIngredient"],
            idRecipe: multiRecipeIngredientObj["idRecipe"]
          );
          var ingredient = Ingredient(
            idIngredient: multiRecipeIngredientObj["ingredient"]["idIngredient"],
            name: multiRecipeIngredientObj["ingredient"]["name"],
            routeImage: multiRecipeIngredientObj["ingredient"]["routeImage"].replaceAll(r"\",'/').split("/").last,
          );
          if(images){
            await insertImage(multiRecipeIngredientObj["ingredient"]["routeImage"]);
          }
          var existIngredient = await trc.query("ingredients",where: "idIngredient = ?", whereArgs: [ingredient.idIngredient]);
          if(existIngredient.isEmpty){
            await trc.insert("ingredients", ingredient.toMap());
          }
          responseRecipeIngre = await trc.insert("recipe_ingredients", recipeIngredient.toMap());
        }
        if(responseStep!=null && responseRecipe!=null && responseRecipeIngre!=null && responseImg!=null){
          return 1;
        }else{
          return 0;
        }
      }else{
        return 0;
      }
    });
    return(insert);
  }

  insertImage(String route) async{
    var arrayRoute =route.replaceAll(r"\",'/').split("/");
    var type = arrayRoute[arrayRoute.length-2];
    if(type!="ingredient"){
      type="recipe";
    }
    print(type);
    String nameImage = arrayRoute.last;
      //////
      ///
      //
      try {
        // Saved with this method.
        final Directory extDir = await getExternalStorageDirectory();
        var direcImage = File(extDir.path+'/recipes/$type/$nameImage');
        var exist = await direcImage.exists();
        print(exist);
        if (!exist) {
          await ImageDownloader.downloadImage("http://3.23.131.0:3002/"+route.replaceAll(r"\",'/'),destination: AndroidDestinationType.custom(directory: "/recipes")..inExternalFilesDir()..subDirectory("$type/$nameImage"));
        }
      } catch (error) {
        print(error);
      }
      ///
  }

  removeRecipe(Recipe recipe) async {
    final db = await database;
    var remove = await db.transaction((trc) async{
      var existRecipe = await trc.query("recipes",where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
      if(existRecipe.isNotEmpty){
        var removeRecipe = await trc.delete('recipes',where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
        var removeSteps = await trc.delete("steps_recipes",where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
        //
        var imagesRecipe = await trc.query("image_recipes",where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
        //
        var removeImage = await trc.delete("image_recipes",where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
        var removeIngredientsRecipe = await trc.delete("recipe_ingredients",where: "idRecipe = ?", whereArgs: [recipe.idRecipe]);
        if(removeRecipe!=null&&removeSteps!=null&&removeImage!=null&&removeIngredientsRecipe!=null){
          for(final images in imagesRecipe){
            if(images["route"]!="default.jpg"){
              final Directory extDir = await getExternalStorageDirectory();
              var direcImage = File(extDir.path+'/recipe/recipes/'+images["route"]);
              var exist = await direcImage.exists();
              if(exist){
                await direcImage.delete();
              }
            }
          }
          return 1;
        }else{
          return 0;
        }
      }else{
        return 2;
      }
    });
    return remove;
  }
}