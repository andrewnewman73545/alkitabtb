import 'dart:async';
import 'dart:io';

import 'package:alkitabtb/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

const String DATA_INITIALISED = "DATA_INITIALISED";
final String databaseName = "bible-data.db";

class DatabaseProvider {
  BuildContext context;
  Database db;
  String keyTable = 'key_english';

  String textTable = 't_bbe';
  final _lock = new Lock();

  Future openDefault(BuildContext context) async {
//    Directory appDocDir = await getApplicationDocumentsDirectory();
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);
    await this.open(path);
    this.context = context;

    this.keyTable = 'key_english';
    this.textTable = 't_bbe';
  }

  Future open(String path) async {
    if (db != null) return;
    await _lock.synchronized(() async {
      // Check again once entering the synchronized block
      if (db != null) return;
      await _prepareDatabase();
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {},
      );
    });
  }

  Future<Kitab> getBook(int id) async {
    List<Map> devotionals = await db.query(
      keyTable,
      columns: [columnBook, columnName],
      where: "$columnBook = ?",
      whereArgs: [id],
    );
    if (devotionals.length > 0) {
      return Kitab.fromMap(devotionals.first);
    }
    return null;
  }

  ///Method return a book from the database based on the passed name
  ///The method searches both of the key_tables, with priority to the current
  ///language table.
  Future<Kitab> findBook(String name) async {
    List<Map> books = await db.query(
      keyTable,
      columns: [columnBook, columnName],
      where: "$columnName = ?",
      whereArgs: [name],
    );
    if (books.length > 0) {
      return Kitab.fromMap(books.first);
    } else {
      if (books.length > 0) {
        return Kitab.fromMap(books.first);
      } else {
        if (books.length == 1) {
          return Kitab.fromMap(books.first);
        } else {}
      }
    }
    return null;
  }

  Future<List<Kitab>> getBooks() async {
    if (db == null) {
      print('null db');
    }
    List<Map> books = await db.rawQuery(""
        "SELECT $keyTable.b, $keyTable.n "
        " FROM '$keyTable' ");
    if (books.length > 0) {
      return books.map((book) => Kitab.fromMap(book)).toList();
    }
    return null;
  }

  Future<List<Pasal>> getChapters(Kitab book) async {
    List<Map> chapters = await db.query(textTable,
        where: "$columnBook = ?",
        columns: [columnBook, columnChapter],
        whereArgs: [book.id],
        distinct: true);

    if (chapters.length > 0) {
      return chapters
          .map((chapter) => Pasal.fromAddBook(chapter, book))
          .toList();
    }
    return null;
  }

  Future<List<Ayat>> getVerses(Pasal chapter) async {
    List<Map> verses = List();
    int book = chapter.book;

    if (book == null) {
      var _book = await this.findBook(chapter.name);
      book = _book?.id;
    }

    if (book != null) {
      verses = await db.query(
        textTable,
        where: "$columnBook = ? AND $columnChapter = ?",
        whereArgs: [book, chapter.chapter],
      );
    } else {
      throw ArgumentError.value(chapter, 'Failed to read the chapter');
    }

    if (verses.length > 0) {
      return verses.map((verse) => Ayat.fromMap(verse)).toList();
    }

    verses = await db.query(textTable);
    if (verses.length > 0) {
      return verses.map((verse) => Ayat.fromMap(verse)).toList();
    }
    throw Exception('Database returns : ' + verses.toString());
  }

  Future<List<Ayat>> searchText(String queryText) async {
    List<Map> verses = await db.query(
      "$textTable left join $keyTable on $textTable.b = $keyTable.b",
      where: "$columnText LIKE '%$queryText%'",
    );
    if (verses.length < 1) {
      verses = await db.query(
        "$textTable left join $keyTable on $textTable.b = $keyTable.b",
        where: "$columnText LIKE '%$queryText%'",
      );
    }
    if (verses.length > 0) {
      return verses.map((verse) => Ayat.fromMap(verse)).toList();
    }
    return List();
  }

  Future close() async => db.close();

  _prepareDatabase({bool overwrite = false}) async {
    // Construct a file path to copy database to
//    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);

    // Only copy if the database doesn't exist or to clear errors
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('assets', databaseName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      File(path).createSync(recursive: true);
      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
      print('created new database');
    }

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {},
    );

    List<Map> shonaTextTableColumns =
        await db.rawQuery("PRAGMA table_info(t_shona)");
    if (shonaTextTableColumns.length > 0) {
      bool valid = false;
      shonaTextTableColumns.forEach((c) {
        print(c);
        if (c['_id'] != null) {
          valid = true;
        }
      });
      if (valid) return;
      await db.execute("DROP TABLE IF EXISTS text_temp");
      await db.execute("CREATE TABLE text_temp as SELECT * from t_shona");
      await db.execute("DROP TABLE t_shona");
      await db.execute("CREATE TABLE t_shona ($columnId INTEGER PRIMARY KEY,"
          "$columnBook INTEGER, "
          "$columnChapter INTEGER, "
          "$columnVerse INTEGER, "
          "$columnText TEXT)");
      await db.execute("INSERT INTO t_shona"
          "($columnId, $columnBook, $columnChapter, $columnVerse, $columnText)"
          "SELECT "
          "rowid as $columnId, $columnBook, $columnChapter, $columnVerse, $columnText"
          " from text_temp");
      shonaTextTableColumns = await db.rawQuery("PRAGMA table_info(t_shona)");
      if (shonaTextTableColumns.length > 0) {
        valid = false;
        shonaTextTableColumns.forEach((c) {
          print(c);
          if (c['_id'] != null) {
            valid = true;
          }
        });
        if (valid) {
          await db.execute("DROP TABLE text_temp");
        }
      }
    }
    //prefs.setBool(DATA_INITIALISED, true);
  }
}
