import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro.dart';
import '../models/material_model.dart';

List<Registro> registrosGlobais = [];

List<MaterialModel> materiaisGlobais = [];

double metaBolsaGlobal = 18000;

DateTime dataInicioGlobal = DateTime.now();

DateTime dataFimGlobal =
    DateTime.now().add(
  const Duration(days: 30),
);

Future<void> salvarRegistrosGlobais() async {
  final prefs = await SharedPreferences.getInstance();

  List<String> lista = registrosGlobais.map((registro) {
    return jsonEncode(registro.toMap());
  }).toList();

  await prefs.setStringList(
    'registros',
    lista,
  );
}

Future<void> carregarRegistrosGlobais() async {
  final prefs = await SharedPreferences.getInstance();

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

double totalCompradoGlobal() {
  double total = 0;

  for (var registro in registrosGlobais) {
    total += registro.comprado;
  }

  return total;
}

double totalVendidoGlobal() {
  double total = 0;

  for (var registro in registrosGlobais) {
    total += registro.vendido;
  }

  return total;
}

int totalLivrosGlobal() {
  int total = 0;

  for (var registro in registrosGlobais) {
    total += registro.quantidade;
  }

  return total;
}

double faltaParaBolsa() {
  double falta =
      metaBolsaGlobal - totalCompradoGlobal();

  if (falta < 0) {
    return 0;
  }

  return falta;
}


int diasRestantes() {
  final hoje = DateTime.now();

  int dias =
      dataFimGlobal.difference(hoje).inDays;

  if (dias <= 0) {
    return 1;
  }

  return dias;
}

double metaDiariaNecessaria() {

  if (metaBolsaGlobal == 0) {
    return 0;
  }
  return faltaParaBolsa() /
      diasRestantes();
}

Future<void> salvarMateriaisGlobais() async {

  final prefs =
      await SharedPreferences.getInstance();

  List<String> lista =
      materiaisGlobais.map((material) {

    return jsonEncode(
      material.toMap(),
    );

  }).toList();

  await prefs.setStringList(
    'materiais',
    lista,
  );
}

Future<void> carregarMateriaisGlobais() async {

  final prefs =
      await SharedPreferences.getInstance();

  List<String>? lista =
      prefs.getStringList('materiais');

  if (lista != null) {

    materiaisGlobais =
        lista.map((item) {

      return MaterialModel.fromMap(
        jsonDecode(item),
      );

    }).toList();
  }
}
Future<void> salvarPlanejamento() async {
  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setDouble(
    'metaBolsaGlobal',
    metaBolsaGlobal,
  );

  await prefs.setString(
    'dataInicioGlobal',
    dataInicioGlobal.toIso8601String(),
  );

  await prefs.setString(
    'dataFimGlobal',
    dataFimGlobal.toIso8601String(),
  );
}

Future<void> carregarPlanejamento() async {
  final prefs =
      await SharedPreferences.getInstance();

  metaBolsaGlobal =
      prefs.getDouble(
        'metaBolsaGlobal',
      ) ??
      18000;

  String? inicio =
      prefs.getString(
        'dataInicioGlobal',
      );

  String? fim =
      prefs.getString(
        'dataFimGlobal',
      );

  if (inicio != null) {
    dataInicioGlobal =
        DateTime.parse(inicio);
  }

  if (fim != null) {
    dataFimGlobal =
        DateTime.parse(fim);
  }
}

Future<void> excluirPlanejamento() async {
  final prefs =
      await SharedPreferences.getInstance();

  await prefs.remove(
    'metaBolsaGlobal',
  );

  await prefs.remove(
    'dataInicioGlobal',
  );

  await prefs.remove(
    'dataFimGlobal',
  );

  metaBolsaGlobal = 18000;

  dataInicioGlobal = DateTime.now();

  dataFimGlobal =
      DateTime.now().add(
    const Duration(days: 30),
  );
}