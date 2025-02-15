import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const NotasApp());
}

class NotasApp extends StatelessWidget {
  const NotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Notas',
      theme: ThemeData.dark(),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceSeleccionado = 0;
  List<Nota> _notas = [];
  final File _archivoNotas = File('notas.json');

  @override
  void initState() {
    super.initState();
    _cargarNotas();
  }

  Future<void> _cargarNotas() async {
    try {
      if (await _archivoNotas.exists()) {
        final contenido = await _archivoNotas.readAsString();
        setState(() {
          _notas = (jsonDecode(contenido) as List)
              .map((json) => Nota.fromMap(json))
              .toList();
        });
      }
    } catch (e) {
      print('Error cargando notas: $e');
    }
  }

  Future<void> _guardarNotas() async {
    try {
      final jsonNotas = jsonEncode(_notas.map((n) => n.toMap()).toList());
      await _archivoNotas.writeAsString(jsonNotas);
    } catch (e) {
      print('Error guardando notas: $e');
    }
  }

  void _agregarNota(String titulo, String contenido) {
    setState(() {
      _notas.add(Nota(titulo: titulo, contenido: contenido));
    });
    _guardarNotas();
  }

  void _eliminarNota(int indice) {
    setState(() {
      _notas.removeAt(indice);
    });
    _guardarNotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _indiceSeleccionado,
            onDestinationSelected: (indice) => 
                setState(() => _indiceSeleccionado = indice),
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.notes), label: Text('Notas')),
              NavigationRailDestination(
                  icon: Icon(Icons.add), label: Text('Crear Nota')),
              NavigationRailDestination(
                  icon: Icon(Icons.person), label: Text('Usuario')),
            ],
          ),
          Expanded(child: _obtenerPantalla(_indiceSeleccionado)),
        ],
      ),
    );
  }

  Widget _obtenerPantalla(int indice) {
    switch (indice) {
      case 0:
        return PantallaListaNotas(notas: _notas, onEliminarNota: _eliminarNota);
      case 1:
        return PantallaCrearNota(onAgregarNota: _agregarNota);
      case 2:
        return const PantallaInformacionUsuario();
      default:
        return const Center(child: Text('Pantalla no encontrada'));
    }
  }
}

class Nota {
  String titulo;
  String contenido;

  Nota({required this.titulo, required this.contenido});

  Map<String, dynamic> toMap() => {'titulo': titulo, 'contenido': contenido};

  factory Nota.fromMap(Map<String, dynamic> map) =>
      Nota(titulo: map['titulo'], contenido: map['contenido']);
}

class PantallaListaNotas extends StatelessWidget {
  final List<Nota> notas;
  final Function(int) onEliminarNota;

  const PantallaListaNotas({super.key, required this.notas, required this.onEliminarNota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Notas')),
      body: ListView.builder(
        itemCount: notas.length,
        itemBuilder: (context, indice) => ListTile(
          title: Text(notas[indice].titulo),
          subtitle: Text(notas[indice].contenido),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onEliminarNota(indice),
          ),
        ),
      ),
    );
  }
}

class PantallaCrearNota extends StatefulWidget {
  final Function(String, String) onAgregarNota;

  const PantallaCrearNota({super.key, required this.onAgregarNota});

  @override
  _PantallaCrearNotaState createState() => _PantallaCrearNotaState();
}

class _PantallaCrearNotaState extends State<PantallaCrearNota> {
  final TextEditingController _controladorTitulo = TextEditingController();
  final TextEditingController _controladorContenido = TextEditingController();

  void _guardarNota() {
    final String titulo = _controladorTitulo.text.trim();
    final String contenido = _controladorContenido.text.trim();
    if (titulo.isNotEmpty && contenido.isNotEmpty) {
      widget.onAgregarNota(titulo, contenido);
      _controladorTitulo.clear();
      _controladorContenido.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nueva Nota')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controladorTitulo,
              decoration: const InputDecoration(
                  labelText: 'Título', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controladorContenido,
              decoration: const InputDecoration(
                  labelText: 'Contenido', border: OutlineInputBorder()),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _guardarNota,
                child: const Text('Guardar Nota')),
          ],
        ),
      ),
    );
  }
}

class PantallaInformacionUsuario extends StatelessWidget {
  const PantallaInformacionUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información del Usuario')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
                backgroundImage: AssetImage('assets/perfil.jpg'), radius: 50),
            SizedBox(height: 16),
            Text('Nombre: Juan Pérez', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Email: juan.perez@example.com',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}