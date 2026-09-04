import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/material_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _materiaisCollectionFor(
    String? userId,
  ) {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Faça login antes de sincronizar os materiais.',
      );
    }

    final uid = userId ?? usuario.uid;
    if (uid != usuario.uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Você não pode acessar materiais de outro usuário.',
      );
    }

    return _firestore.collection('usuarios').doc(uid).collection('materiais');
  }

  Future<String> adicionarMaterial(
    MaterialModel material, {
    String? userId,
  }) async {
    final collection = _materiaisCollectionFor(userId);
    if (material.id != null && material.id!.isNotEmpty) {
      await collection.doc(material.id).set(material.toMap());
      return material.id!;
    }

    final documento = await collection.add(material.toMap());
    return documento.id;
  }

  String mensagemDeErro(Object erro) {
    if (erro is FirebaseException) {
      return '${erro.code}: ${erro.message ?? 'erro do Firebase'}';
    }

    return erro.toString();
  }

  Future<void> atualizarMaterial(
    MaterialModel material, {
    String? userId,
  }) async {
    if (material.id == null || material.id!.isEmpty) {
      throw ArgumentError('O material precisa de um ID para ser atualizado.');
    }

    await _materiaisCollectionFor(
      userId,
    ).doc(material.id).update(material.toMap());
  }

  Future<void> excluirMaterial(MaterialModel material, {String? userId}) async {
    final collection = _materiaisCollectionFor(userId);
    if (material.id != null && material.id!.isNotEmpty) {
      await collection.doc(material.id).delete();
      return;
    }

    final snapshot = await collection
        .where('nome', isEqualTo: material.nome)
        .where('valorCompra', isEqualTo: material.valorCompra)
        .where('valorVenda', isEqualTo: material.valorVenda)
        .get();

    for (final documento in snapshot.docs) {
      await documento.reference.delete();
    }
  }

  Future<List<MaterialModel>> buscarMateriais({String? userId}) async {
    final snapshot = await _materiaisCollectionFor(userId).get();
    return snapshot.docs.map((doc) {
      return MaterialModel.fromMap(doc.data(), id: doc.id);
    }).toList();
  }

  Stream<List<MaterialModel>> listarMateriais({String? userId}) {
    return _materiaisCollectionFor(userId).orderBy('nome').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return MaterialModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }
}
