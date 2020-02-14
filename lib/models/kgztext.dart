import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Kgztext {
  int id;
  String title;

  Kgztext({this.id, this.title});

  factory Kgztext.fromJson(Map<String, dynamic> json) {
    return Kgztext(
        id: json['id'] as int,
        title: json['title'] as String,

        
        );
  }
}

Future<List<Kgztext>> fetchData(http.Client client) async{
  final response = await client.get('http://mineconom.gov.kg/ru/api/post/main');
  return compute(parseData, response.body);
}

List<Kgztext> parseData(String responseBody){
  final parsed = json.decode(responseBody);
  return parsed['data'].map<Kgztext>((json) => Kgztext.fromJson(json)).toList();
}