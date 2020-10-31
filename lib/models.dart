final columnId = '_id';
final columnBook = 'b';
final columnName = 'n';
final columnNameAlt = '_n';
final columnVId = 'id';
final columnChapter = 'c';
final columnVerse = 'v';
final columnText = 't';

class Kitab {
  int id;
  String name;
  String altName;

  Kitab({this.id, this.name, this.altName});

  Kitab.fromMap(Map<String, dynamic> map) {
    id = map[columnBook];
    name = map[columnName];
    altName = map[columnNameAlt];
  }
}

class Pasal {
  int id;
  int book;
  String name;
  int chapter;

  Pasal({this.id, this.book, this.name, this.chapter});

  Pasal.fromMap(Map<String, dynamic> map) {
    this.id = map[columnId];
    this.name = map[columnName];
    this.book = map[columnBook];
    this.chapter = map[columnChapter];
  }

  Pasal.fromAddBook(Map<String, dynamic> map, Kitab book) {
    this.id = map[columnId];
    this.name = book.name;
    this.book = book.id;
    this.chapter = map[columnChapter];
  }

  @override
  String toString() {
    return '$name($book) $chapter';
  }
}

class Ayat {
  int id;
  int book;
  int chapter;
  int verse;
  String text;
  String bookName;

  Ayat.fromMap(Map<String, dynamic> map) {
    this.id = map[columnVId];
    this.book = map[columnBook];
    this.chapter = map[columnChapter];
    this.verse = map[columnVerse];
    this.text = map[columnText];
    this.bookName = map[columnName];
  }

  @override
  String toString() {
    return bookName.toString() +
        (book?.toString() ?? 'Book') +
        (chapter?.toString() ?? 'Chapter') +
        (verse?.toString() ?? 'Verse') +
        (text?.toString() ?? 'Text');
  }
}
