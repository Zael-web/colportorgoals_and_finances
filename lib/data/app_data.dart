import '../models/registro.dart';
import 'dart:convert';
import '../models/material_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

List<Registro> registrosGlobais = [];
List<MaterialModel> materiaisGlobais = [];

Future<void> salvarRegistrosGlobais() async {

  final prefs =
      await SharedPreferences.getInstance();

  List<String> lista = registrosGlobais.map((registro) {

    return jsonEncode(
      registro.toMap(),
    );

  }).toList();

  await prefs.setStringList(
    'registros',
    lista,
  );
}

Future<void> carregarRegistrosGlobais() async {

  final prefs =
      await SharedPreferences.getInstance();

  List<String>? lista =
      prefs.getStringList('registros');

  if (lista != null) {

    registrosGlobais = lista.map((item) {

      return Registro.fromMap(
        jsonDecode(item),
      );

    }).toList();
  }
}