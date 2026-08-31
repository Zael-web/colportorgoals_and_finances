import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/material_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _materiaisCollectionFor(
    String? userId,
  ) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return _firestore.collection('materiais');
    }

    return _firestore.collection('usuarios').doc(uid).collection('materiais');
  }

  Future<void> adicionarMaterial(MaterialModel material, {String? userId}) async {
    await _materiaisCollectionFor(userId).add(material.toMap());
  }

  Future<void> atualizarMaterial(MaterialModel material, {String? userId}) async {
    if (material.id == null || material.id!.isEmpty) {
      throw ArgumentError('O material precisa de um ID para ser atualizado.');
    }

    await _materiaisCollectionFor(userId).doc(material.id).update(material.toMap());
  }

  Future<void> excluirMaterial(String id, {String? userId}) async {
    await _materiaisCollectionFor(userId).doc(id).delete();
  }

  Stream<List<MaterialModel>> listarMateriais({String? userId}) {
    return _materiaisCollectionFor(userId).orderBy('nome').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaterialModel.fromMap(
          doc.data(),
          id: doc.id,
        );
      }).toList();
    });
  }
}