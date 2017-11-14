import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseClient {
  Database _db;

  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, "database.db");

    _db = await openDatabase(dbPath, version: 5,
        onCreate: this._create);
  }

  Future close() async {
    await _db.close();
  }

  Future _create(Database db, int version) async {
    await db.execute("""DROP TABLE IF EXISTS recipes""");
    await db.execute("""
            create table recipes (
            _id text primary key,
            server_id text,
            country text,
            title text not null,
            ingredients text,
            preparation text,
            image_blob text,
            image_name text,
            source_url text,
            original_id integer not null,
            original_image text,
            tags text,
            updated text)""");
  }

  Future upsertRecipe(Recipe recipe) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery("SELECT COUNT(*) FROM recipes WHERE original_id = ?", [recipe.original_id]));
    if (count == 0) {
      recipe.original_id = await _db.insert("recipes", recipe.toMap());
    } else {
      await _db.update("recipes", recipe.toMap(), where: "original_id = ?", whereArgs: [recipe.original_id]);
    }

    return recipe;
  }

  Future fetchRecipe(int original_id) async {
    List results = await _db.query("recipes", columns: Recipe.columns, where: "original_id = ?", whereArgs: [original_id]);

    Recipe recipe = Recipe.fromMap(results[0]);

    return recipe;
  }

  Future<List> fetchLatestRecipes(int limit) async {
    List results = await _db.query("recipes", columns: Recipe.columns, limit: limit, orderBy: "original_id DESC");

    List recipes = new List();
    results.forEach((result) {
      Recipe aRecipe = Recipe.fromMap(result);
      recipes.add(aRecipe);
    });

    return recipes;
  }
}


class Recipe {
  Recipe();

  String server_id;
  String country;
  String title;
  String ingredients;
  String preparation;
  String image_name;
  String image_blob;
  String source_url;
  int original_id;
  String original_image;
  String tags;
  String updated;


  static final columns = ["server_id",
                          "country",
                          "title",
                          "ingredients",
                          "preparation",
                          "image_name",
                          "image_blob",
                          "source_url",
                          "original_id",
                          "original_image",
                          "tags",
                          "updated"];

  Map toMap() {
    Map map = {
      "title": title,
    };

    if (original_id != null) {
      map["original_id"] = original_id;
    }
    map["image_blob"] = image_blob;
    return map;
  }

  static fromMap(Map map) {
    Recipe recipe = new Recipe();
    recipe.original_id = map["original_id"];
    recipe.title = map["title"];
    recipe.image_blob = map["image_blob"];

    return recipe;
  }
}