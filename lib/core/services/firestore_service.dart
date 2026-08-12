import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getCollection(String name) {
    return _firestore.collection(name);
  }

  Future<DocumentSnapshot> getDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).get();
  }
  
  // Add other helper methods as needed
}