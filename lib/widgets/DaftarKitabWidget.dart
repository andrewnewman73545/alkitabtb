import 'dart:async';

import 'package:alkitabtb/database.dart';
import 'package:alkitabtb/models.dart';
import 'package:alkitabtb/pages/pasal.dart';
import 'package:flutter/material.dart';

class DaftarKitabWidget extends StatefulWidget {
  final Kitab kitabx;

  const DaftarKitabWidget({Key key, this.kitabx}) : super(key: key);

  @override
  _DaftarKitabWidgetState createState() {
    return _DaftarKitabWidgetState(currentBook: this.kitabx);
  }
}

class _DaftarKitabWidgetState extends State<DaftarKitabWidget> {
  final db = DatabaseProvider();
  Kitab currentBook;

  _DaftarKitabWidgetState({this.currentBook});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Kitab>>(
      future: _GET_KITAB(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data != null) {
            return BookList(snapshot.data, (book) => _GOTO_KITAB(book));
          } else {
            return Text('Something is wrong');
          }
        } else if (snapshot.hasError) {
          return Text("""
          Error reading from the database.
          The error is ${snapshot.error}.
          Please try again :-);          
          """);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future<List<Kitab>> _GET_KITAB() async {
    await db.openDefault(context);
    return db.getBooks();
  }

  _GOTO_KITAB(Kitab book) {
    Navigator.push(context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return ChapterListPage(book: book);
    }));
  }
}

class BookList extends StatelessWidget {
  final List<Kitab> kitabxx;
  final callback;

  BookList(this.kitabxx, this.callback);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            child: Card(
              elevation: 0,
              child: ListTile(
                onTap: () => callback(kitabxx[index]),
                title: Text(
                  '${kitabxx[index].name}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
          );
        },
        itemCount: kitabxx.length,
      ),
    );
  }

  _goToBook(Kitab book) {
    print(book.name);
  }
}
