import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

List<String> asignaturas = [];
List<String> asignaturasDuplicadas = [];
List<String> codigos = [];
Map<String, List<String>> notas = {};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = "Cuaderno de notas";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white, brightness: Brightness.dark),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(
        title: appTitle,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  Future<void> loadMap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String? jsonString = prefs.getString('notas');

      if (jsonString != null) {
        Map<String, dynamic> jsonMap = json.decode(jsonString);

        jsonMap.forEach((key, value) {
          if (value is List) {
            notas[key] = List<String>.from(value);
          }
        });
      }
    });
  }

  Future<void> saveLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('asignaturasDuplicadas', asignaturasDuplicadas);
    prefs.setStringList('asignaturas', asignaturas);
    prefs.setStringList('codigos', codigos);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMap();
    });
  }

  @override
  void dispose() {
    super.dispose();
    saveLists();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    AddAsignatura(),
    ConsultarNotas(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Icon(Icons.code),
          )
        ],
      ),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Icon(
                  Icons.code,
                  size: 60,
                )),
            ListTile(
                title: const Text('Añadir Asignatura'),
                selected: _selectedIndex == 0,
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                }),
            ListTile(
              title: const Text("Consultar Notas"),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveLists() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('asignaturasDuplicadas', asignaturasDuplicadas);
  prefs.setStringList('codigos', codigos);
  prefs.setStringList('asignaturas', asignaturas);
}

Future<void> saveMap() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String jsonMap = json.encode(notas);
  prefs.setString('notas', jsonMap);
}

class AddAsignatura extends StatefulWidget {
  const AddAsignatura({super.key});

  @override
  State<AddAsignatura> createState() => _AddAsignaturaState();
}

class _AddAsignaturaState extends State<AddAsignatura> {
  Future<void> loadLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      asignaturasDuplicadas =
          prefs.getStringList('asignaturasDuplicadas') ?? [];
      asignaturas = prefs.getStringList('asignaturas') ?? [];
      codigos = prefs.getStringList('codigos') ?? [];
    });
  }

  final List<String> anyos = <String>["1 año", "2 año", "3 año", "4 año"];
  final List<String> semestres = <String>["1 semestre", "2 semestre"];

  String _anyoSeleccionado = "1 año";
  String _semestreSeleccionado = "1 semestre";

  final _controladorAsignatura = TextEditingController();
  final _controladorCodigo = TextEditingController();

  void mostrarInfo() {
    setState(() {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (!codigos.contains(_controladorCodigo.value.text)) {
        codigos.add(_controladorCodigo.text);
        String anyadir =
            "${_controladorAsignatura.text} $_anyoSeleccionado $_semestreSeleccionado ${_controladorCodigo.text}";
        asignaturas.add(anyadir);
        asignaturasDuplicadas.add(anyadir);
        notas[anyadir] = [];
        const snackBar = SnackBar(
          content: Text("Asignatura añadida"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        var snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(9),
            height: 35,
            decoration: const BoxDecoration(
                color: Color(0xFFC72C41),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: const Text("Error, la asignatura ya ha sido añadida"),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
    saveLists();
    saveMap();
  }

  double _valor = 0.0;

  void actualizar() {
    var res = 0.0;

    final controladores = [_controladorAsignatura, _controladorCodigo];

    for (final controlador in controladores) {
      if (controlador.value.text.isNotEmpty) {
        res += 1 / controladores.length;
      }
    }

    setState(() {
      _valor = res;
    });
  }

  void borrarAsignatura(int index, String texto) {
    setState(() {
      int i = asignaturasDuplicadas.indexOf(texto);
      asignaturasDuplicadas.removeAt(i);
      asignaturas.removeAt(index);
      codigos.removeAt(i);
      notas[texto] = [];
    });
    saveLists();
  }

  @override
  void initState() {
    super.initState();
    loadLists();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          onChanged: actualizar,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                controller: _controladorAsignatura,
                decoration:
                    const InputDecoration(hintText: "Nombre de la asignatura"),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButton(
                    items: anyos.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: SizedBox(
                          width: 60,
                          child: Text(
                            e,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: ((value) {
                      setState(() {
                        _anyoSeleccionado = value!;
                      });
                    }),
                    value: _anyoSeleccionado,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: DropdownButton(
                    items: semestres.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _semestreSeleccionado = value as String;
                      });
                    },
                    value: _semestreSeleccionado,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      controller: _controladorCodigo,
                      decoration:
                          const InputDecoration(hintText: "Código asignatura"),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: _valor == 1 ? mostrarInfo : null,
                  child: const Text("Añadir asignatura")),
            )
          ]),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: TextFormField(
                onChanged: (value) {
                  filterSearch(value);
                },
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(18)))),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: asignaturas.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: ListTile(
                    title: Text(asignaturas[index]),
                    trailing: IconButton(
                        onPressed: () {
                          borrarAsignatura(index, asignaturas[index]);
                        },
                        icon: const Icon(Icons.delete)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void filterSearch(String query) {
    setState(() {
      asignaturas = asignaturasDuplicadas
          .where(
              (element) => element.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _controladorAsignatura.dispose();
    _controladorCodigo.dispose();
    super.dispose();
  }
}

class ConsultarNotas extends StatefulWidget {
  const ConsultarNotas({super.key});

  @override
  State<ConsultarNotas> createState() => _ConsultarNotasState();
}

class _ConsultarNotasState extends State<ConsultarNotas> {
  String _valor = asignaturasDuplicadas.isEmpty ? "" : asignaturasDuplicadas[0];

  void cambiarPagina() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AnyadirNota(asignatura: _valor)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        asignaturas.isNotEmpty
            ? DropdownButton(
                itemHeight: 110,
                value: _valor,
                items: asignaturasDuplicadas.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Text(
                        e,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _valor = value as String;
                  });
                })
            : const Text("No hay asignaturas"),
        ElevatedButton(
            onPressed: _valor == "" ? null : cambiarPagina,
            child: const Text("Añadir/Consultar nota")),
      ],
    );
  }
}

class AnyadirNota extends StatefulWidget {
  final String asignatura;
  const AnyadirNota({super.key, required this.asignatura});

  @override
  State<AnyadirNota> createState() => _AnyadirNotaState();
}

class _AnyadirNotaState extends State<AnyadirNota> {
  double nota = 0.0;
  String examen = "";
  double ponderacion = 0.0;
  String notaFinal = "";

  final _controladorNota = TextEditingController();
  final _controladorExamen = TextEditingController();
  final _controladorPonderacion = TextEditingController();

  String calcularNota() {
    setState(() {
      double res = 0.0;
      for (String texto in notas[widget.asignatura]!) {
        List<String> textoSplit = texto.split(" ");
        res += double.parse(textoSplit[3 + textoSplit.length - 6]) *
            double.parse(textoSplit.last) /
            100;
      }
      notaFinal = res.toString();
    });
    return notaFinal;
  }

  void borrarNota(String nota) {
    setState(() {
      notas[widget.asignatura]!.remove(nota);
      saveMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Añadir Nota de ${widget.asignatura}"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Form(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _controladorNota,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              hintText: "Nota",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          controller: _controladorExamen,
                          decoration: const InputDecoration(
                              hintText: "Nombre del examen",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          controller: _controladorPonderacion,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              hintText: "Ponderación",
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)))),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  examen = _controladorExamen.text.trim();
                  nota = double.parse(_controladorNota.text);
                  ponderacion = double.parse(_controladorPonderacion.text);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Añadido examen: $examen con nota $nota")));
                  setState(() {
                    notas[widget.asignatura]?.add(
                        "Examen: $examen Nota: $nota Ponderacion: $ponderacion");
                    saveMap();
                  });
                });
              },
              child: const Text("Añadir Nota"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notas[widget.asignatura]?.length,
              itemBuilder: (context, index) {
                List<String>? textoSplit =
                    notas[widget.asignatura]?[index].split(" ");
                String? examenAdd = "";
                for (var i = 1; i <= 1 + textoSplit!.length - 6; i++) {
                  examenAdd = "${examenAdd!} ${textoSplit[i]}";
                  examenAdd = examenAdd.trim();
                }
                String? notaAdd = notas[widget.asignatura]?[index]
                    .split(" ")[3 + textoSplit.length - 6];
                String? ponderacionAdd =
                    notas[widget.asignatura]?[index].split(" ").last;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                          "Examen: $examenAdd Nota: $notaAdd Ponderacion: $ponderacionAdd"),
                      trailing: IconButton(
                          onPressed: () {
                            borrarNota(
                                "Examen: $examenAdd Nota: $notaAdd Ponderacion: $ponderacionAdd");
                          },
                          icon: const Icon(Icons.delete)),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: Text("Nota final: ${calcularNota()}"),
          )
        ],
      ),
    );
  }
}
