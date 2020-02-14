import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../models/kgztext.dart';

class TextsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Kgztext>>(
        future: fetchData(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.error) print(snapshot.error);
          return snapshot.hasData
              ? TextsList(texts: snapshot.data)
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                );
        },
      ),
    );
  }
}

class TextsList extends StatefulWidget {
  final List<Kgztext> texts;
  const TextsList({Key key, this.texts}) : super(key: key);
  @override
  _TextsListState createState() => _TextsListState();
}

class _TextsListState extends State<TextsList> {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListView.builder(itemCount: widget.texts.length,
      itemBuilder: (context, index){
        return Container(height: 30,child: Text('${widget.texts[index].id}'+'${widget.texts[index].title}'),);
      },)
    ],);
  }
}
