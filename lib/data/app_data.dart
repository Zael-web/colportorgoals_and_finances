import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/registro.dart';
import '../models/material_model.dart';
import '../models/campanha.dart';
import '../services/firestore_service.dart';

List<Registro> registrosGlobais = [];

final ValueNotifier<int> dadosGlobaisVersion = ValueNotifier<int>(0);

final FirestoreService _firestoreService = FirestoreService();

List<MaterialModel> _materiaisPadrao() {
  return [
    MaterialModel(
      nome: 'A Última Chamada',
      valorCompra: 105.93,
      valorVenda: 211.86,
    ),
    MaterialModel(
      nome: 'Como Formar Filhos Vencedores',
      valorCompra: 126.24,
      valorVenda: 252.48,
    ),
    MaterialModel(
      nome: '21 Dias para Mudar',
      valorCompra: 106.32,
      valorVenda: 212.64,
    ),
    MaterialModel(
      nome: 'Revolucione seu Futuro',
      valorCompra: 93.99,
      valorVenda: 187.98,
    ),
  ];
}

List<MaterialModel> materiaisGlobais = _materiaisPadrao();

double metaBolsaGlobal = 18000;

DateTime dataInicioGlobal = DateTime.now();

DateTime dataFimGlobal = DateTime.now().add(const Duration(days: 30));

List<Planejamento> planejamentosGlobais = [];
String? planejamentoSelecionadoId;

String _keyDoUsuario(String chave) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
  return '${uid}_$chave';
}

void resetarDadosUsuarioAtual() {
  registrosGlobais = [];
  materiaisGlobais = _materiaisPadrao();
  planejamentosGlobais = [];
  planejamentoSelecionadoId = null;
  metaBolsaGlobal = 18000;
  dataInicioGlobal = DateTime.now();
  dataFimGlobal = DateTime.now().add(const Duration(days: 30));
}

Future<void> carregarDadosUsuarioAtual() async {
  resetarDadosUsuarioAtual();

  await carregarRegistrosGlobais();
  await carregarMateriaisGlobais();
  await carregarPlanejamento();
  await carregarPlanejamentos();
}

String formatarMoedaGlobal(double valor) {
  return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ').format(valor);
}

String formatarNumeroGlobal(double valor, {int casas = 2}) {
  return NumberFormat.decimalPatternDigits(
    locale: 'pt_BR',
    decimalDigits: casas,
  ).format(valor);
}

const double percentualDizimo = 0.10;

double calcularDizimoMaterial(double valorMaterial) {
  return valorMaterial * percentualDizimo;
}

double calcularValorPagoMaterial(double valorMaterial) {
  return valorMaterial + calcularDizimoMaterial(valorMaterial);
}

double calcularLucroRegistro(Registro registro) {
  return registro.vendido - registro.comprado - registro.taxaCartao;
}

Future<void> salvarRegistrosGlobais() async {
  final prefs = await SharedPreferences.getInstance();

  List<String> lista = registrosGlobais.map((registro) {
    return jsonEncode(registro.toMap());
  }).toList();

  await prefs.setStringList(_keyDoUsuario('registros'), lista);
}

Future<void> carregarRegistrosGlobais() async {
  final prefs = await SharedPreferences.getInstance();

  final key = _keyDoUsuario('registros');
  List<String>? lista = prefs.getStringList(key);

  if (lista != null) {
    registrosGlobais = lista.map((item) {
      return Registro.fromMap(jsonDecode(item));
    }).toList();

    var houveMigracao = false;
    registrosGlobais = registrosGlobais.map((registro) {
      if (registro.versaoCalculo >= 2) {
        return registro;
      }

      houveMigracao = true;
      final valorMaterial = registro.comprado;
      final dizimo = calcularDizimoMaterial(valorMaterial);
      return Registro(
        material: registro.material,
        vendido: registro.vendido,
        comprado: calcularValorPagoMaterial(valorMaterial),
        quantidade: registro.quantidade,
        observacao: registro.observacao,
        data: registro.data,
        formaPagamento: registro.formaPagamento,
        dizimo: dizimo,
        taxaCartao: registro.taxaCartao,
        valorLiquido: registro.vendido - dizimo - registro.taxaCartao,
      );
    }).toList();

    if (houveMigracao) {
      await salvarRegistrosGlobais();
    }
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

double totalLucroGlobal() {
  double total = 0;

  for (final registro in registrosGlobais) {
    total += calcularLucroRegistro(registro);
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
  double falta = metaBolsaGlobal - totalCompradoGlobal();

  if (falta < 0) {
    return 0;
  }

  return falta;
}

int diasRestantes() {
  final hoje = DateTime.now();

  int dias = dataFimGlobal.difference(hoje).inDays;

  if (dias <= 0) {
    return 1;
  }

  return dias;
}

double metaDiariaNecessaria() {
  if (metaBolsaGlobal == 0) {
    return 0;
  }
  return faltaParaBolsa() / diasRestantes();
}

Future<void> salvarMateriaisGlobais() async {
  final prefs = await SharedPreferences.getInstance();

  List<String> lista = materiaisGlobais.map((material) {
    return jsonEncode(material.toMap());
  }).toList();

  await prefs.setStringList(_keyDoUsuario('materiais'), lista);
}

Future<void> carregarMateriaisGlobais() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final materiaisFirestore = await _firestoreService
        .listarMateriais(userId: uid)
        .first;

    if (materiaisFirestore.isNotEmpty) {
      materiaisGlobais = materiaisFirestore;
      return;
    }
  } catch (_) {
    // Se o Firestore ainda não responder, usamos os dados locais como fallback.
  }

  final prefs = await SharedPreferences.getInstance();
  final key = _keyDoUsuario('materiais');

  List<String>? lista = prefs.getStringList(key);

  if (lista != null && lista.isNotEmpty) {
    materiaisGlobais = lista.map((item) {
      return MaterialModel.fromMap(jsonDecode(item));
    }).toList();
  }

  if (materiaisGlobais.isNotEmpty) {
    for (final material in materiaisGlobais) {
      try {
        await _firestoreService.adicionarMaterial(material);
      } catch (_) {
        // Ignora duplicidades ou falhas momentâneas durante a migração.
      }
    }
  }
}

Future<void> salvarPlanejamento() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setDouble(_keyDoUsuario('metaBolsaGlobal'), metaBolsaGlobal);
  await prefs.setString(
    _keyDoUsuario('dataInicioGlobal'),
    dataInicioGlobal.toIso8601String(),
  );
  await prefs.setString(
    _keyDoUsuario('dataFimGlobal'),
    dataFimGlobal.toIso8601String(),
  );

  if (planejamentoSelecionadoId != null) {
    final index = planejamentosGlobais.indexWhere(
      (item) => item.id == planejamentoSelecionadoId,
    );
    if (index != -1) {
      planejamentosGlobais[index] = Planejamento(
        id: planejamentosGlobais[index].id,
        nome: planejamentosGlobais[index].nome,
        meta: metaBolsaGlobal,
        dataInicio: dataInicioGlobal,
        dataFim: dataFimGlobal,
      );
      await salvarListaPlanejamentos();
    }
  }
}

Future<void> carregarPlanejamento() async {
  final prefs = await SharedPreferences.getInstance();

  metaBolsaGlobal = prefs.getDouble(_keyDoUsuario('metaBolsaGlobal')) ?? 18000;

  String? inicio = prefs.getString(_keyDoUsuario('dataInicioGlobal'));
  String? fim = prefs.getString(_keyDoUsuario('dataFimGlobal'));

  if (inicio != null) {
    dataInicioGlobal = DateTime.parse(inicio);
  }

  if (fim != null) {
    dataFimGlobal = DateTime.parse(fim);
  }
}

Future<void> excluirPlanejamento() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove(_keyDoUsuario('metaBolsaGlobal'));
  await prefs.remove(_keyDoUsuario('dataInicioGlobal'));
  await prefs.remove(_keyDoUsuario('dataFimGlobal'));

  metaBolsaGlobal = 0;

  dataInicioGlobal = DateTime.now();

  dataFimGlobal = DateTime.now().add(const Duration(days: 30));

  if (planejamentoSelecionadoId != null) {
    planejamentosGlobais.removeWhere(
      (item) => item.id == planejamentoSelecionadoId,
    );
    planejamentoSelecionadoId = null;
    await prefs.remove(_keyDoUsuario('planejamentoSelecionadoId'));
    await salvarListaPlanejamentos();
  }

  dadosGlobaisVersion.value++;
}

Future<void> salvarListaPlanejamentos() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _keyDoUsuario('planejamentos'),
    planejamentosGlobais
        .map((planejamento) => jsonEncode(planejamento.toMap()))
        .toList(),
  );
}

Future<void> carregarPlanejamentos() async {
  final prefs = await SharedPreferences.getInstance();
  final lista = prefs.getStringList(_keyDoUsuario('planejamentos'));

  if (lista != null) {
    planejamentosGlobais = lista
        .map(
          (item) =>
              Planejamento.fromMap(jsonDecode(item) as Map<String, dynamic>),
        )
        .toList();
  }

  if (lista == null && planejamentosGlobais.isEmpty) {
    planejamentosGlobais = [
      Planejamento(
        id: 'principal',
        nome: 'Meu planejamento',
        meta: metaBolsaGlobal,
        dataInicio: dataInicioGlobal,
        dataFim: dataFimGlobal,
      ),
    ];
    await salvarListaPlanejamentos();
    await selecionarPlanejamento('principal');
    return;
  }

  if (planejamentosGlobais.isEmpty) {
    planejamentoSelecionadoId = null;
    return;
  }

  planejamentoSelecionadoId = prefs.getString(_keyDoUsuario('planejamentoSelecionadoId'));
  if (planejamentosGlobais.isEmpty) {
    planejamentoSelecionadoId = null;
    return;
  }
  if (!planejamentosGlobais.any(
    (item) => item.id == planejamentoSelecionadoId,
  )) {
    planejamentoSelecionadoId = planejamentosGlobais.first.id;
  }
  await selecionarPlanejamento(planejamentoSelecionadoId!);
}

Future<void> selecionarPlanejamento(String id) async {
  final planejamento = planejamentosGlobais.firstWhere((item) => item.id == id);
  planejamentoSelecionadoId = id;
  metaBolsaGlobal = planejamento.meta;
  dataInicioGlobal = planejamento.dataInicio;
  dataFimGlobal = planejamento.dataFim;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyDoUsuario('planejamentoSelecionadoId'), id);
  await salvarPlanejamento();
  dadosGlobaisVersion.value++;
}

Future<void> salvarOuAtualizarPlanejamento(Planejamento planejamento) async {
  final index = planejamentosGlobais.indexWhere(
    (item) => item.id == planejamento.id,
  );
  if (index == -1) {
    planejamentosGlobais.add(planejamento);
  } else {
    planejamentosGlobais[index] = planejamento;
  }
  await salvarListaPlanejamentos();
  await selecionarPlanejamento(planejamento.id);
}

Future<void> excluirPlanejamentoPorId(String id) async {
  planejamentosGlobais.removeWhere((item) => item.id == id);

  if (planejamentoSelecionadoId == id) {
    planejamentoSelecionadoId = null;
    metaBolsaGlobal = 0;
    dataInicioGlobal = DateTime.now();
    dataFimGlobal = DateTime.now().add(const Duration(days: 30));
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDoUsuario('planejamentoSelecionadoId'));
    await prefs.remove(_keyDoUsuario('metaBolsaGlobal'));
    await prefs.remove(_keyDoUsuario('dataInicioGlobal'));
    await prefs.remove(_keyDoUsuario('dataFimGlobal'));
  }

  await salvarListaPlanejamentos();
  dadosGlobaisVersion.value++;
}
