import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/material_model.dart';
import '../models/registro.dart';

class RegistroScreen extends StatefulWidget {
  final VoidCallback atualizarHome;

  const RegistroScreen({super.key, required this.atualizarHome});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  DateTime dataSelecionada = DateTime.now();
  DateTime? dataFiltro;
  int? indiceEditando;
  String formaPagamentoSelecionada = 'Dinheiro';
  String? materialSelecionadoNome;

  @override
  void initState() {
    super.initState();
    _definirMaterialPadrao();
  }

  @override
  void dispose() {
    quantidadeController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  void _definirMaterialPadrao() {
    if (materiaisGlobais.isNotEmpty) {
      materialSelecionadoNome = materiaisGlobais.first.nome;
    }
  }

  MaterialModel? get materialSelecionado {
    if (materialSelecionadoNome == null) return null;

    for (final material in materiaisGlobais) {
      if (material.nome == materialSelecionadoNome) {
        return material;
      }
    }

    return null;
  }

  String formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2)}';
  }

  String formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  bool mesmaData(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int get quantidadeDigitada => int.tryParse(quantidadeController.text) ?? 0;

  double get valorCompraUnitario => materialSelecionado?.valorCompra ?? 0;

  double get valorVendaUnitario => materialSelecionado?.valorVenda ?? 0;

  double get valorCompradoCalculado => valorCompraUnitario * quantidadeDigitada;

  double get valorVendidoCalculado => valorVendaUnitario * quantidadeDigitada;

  double get dizimoCalculado => valorVendidoCalculado * 0.10;

  double get taxaCartaoCalculada =>
      formaPagamentoSelecionada == 'Cartão' ? valorVendidoCalculado * 0.03 : 0;

  double get valorLiquidoCalculado =>
      valorVendidoCalculado - dizimoCalculado - taxaCartaoCalculada;

  List<int> get _indicesVisiveis {
    final indices = <int>[];

    for (var i = 0; i < registrosGlobais.length; i++) {
      final registro = registrosGlobais[i];
      if (dataFiltro == null || mesmaData(registro.data, dataFiltro!)) {
        indices.add(i);
      }
    }

    return indices.reversed.toList();
  }

  double get totalVendido => totalVendidoGlobal();

  double get totalComprado => totalCompradoGlobal();

  int get totalLivros => totalLivrosGlobal();

  double get totalAcumuladoCampanha => totalVendido + totalComprado;

  double get melhorDiaVendas {
    if (registrosGlobais.isEmpty) return 0;

    double maior = 0;
    for (final registro in registrosGlobais) {
      if (registro.vendido > maior) {
        maior = registro.vendido;
      }
    }
    return maior;
  }

  int get diasComRegistro {
    final dias = <String>{};
    for (final registro in registrosGlobais) {
      dias.add(
        '${registro.data.year}-${registro.data.month}-${registro.data.day}',
      );
    }
    return dias.isEmpty ? 1 : dias.length;
  }

  double get mediaDiariaVendas {
    if (registrosGlobais.isEmpty) return 0;
    return totalVendido / diasComRegistro;
  }

  void limparFormulario() {
    indiceEditando = null;
    quantidadeController.clear();
    observacaoController.clear();
    formaPagamentoSelecionada = 'Dinheiro';
    dataSelecionada = DateTime.now();
    _definirMaterialPadrao();
  }

  Future<void> escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataSelecionada = data;
      });
    }
  }

  Future<void> escolherFiltro() async {
    final dataInicial = dataFiltro ?? DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (data != null) {
      setState(() {
        dataFiltro = data;
      });
    }
  }

  void limparFiltro() {
    setState(() {
      dataFiltro = null;
    });
  }

  void preencherParaEdicao(int indice) {
    final registro = registrosGlobais[indice];

    setState(() {
      indiceEditando = indice;
      materialSelecionadoNome = registro.material;
      quantidadeController.text = registro.quantidade.toString();
      observacaoController.text = registro.observacao;
      formaPagamentoSelecionada = registro.formaPagamento;
      dataSelecionada = registro.data;
    });
  }

  Future<void> confirmarExclusao(int indice) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir registro'),
          content: const Text('Deseja excluir este registro?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmado != true) return;

    setState(() {
      registrosGlobais.removeAt(indice);
      if (indiceEditando == indice) {
        limparFormulario();
      }
    });

    await salvarRegistrosGlobais();
    widget.atualizarHome();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro excluído com sucesso!')),
    );
  }

  Future<void> salvarRegistro() async {
    final estavaEditando = indiceEditando != null;

    final material = materialSelecionado;
    final quantidade = quantidadeDigitada;
    final observacao = observacaoController.text.trim();

    if (materialSelecionadoNome == null || material == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um material!')));
      return;
    }

    if (quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida!')),
      );
      return;
    }

    final valorComprado = valorCompraUnitario * quantidade;
    final valorVendido = valorVendaUnitario * quantidade;
    final dizimo = valorVendido * 0.10;
    final taxaCartao = formaPagamentoSelecionada == 'Cartão'
        ? valorVendido * 0.03
        : 0.0;
    final valorLiquido = valorVendido - dizimo - taxaCartao;

    final novoRegistro = Registro(
      material: materialSelecionadoNome!,
      vendido: valorVendido,
      comprado: valorComprado,
      quantidade: quantidade,
      observacao: observacao,
      data: dataSelecionada,
      formaPagamento: formaPagamentoSelecionada,
      dizimo: dizimo,
      taxaCartao: taxaCartao,
      valorLiquido: valorLiquido,
    );

    setState(() {
      if (indiceEditando != null) {
        registrosGlobais[indiceEditando!] = novoRegistro;
      } else {
        registrosGlobais.add(novoRegistro);
      }
      limparFormulario();
    });

    await salvarRegistrosGlobais();
    widget.atualizarHome();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          estavaEditando
              ? 'Registro atualizado com sucesso!'
              : 'Registro salvo com sucesso!',
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _materialItems() {
    final itens = <DropdownMenuItem<String>>[];

    for (final material in materiaisGlobais) {
      itens.add(
        DropdownMenuItem<String>(
          value: material.nome,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              '${material.nome}  •  C:${formatarMoeda(material.valorCompra)}  V:${formatarMoeda(material.valorVenda)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      );
    }

    if (materialSelecionadoNome != null &&
        materiaisGlobais
            .where((m) => m.nome == materialSelecionadoNome)
            .isEmpty) {
      itens.insert(
        0,
        DropdownMenuItem<String>(
          value: materialSelecionadoNome,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              materialSelecionadoNome!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      );
    }

    return itens;
  }

  String _labelFormaPagamento(String valor) {
    switch (valor) {
      case 'PIX':
        return 'PIX';
      case 'Cartão':
        return 'Cartão';
      default:
        return 'Dinheiro';
    }
  }

  Widget _summaryCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 11, 41, 77),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icone, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(137, 255, 255, 255),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String titulo, String valor, IconData icone, Color cor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 11, 41, 77),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cor.withValues(alpha: 0.12),
            child: Icon(icone, color: cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipInfo(IconData icone, String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 18, color: cor),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(color: cor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _registroCard(int indice) {
    final registro = registrosGlobais[indice];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Color.fromARGB(255, 11, 41, 77),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registro.material.isEmpty
                            ? 'Registro diário'
                            : registro.material,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatarData(registro.data),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      preencherParaEdicao(indice);
                    } else if (value == 'excluir') {
                      confirmarExclusao(indice);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chipInfo(
                  Icons.menu_book,
                  registro.material,
                  const Color.fromARGB(255, 11, 41, 77),
                ),
                _chipInfo(
                  Icons.shopping_basket,
                  'Qtd ${registro.quantidade}',
                  Colors.orange,
                ),
                _chipInfo(
                  Icons.trending_up,
                  'Vendido ${formatarMoeda(registro.vendido)}',
                  Colors.green,
                ),
                _chipInfo(
                  Icons.inventory_2,
                  'Comprado ${formatarMoeda(registro.comprado)}',
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chipInfo(
                  registro.formaPagamento == 'Cartão'
                      ? Icons.credit_card
                      : registro.formaPagamento == 'PIX'
                      ? Icons.qr_code
                      : Icons.payments,
                  _labelFormaPagamento(registro.formaPagamento),
                  Colors.deepPurple,
                ),
                _chipInfo(
                  Icons.percent,
                  'Dízimo ${formatarMoeda(registro.dizimo)}',
                  Colors.indigo,
                ),
                _chipInfo(
                  Icons.credit_card,
                  'Taxa cartão ${formatarMoeda(registro.taxaCartao)}',
                  Colors.red,
                ),
                _chipInfo(
                  Icons.account_balance_wallet,
                  'Líquido ${formatarMoeda(registro.valorLiquido)}',
                  Colors.teal,
                ),
              ],
            ),
            if (registro.observacao.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  registro.observacao,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => preencherParaEdicao(indice),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 11, 41, 77),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => confirmarExclusao(indice),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Excluir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 11, 41, 77),
            Color.fromARGB(255, 18, 64, 119),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              255,
              11,
              41,
              77,
            ).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo automático',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _summaryCard(
            titulo: 'Livro selecionado',
            valor: materialSelecionadoNome ?? 'Selecione um material',
            icone: Icons.menu_book,
            cor: Colors.white,
          ),
          const SizedBox(height: 10),
          _summaryCard(
            titulo: 'Quantidade',
            valor: quantidadeDigitada.toString(),
            icone: Icons.shopping_basket,
            cor: Colors.white,
          ),
          const SizedBox(height: 10),
          _summaryCard(
            titulo: 'Valor comprado',
            valor: formatarMoeda(valorCompradoCalculado),
            icone: Icons.inventory_2,
            cor: Colors.white,
          ),
          const SizedBox(height: 10),
          _summaryCard(
            titulo: 'Valor vendido',
            valor: formatarMoeda(valorVendidoCalculado),
            icone: Icons.trending_up,
            cor: Colors.white,
          ),
          const SizedBox(height: 10),
          _summaryCard(
            titulo: 'Dízimo',
            valor: formatarMoeda(dizimoCalculado),
            icone: Icons.percent,
            cor: Colors.white,
          ),
          const SizedBox(height: 10),
          _summaryCard(
            titulo: 'Taxa do cartão',
            valor: formatarMoeda(taxaCartaoCalculada),
            icone: Icons.credit_card,
            cor: Colors.white,
          ),
          const SizedBox(height: 10),
          _summaryCard(
            titulo: 'Valor líquido',
            valor: formatarMoeda(valorLiquidoCalculado),
            icone: Icons.account_balance_wallet,
            cor: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registrosVisiveis = _indicesVisiveis;
    final temMateriais = materiaisGlobais.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Registro Diário'),
        backgroundColor: const Color.fromARGB(255, 11, 41, 77),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: escolherFiltro,
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filtrar por data',
          ),
          if (dataFiltro != null)
            IconButton(
              onPressed: limparFiltro,
              icon: const Icon(Icons.clear),
              tooltip: 'Limpar filtro',
            ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 11, 41, 77),
              Color.fromARGB(255, 18, 64, 119),
            ],
          ),
        ),

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 11, 41, 77),
                        const Color.fromARGB(255, 11, 41, 77),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 11, 41, 77),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo da Campanha',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _summaryCard(
                        titulo: 'Total vendido',
                        valor: formatarMoeda(totalVendido),
                        icone: Icons.trending_up,
                        cor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      _summaryCard(
                        titulo: 'Total comprado',
                        valor: formatarMoeda(totalComprado),
                        icone: Icons.shopping_cart,
                        cor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      _summaryCard(
                        titulo: 'Total de livros',
                        valor: totalLivros.toString(),
                        icone: Icons.menu_book,
                        cor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 11, 41, 77),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 11, 41, 77),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            indiceEditando == null
                                ? 'Novo registro'
                                : 'Editar registro',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: escolherData,
                            icon: const Icon(Icons.date_range),
                            label: Text(formatarData(dataSelecionada)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: materialSelecionadoNome,
                        isExpanded: true,
                        dropdownColor: const Color.fromARGB(255, 11, 41, 77),
                        items: _materialItems(),
                        selectedItemBuilder: (context) {
                          return materiaisGlobais.map((material) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                material.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList();
                        },
                        decoration: InputDecoration(
                          labelText: 'Selecione o material',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 11, 41, 77),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: temMateriais
                            ? (value) {
                                setState(() {
                                  materialSelecionadoNome = value;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantidadeController,
                        onChanged: (_) => setState(() {}),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantidade de livros',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: formaPagamentoSelecionada,
                        decoration: const InputDecoration(
                          labelText: 'Forma de pagamento',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Dinheiro',
                            child: Text('Dinheiro'),
                          ),
                          DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                          DropdownMenuItem(
                            value: 'Cartão',
                            child: Text('Cartão'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            formaPagamentoSelecionada = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: observacaoController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Observação',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _previewCard(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: temMateriais ? salvarRegistro : null,
                              icon: Icon(
                                indiceEditando == null
                                    ? Icons.save
                                    : Icons.check,
                              ),
                              label: Text(
                                indiceEditando == null
                                    ? 'Salvar Registro'
                                    : 'Salvar Alteração',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  11,
                                  41,
                                  77,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                minimumSize: const Size.fromHeight(52),
                              ),
                            ),
                          ),
                          if (indiceEditando != null) ...[
                            const SizedBox(width: 10),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  limparFormulario();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(52, 52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Icon(Icons.close),
                            ),
                          ],
                        ],
                      ),
                      if (!temMateriais) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhum material disponível. Adicione materiais na tela Materiais.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 11, 41, 77),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estatísticas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _statTile(
                        'Melhor dia de vendas',
                        formatarMoeda(melhorDiaVendas),
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                      _statTile(
                        'Total acumulado da campanha',
                        formatarMoeda(totalAcumuladoCampanha),
                        Icons.account_balance_wallet,
                        const Color.fromARGB(255, 255, 255, 255),
                      ),
                      _statTile(
                        'Média diária de vendas',
                        formatarMoeda(mediaDiariaVendas),
                        Icons.show_chart,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: escolherFiltro,
                      icon: const Icon(Icons.filter_alt),
                      label: const Text('Filtrar por Data'),
                    ),
                  ],
                ),
                if (dataFiltro != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Chip(
                          label: Text('Filtro: ${formatarData(dataFiltro!)}'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: limparFiltro,
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),
                  ),
                if (registrosVisiveis.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 11, 41, 77),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inbox, size: 42, color: Colors.white54),
                        SizedBox(height: 10),
                        Text(
                          'Nenhum registro encontrado',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: registrosVisiveis.length,
                    itemBuilder: (context, index) {
                      return _registroCard(registrosVisiveis[index]);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
