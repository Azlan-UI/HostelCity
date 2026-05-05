import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  // Generic collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  // Users Collection
  CollectionReference get usersCollection =>
      _firestore.collection(FirebaseConstants.usersCollection);

  // Hostels Collection
  CollectionReference get hostelsCollection =>
      _firestore.collection(FirebaseConstants.hostelsCollection);

  // Rooms Collection
  CollectionReference get roomsCollection =>
      _firestore.collection(FirebaseConstants.roomsCollection);

  // Beds Collection
  CollectionReference get bedsCollection =>
      _firestore.collection(FirebaseConstants.bedsCollection);

  // Residents Collection
  CollectionReference get residentsCollection =>
      _firestore.collection(FirebaseConstants.residentsCollection);

  // Payments Collection
  CollectionReference get paymentsCollection =>
      _firestore.collection(FirebaseConstants.paymentsCollection);

  // Complaints Collection
  CollectionReference get complaintsCollection =>
      _firestore.collection(FirebaseConstants.complaintsCollection);

  // Notices Collection
  CollectionReference get noticesCollection =>
      _firestore.collection(FirebaseConstants.noticesCollection);

  // Reviews Collection
  CollectionReference get reviewsCollection =>
      _firestore.collection(FirebaseConstants.reviewsCollection);

  // Generic CRUD Operations

  // Create document
  Future<String> createDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'create document in $collectionPath');
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  // Create document with custom ID
  Future<void> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'set document $documentId in $collectionPath');
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

  // Read document
  Future<DocumentSnapshot> getDocument(String collectionPath, String documentId) async {
    try {
      return await _firestore.collection(collectionPath).doc(documentId).get();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'get document $documentId in $collectionPath');
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  // Update document
  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'update document $documentId in $collectionPath');
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  // Delete document
  Future<void> deleteDocument(String collectionPath, String documentId) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'delete document $documentId in $collectionPath');
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Stream document
  Stream<DocumentSnapshot> streamDocument(String collectionPath, String documentId) {
    return _firestore.collection(collectionPath).doc(documentId).snapshots();
  }

  // Stream collection
  Stream<QuerySnapshot> streamCollection(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // Stream collection with query
  Stream<QuerySnapshot> streamCollectionWithQuery(Query query) {
    return query.snapshots();
  }

  // Batch write
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(
              _firestore.collection(operation.collectionPath).doc(operation.documentId),
              operation.data!,
            );
            break;
          case BatchOperationType.update:
            batch.update(
              _firestore.collection(operation.collectionPath).doc(operation.documentId),
              operation.data!,
            );
            break;
          case BatchOperationType.delete:
            batch.delete(
              _firestore.collection(operation.collectionPath).doc(operation.documentId),
            );
            break;
        }
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'batch write');
    } catch (e) {
      throw Exception('Batch write failed: $e');
    }
  }

  // Transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, 'transaction');
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  // Enable offline persistence
  Future<void> enableOfflinePersistence() async {
    try {
      // Offline persistence is enabled by default in Flutter
      // No action needed
    } catch (e) {
      print('Offline persistence: $e');
    }
  }

  // Error handling helper
  Exception _handleFirebaseException(FirebaseException e, String operation) {
    if (e.code == 'permission-denied') {
      return Exception('Access Denied: You do not have permission to $operation. ${e.message}');
    } else if (e.code == 'not-found') {
      return Exception('Not Found: The requested document for $operation does not exist.');
    } else if (e.code == 'unavailable') {
      return Exception('Service Unavailable: Firestore is temporarily offline. Please check your connection.');
    }
    return Exception('Firestore Error during $operation: ${e.message}');
  }
}

// Batch operation model
class BatchOperation {
  final BatchOperationType type;
  final String collectionPath;
  final String documentId;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.type,
    required this.collectionPath,
    required this.documentId,
    this.data,
  });
}

enum BatchOperationType {
  set,
  update,
  delete,
}
