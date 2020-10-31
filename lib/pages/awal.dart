import 'dart:io';
import 'package:alkitabtb/database.dart';
import 'package:alkitabtb/models.dart';
import 'package:alkitabtb/pages/info.dart';
import 'package:alkitabtb/pages/pasal.dart';
import 'package:alkitabtb/pages/baca_ayat.dart';
import 'package:alkitabtb/theme.dart';
import 'package:alkitabtb/widgets/DaftarKitabWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AwalPage extends StatefulWidget {
  final int initialIndex;

  const AwalPage({Key key, this.initialIndex}) : super(key: key);

  @override
  AwalPageState createState() {
    return new AwalPageState();
  }
}

class AwalPageState extends State<AwalPage> {
  bool searching = false;
  bool dark = false;
  SearchDelegate _searchDelegate;
  ThemeData theme = getAppTheme(theme: "blue");
  Kitab kitabx;
  TabController tabController;

  int _bottomNavBarSelectedIndex;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _onBottomNavBarItemTapped(int index) {
    setState(() {
      _bottomNavBarSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    _searchDelegate = _MainSearchDelegate(_openBook, Theme.of(context));

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Flutter-Alkitab"),
        actions: <Widget>[
          _BUAT_TOOLBAR(context),
        ],
      ),
      body: [
        this.kitabx == null
            ? DaftarKitabWidget()
            : DaftarKitabWidget(kitabx: this.kitabx),
        InfoPage()
      ].elementAt(_bottomNavBarSelectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  @override
  void initState() {
    super.initState();
    _bottomNavBarSelectedIndex = widget.initialIndex;
  }

  _openBook(Kitab book) {
    setState(() {
      this.kitabx = book;
    });
  }

  IconButton _BUAT_TOOLBAR(BuildContext context) {
    return IconButton(
      tooltip: 'Pencarian',
      icon: const Icon(Icons.search),
      onPressed: () async {
        await showSearch<dynamic>(
          context: context,
          delegate: _searchDelegate,
        );
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.local_library),
          title: Text("Baca"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          title: Text("Info"),
        ),
        /*
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          title: Text(AppLocalizations.of(context).text('notes')),
        ),

         */
      ],
      currentIndex: _bottomNavBarSelectedIndex,
      selectedItemColor: Theme.of(context).accentColor,
      onTap: _onBottomNavBarItemTapped,
    );
  }
}

//TODO: Set the theme for search delegate to match rest of application
class _MainSearchDelegate extends SearchDelegate {
  final db = DatabaseProvider();
  final ThemeData theme;
  final void Function(Kitab) _openBook;

  _MainSearchDelegate(this._openBook, this.theme);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        tooltip: 'Bersihkan',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: db.openDefault(context).then((_) => db.searchText(query)),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null && snapshot.data.length > 0) {
                List<Ayat> results = snapshot.data;
                return Column(
                  children: <Widget>[
                    Text(
                      results.length.toString() + ' results',
                      style: Theme.of(context).textTheme.body1,
                    ),
                    Expanded(child: _resultList(results))
                  ],
                );
              } else {
                return Text('Nothing.');
              }
            } else if (snapshot.hasError) {
              return Text("""An error has occured,
              ${snapshot.error}
              Please retry.""");
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Waiting for resultss'),
                CircularProgressIndicator(),
              ],
            );
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Kitab>>(
        future: db.openDefault(context).then((value) => db.getBooks()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<Kitab> allBooks = snapshot.data.toList();
            List<Kitab> suggestions = allBooks
                .where((book) =>
                    book.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
            if (suggestions.length > 0) {
              return _suggestionList(suggestions);
            }
          } else if (snapshot.hasError) {
            return Text("""Error
            ${snapshot.error}""");
          }
          return Container();
        },
      ),
    );
  }

  Widget _suggestionList(suggestions) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        String suggestion = suggestions[index].name;
        int indexOfQuery =
            suggestion.toLowerCase().indexOf(query.toLowerCase());
        return ListTile(
          onTap: () {
            Navigator.of(context).pop();
            _goToBook(context, suggestions[index]);
          },
          title: RichText(
            text: TextSpan(
              children: indexOfQuery > 0
                  ? <TextSpan>[
                      TextSpan(
                        text: suggestion.substring(0, indexOfQuery),
                        style: theme.textTheme.body1,
                      ),
                      TextSpan(
                        text: suggestion.substring(
                            indexOfQuery, indexOfQuery + query.length),
                        style: theme.textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: suggestion.substring(indexOfQuery + query.length),
                        style: theme.textTheme.body1,
                      ),
                    ]
                  : <TextSpan>[
                      TextSpan(
                        text: suggestion.substring(0, query.length),
                        style: theme.textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: suggestion.substring(query.length),
                        style: theme.textTheme.body1,
                      ),
                    ],
            ),
          ),
        );
      },
      itemCount: suggestions.length,
    );
  }

  void _goToBook(BuildContext context, Kitab book) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return ChapterListPage(book: book);
    }));
  }

  Widget _resultList(List<Ayat> results) {
    return GridView.builder(
      itemBuilder: (BuildContext context, int index) {
        Ayat verse = results[index];
        String verseText = verse.text;
        int indexOfQuery =
            verse.text.toLowerCase().indexOf(query.toLowerCase());
        return ListTile(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return BacaPage(
                kitabx: Kitab(id: verse.book, name: verse.bookName),
                pasalx: Pasal(
                  id: verse.chapter,
                  book: verse.book,
                  chapter: verse.chapter,
                ),
              );
            }));
          },
          title: Text(
            verse.bookName +
                ' ' +
                verse.chapter.toString() +
                ':' +
                verse.verse.toString(),
          ),
          subtitle: RichText(
            text: TextSpan(
              children: indexOfQuery > 0
                  ? <TextSpan>[
                      TextSpan(
                        text: verseText.substring(0, indexOfQuery),
                        style: theme.textTheme.body1,
                      ),
                      TextSpan(
                        text: verseText.substring(
                            indexOfQuery, indexOfQuery + query.length),
                        style: theme.textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: verseText.substring(indexOfQuery + query.length),
                        style: theme.textTheme.body1,
                      ),
                    ]
                  : <TextSpan>[
                      TextSpan(
                        text: verseText.substring(0, query.length),
                        style: theme.textTheme.body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: verseText.substring(query.length),
                        style: theme.textTheme.body1,
                      ),
                    ],
            ),
          ),
        );
      },
      itemCount: results.length,
    );
  }
}
