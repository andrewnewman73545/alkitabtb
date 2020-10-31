import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  'TB Text\ndiambil dari : \n\nhttps://gobible.wordpress.com/2012/10/31/pdb-files-for-bible/\n\nTerjemahan Baru (TB) Copyright Lembaga Alkitab Indonesia (Indonesian Bible Society), 1974. \n\nReleased for non-profit scholarly and personal use. Not to be sold for profit. When making formal public reference to the materials, please acknowlege The Indonesian Bible Society (Lembaga Alkitab Indonesia) as the copyright holder.\n\nProgram ini Free untuk pembelajaran',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
