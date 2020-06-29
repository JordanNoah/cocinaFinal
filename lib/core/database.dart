import 'dart:io';
import 'package:food_size/models/recipe_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class ClientDatabaseProvider {
  ClientDatabaseProvider._();

  static final ClientDatabaseProvider db = ClientDatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "recipes.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
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
    });
  }

  //lista de querys
  //Todas las recetas
  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    List<Map<String, dynamic>> response = await db.query('recipes');
    return response.map((f) => Recipe.fromMap(f)).toList();
  }

  //receta especifica
  Future<Recipe> getRecipeWithId(int id) async {
    final db = await database;
    var responseRecipe =
        await db.query("recipes", where: "idRecipe = ?", whereArgs: [id]);
    return responseRecipe.isNotEmpty
        ? Recipe.fromMap(responseRecipe.first)
        : null;
  }

  Future<List<dynamic>> getStepsRecipeWithId(int id) async {
    final db = await database;
    List<Map<String, dynamic>> responseSteps =
        await db.query("steps_recipes", where: "idRecipe = ?", whereArgs: [id]);
    return responseSteps;
  }

  Future<List> getIngredientsRecipeWithId(int id) async {
    final db = await database;
    List responseIngredients = await db.rawQuery(
        "SELECT * from recipe_ingredients INNER JOIN ingredients on ingredients.idIngredient=recipe_ingredients.idIngredient WHERE idRecipe = $id");
    return responseIngredients;
  }

  Future<List<dynamic>> getRecipeAsList(int id) async {
    final db = await database;
    var responseRecipe =
        await db.query("recipes", where: "idRecipe = ?", whereArgs: [id]);
    return responseRecipe;
  }

  getImage(int id) async {
    final db = await database;
    List responseImages =
        await db.rawQuery("SELECT * from image_recipes where idRecipe=$id");
    return responseImages;
  }

  getImgProfileRecipe(int id) async {
    final db = await database;
    List responseImages = await db.rawQuery(
        "SELECT route FROM image_recipes where principal = 1 AND idRecipe = $id LIMIT 1");
    return responseImages.length == 0 ? null : responseImages[0]["route"];
  }

  getImgIngredient(int id) async {
    final db = await database;
    List responseImages = await db.rawQuery(
        "SELECT routeImage FROM ingredients where idIngredient = $id LIMIT 1");
    return responseImages.length == 0 ? null : responseImages[0]["routeImage"];
  }

  removeRecipe(int idRecipe) async {
    final db = await database;
    var remove = await db.transaction((trc) async {
      var existRecipe = await trc
          .query("recipes", where: "idRecipe = ?", whereArgs: [idRecipe]);
      if (existRecipe.isNotEmpty) {
        var removeRecipe = await trc
            .delete('recipes', where: "idRecipe = ?", whereArgs: [idRecipe]);
        var removeSteps = await trc.delete("steps_recipes",
            where: "idRecipe = ?", whereArgs: [idRecipe]);
        //
        var imagesRecipe = await trc.query("image_recipes",
            where: "idRecipe = ?", whereArgs: [idRecipe]);
        //
        var removeImage = await trc.delete("image_recipes",
            where: "idRecipe = ?", whereArgs: [idRecipe]);
        var removeIngredientsRecipe = await trc.delete("recipe_ingredients",
            where: "idRecipe = ?", whereArgs: [idRecipe]);
        if (removeRecipe != null &&
            removeSteps != null &&
            removeImage != null &&
            removeIngredientsRecipe != null) {
          for (final images in imagesRecipe) {
            if (images["route"] != "default.jpg") {
              final Directory extDir = await getExternalStorageDirectory();
              var direcImage =
                  File(extDir.path + '/recipe/recipes/' + images["route"]);
              var exist = await direcImage.exists();
              if (exist) {
                await direcImage.delete();
              }
            }
          }
          return 1;
        } else {
          return 0;
        }
      } else {
        return 2;
      }
    });
    return remove;
  }
}
