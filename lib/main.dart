import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'config.dart';

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
  bool isLoaded = false;
  Uri apiRoute = Uri.https("restcountries.com", "/v3.1/all", {
    'fields': 'translations,latlng,area,flags,capital,continents,population',
  });
  List<Pais> paises = [];
  Pais? paisSelecionado;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    var response = await http.get(apiRoute);
    paises = jsonDecode(response.body).map<Pais>((country) {
      return Pais(
        nome: country['translations']['por']['common'].toString(),
        latlng: (country['latlng'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
        area: country['area'],
        flag: country['flags']['png'],
        capital: (country['capital'].isNotEmpty) ? country['capital'][0] : 'N/I',
        region: country['continents'][0],
        population: country['population'].toString(),
      );
    }).toList();

    setState(() {
      isLoaded = true;
    });
  }

  void goToCountry(Pais pais) {
    final loc = LatLng(pais.latlng![0], pais.latlng![1]);
    final double zoom = estimateZoom(pais.area ?? 500);

    _mapController.move(loc, zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('CountryFindr', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SearchBar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchAnchor(
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
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  final query = controller.text.toLowerCase();

                  final filteredPaises = paises
                      .where(
                        (pais) => pais.nome.toLowerCase().contains(query),
                  )
                      .toList();

                  return List<ListTile>.generate(filteredPaises.length, (
                      int index,
                      ) {
                    final Pais item = filteredPaises[index];
                    return ListTile(
                      title: Text(item.nome),
                      onTap: () {
                        setState(() {
                          paisSelecionado = Pais(
                              nome: item.nome,
                              latlng: item.latlng,
                              area: item.area,
                              flag: item.flag,
                              capital: item.capital,
                              region: item.region,
                              population: item.population
                          );
                          goToCountry(item);

                          controller.closeView(item.nome);
                          FocusScope.of(context).unfocus();
                        });
                      },
                    );
                  });
                },
              ),
            ),

            // Mapa
            Visibility(
              visible: paisSelecionado != null,
              maintainState: true,
              maintainAnimation: true,
              maintainSize: false,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 400,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(-14.2350, -51.9253),
                      initialZoom: 3.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=$MAPTILER_API_KEY&language=pt',
                        userAgentPackageName: 'com.example.ap2_sexta',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Infos dos países
            Visibility(
              visible: paisSelecionado != null,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Card(
                  color: Colors.blue[50],
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(paisSelecionado != null ? paisSelecionado!.nome : '', style: TextStyle(fontSize: 42.0, fontWeight: FontWeight.bold),),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.network(paisSelecionado != null ? paisSelecionado!.flag : ''),
                        ),
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Capital', style: TextStyle(fontWeight: FontWeight.bold),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(paisSelecionado != null ? paisSelecionado!.capital : ''),
                                )
                              ]
                            ),
                            TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Continente', style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(paisSelecionado != null ? paisSelecionado!.region : ''),
                                  )
                                ]
                            ),
                            TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('População', style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(paisSelecionado != null ? paisSelecionado!.population : ''),
                                  )
                                ]
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ),
          ],
        ),
      )
    );
  }
}

class Pais {
  final String nome;
  final List<double>? latlng;
  final double area;
  final String flag;
  final String capital;
  final String region;
  final String population;

  Pais({required this.nome, required this.latlng, required this.area, required this.flag, required this.capital, required this.region, required this.population});
}

double estimateZoom(double area) {
  double radiusKm = sqrt(area / pi);

  if (radiusKm > 2000) return 3;
  if (radiusKm > 1000) return 4;
  if (radiusKm > 500) return 5;
  if (radiusKm > 100) return 6;
  return 7;
}