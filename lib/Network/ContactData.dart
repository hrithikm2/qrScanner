import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Contacts> fetchImageData() async{
  final response  = await http.get(Uri.parse("https://fakeface.rest/face/json"));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Contacts.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Contacts {

  String? imageUrl;


  Contacts(
      {
        required this.imageUrl,
        });

  Contacts.fromJson(Map<String, dynamic> json) {

    imageUrl = json['image_url'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['image_url'] = this.imageUrl;

    return data;
  }
}