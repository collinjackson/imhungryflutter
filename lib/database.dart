import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class DatabaseClient {
  Database _db;

  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, "database.db");

    _db = await openDatabase(dbPath, version: 1,
        onCreate: this._create);
  }

  Future _create(Database db, int version) async {
    await db.execute("""
            create table recipes (
            _id text primary key,
            server_id text,
            country text not null,
            title text not null,
            ingredients text not null,
            preparation text not null,
            image_name text not null,
            source text not null,
            original_id integer not null,
            original_image text not null,
            tags text not null,
            updated text)""");
  }

  Future upsertRecipe(Recipe recipe) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery("SELECT COUNT(*) FROM recipes WHERE original_id = ?", [recipe.original_id]));
    if (count == 0) {
      recipe.original_id = await _db.insert("recipes", recipe.toMap());
    } else {
      await _db.update("recipes", recipe.toMap(), where: "id = ?", whereArgs: [recipe.original_id]);
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

    List stories = new List();
    results.forEach((result) {
      Recipe story = Recipe.fromMap(result);
      stories.add(story);
    });

    return stories;
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
  String source_text;
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
                          "source_text",
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

    return map;
  }

  static fromMap(Map map) {
    Recipe recipe = new Recipe();
    recipe.original_id = map["original_id"];
    recipe.title = map["title"];

    return recipe;
  }


}