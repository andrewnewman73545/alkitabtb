import 'dart:async';

import 'package:alkitabtb/database.dart';
import 'package:alkitabtb/models.dart';
import 'package:flutter/material.dart';

class BacaPage extends StatefulWidget {
  final Kitab kitabx;
  final Pasal pasalx;

  const BacaPage({Key key, @required this.kitabx, @required this.pasalx})
      : super(key: key);

  @override
  _BacaPageState createState() => _BacaPageState(this.kitabx, this.pasalx);
}

class _BacaPageState extends State<BacaPage> {
  final DatabaseProvider db = DatabaseProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController bottomSheetController;
  Kitab kitabx;
  Pasal pasalx;
  List<Ayat> ayatx;
  List<int> selectedIndices = List();

  _BacaPageState(this.kitabx, this.pasalx) {}

  @override
  Widget build(BuildContext context) {
    if (this.kitabx == null || this.pasalx == null) {
      return Container(
        color: Colors.white,
        child: Text("""Fatal Error. Please retry.
        Error caused by no either no book or chapter passed."""),
      );
    }
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: FutureBuilder(
            future: db.openDefault(context).then((v) => db.getBook(kitabx.id)),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Text(
                    snapshot.data.name + " " + this.pasalx.chapter.toString());
              }
              return Text(
                  this.kitabx.name + " " + this.pasalx.chapter.toString());
            },
          ),
        ),
        body: _buildBody());
  }

  Widget _buildBody() {
    return Container(
      child: FutureBuilder<List<Ayat>>(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              return _buildVerseList(context);
            } else {
              return Center(
                child: Text('Database returned nothing.'),
              );
            }
          } else if (snapshot.hasError) {
            return Text("""An error occured (READ).
              The error is :
              ${snapshot.error}""");
          }
          return Center(child: CircularProgressIndicator());
        },
        future: _getChapter(),
      ),
    );
  }

  Widget _buildVerseList(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return VerseItem(
          verse: this.ayatx[index],
          isSelected: selectedIndices.contains(index),
          index: index,
          isSelectionMode: selectedIndices.length > 0,
          callback: () => _onSelectElement(index),
        );
      },
      itemCount: this.ayatx.length,
    );
  }

  Future<List<Ayat>> _getChapter() async {
    await db.openDefault(context);
    var v = await db.getVerses(this.pasalx);
    Kitab b;
    if (this.pasalx.book != null)
      b = await db.getBook(this.pasalx.book);
    else
      b = await db.findBook(this.pasalx.name);
    this.ayatx = v ?? this.ayatx;
    this.kitabx = b ?? this.kitabx;
    return this.ayatx;
  }

  _update() async {
    var v = await db.getVerses(this.pasalx);
    var b = await db.getBook(this.pasalx.book);
    setState(() {
      this.ayatx = v ?? this.ayatx;
      this.kitabx = b ?? this.kitabx;
    });
  }

  _onSelectElement(index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
  }
}

class VerseItem extends StatefulWidget {
  final int index;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback callback;
  final Ayat verse;

  const VerseItem(
      {Key key,
      this.index,
      this.isSelected,
      this.isSelectionMode,
      this.callback,
      this.verse})
      : super(key: key);

  @override
  _VerseItemState createState() => _VerseItemState();
}

class _VerseItemState extends State<VerseItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        onTap: widget.isSelectionMode ? widget.callback : null,
        onLongPress: widget.callback,
        title: Text(
          "${this.widget.verse.chapter}:${widget.index + 1}  ${widget.verse.text}",
        ),
      ),
    );
  }
}
