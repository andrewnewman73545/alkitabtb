import 'dart:io';

import 'package:alkitabtb/database.dart';
import 'package:alkitabtb/models.dart';
import 'package:alkitabtb/pages/baca_ayat.dart';
import 'package:flutter/material.dart';

class ChapterListPage extends StatefulWidget {
  final List<Pasal> chapters;
  final Kitab book;

  const ChapterListPage({Key key, this.chapters, this.book}) : super(key: key);

  @override
  ChapterListPageState createState() {
    return new ChapterListPageState();
  }
}

class ChapterListPageState extends State<ChapterListPage> {
  final DatabaseProvider db = DatabaseProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book.name}\nPilih Pasal'),
      ),
      body: FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return ChapterList(
              book: widget.book,
              chapters: snapshot.data,
            );
          } else if (snapshot.hasError) {
            return Text('Error');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
        future: _getChapters(),
      ),
    );
  }

  Future<List<Pasal>> _getChapters() async {
    await db.openDefault(context);
    return db.getChapters(widget.book);
  }
}

class ChapterList extends StatelessWidget {
  final List<Pasal> chapters;
  final Kitab book;

  const ChapterList({Key key, this.chapters, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 6,
      children: List.generate(this.chapters.length, (index) {
        return InkWell(
          onTap: () {
            _goToChapter(context, chapters[index]);
          },
          child: Center(
            heightFactor: 0.5,
            child: Text(
              '${chapters[index].chapter}',
            ),
          ),
        );
      }),
    );

    /*
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return AndroidListCard(
          child: ListTile(
            onTap: () => _goToChapter(context, chapters[index]),
            title: Text(
              '${chapters[index].chapter}',
              style: Theme.of(context).textTheme.body1,
            ),
          ),
        );
      },
      itemCount: this.chapters.length,
    );

     */
  }

  _goToChapter(BuildContext context, Pasal chapter) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return BacaPage(
        kitabx: this.book,
        pasalx: chapter,
      );
    }));
  }
}

class AndroidListCard extends StatelessWidget {
  final Widget child;

  const AndroidListCard({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 0,
        child: child,
      ),
    );
  }
}
