import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final String uid;

  DatabaseService({required this.uid});

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  // Insert module
  Future<String> insertModule(Map<String, dynamic> module) async {
    DocumentReference docRef = await userCollection.doc(uid).collection('modules').add(module);
    return docRef.id;
  }

  // Query all modules
  // Query all modules
  Future<List<Map<String, dynamic>>> queryAllModules() async {
    try {
      QuerySnapshot snapshot =
      await userCollection.doc(uid).collection('modules').get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.code} - ${e.message}');
      print('Hata detayları: ${e.stackTrace}');
      return [];
    } catch (e, stackTrace) {
      print('Beklenmeyen bir hata oluştu: $e');
      print('Hata detayları: $stackTrace');
      return [];
    }
  }

  // Update module
  Future<void> updateModule(String moduleId, Map<String, dynamic> module) async {
    await userCollection
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .update(module);
  }

  // Delete module and its questions
  Future<void> deleteModule(String moduleId) async {
    // Delete the module document
    await userCollection
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .delete();
  }

  // Insert question
  Future<void> insertQuestion(
      String moduleId, Map<String, dynamic> question) async {
    await userCollection
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .add(question);
  }

  // Query questions for a module
  Future<List<Map<String, dynamic>>> queryQuestions(String moduleId) async {
    QuerySnapshot snapshot = await userCollection
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  // Delete all questions for a module
  Future<void> deleteQuestions(String moduleId) async {
    final questionsRef = userCollection
        .doc(uid)
        .collection('modules')
        .doc(moduleId)
        .collection('questions');

    QuerySnapshot snapshot = await questionsRef.get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Delete entire user data (if needed)
  Future<void> deleteUserData() async {
    await userCollection.doc(uid).delete();
  }
}