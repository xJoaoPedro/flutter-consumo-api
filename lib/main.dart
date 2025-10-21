import 'dart:convert';

import 'package:ap2_sexta/assets/mapa_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<Country>? countries;
  bool isLoaded = false;
  Uri apiRoute = Uri.https("restcountries.com", "/v3.1/all", {'fields': 'translations',});
  List<String> paises = [];
  String? linkPais;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    var response = await http.get(apiRoute);
    paises = jsonDecode(response.body).map<String>((country) {
      return country['translations']['por']['common'].toString();
    }).toList();

    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Encontre o país'),
      ),
      body: Column(
        children: !isLoaded
            ? [ Center(child: CircularProgressIndicator(),) ]
            : [Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (query) {
                    controller.openView();
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder: (BuildContext context, SearchController controller) {
                final query = controller.text.toLowerCase();

                final filteredPaises = paises.where(
                      (pais) => pais.toLowerCase().contains(query),
                ).toList();

                return List<ListTile>.generate(filteredPaises.length, (int index) {
                  final String item = filteredPaises[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        linkPais = item;
                        controller.closeView(item);
                      });
                    },
                  );
                });
              },
            ),

            if (linkPais != null)
              SizedBox(
                height: 400, // altura fixa
                child: MapaWebView(pais: linkPais!),
              ),

          ],
        ),]
      ),
    );
  }
}
