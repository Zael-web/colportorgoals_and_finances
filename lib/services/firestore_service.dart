import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/material_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _materiaisCollection {
    return _firestore.collection('materiais');
  }

  Future<void> adicionarMaterial(MaterialModel material) async {
    await _materiaisCollection.add(material.toMap());
  }

  Future<void> atualizarMaterial(MaterialModel material) async {
    if (material.id == null || material.id!.isEmpty) {
      throw ArgumentError('O material precisa de um ID para ser atualizado.');
    }

    await _materiaisCollection.doc(material.id).update(material.toMap());
  }

  Future<void> excluirMaterial(String id) async {
    await _materiaisCollection.doc(id).delete();
  }

  Stream<List<MaterialModel>> listarMateriais() {
    return _materiaisCollection.orderBy('nome').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaterialModel.fromMap(
          doc.data(),
          id: doc.id,
        );
      }).toList();
    });
  }
}