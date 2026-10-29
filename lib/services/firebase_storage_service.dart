import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/node_model.dart';

class FirebaseStorageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Current user ki UID nikalne ke liye
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ==========================================
  // 👇 PURANA CODE: Load & Save Nodes
  // ==========================================

  // Cloud se saare nodes load karein
  Future<List<MindMapNode>> getAllNodes() async {
    if (_uid == null) return [];

    try {
      final snapshot =
          await _db.collection('users').doc(_uid).collection('nodes').get();

      return snapshot.docs
          .map((doc) => MindMapNode.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error loading from cloud: $e");
      return [];
    }
  }

  // 👇 NAYA: Media Upload Function
  Future<String?> uploadMedia(Uint8List fileBytes, String fileName) async {
    if (_uid == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(
          'users/$_uid/media/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      // Upload bytes (Web aur Mobile dono ke liye kaam karega)
      final uploadTask = await ref.putData(fileBytes);

      // Download URL nikaalein
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint("Media upload error: $e");
      return null;
    }
  }

  // 👇 NAYA: Bulk Upload Local Media for Share
  Future<List<MindMapNode>> uploadLocalMediaForNodes(
      List<MindMapNode> nodes) async {
    List<MindMapNode> updatedNodes = [];

    for (var node in nodes) {
      List<MediaItem> updatedMedia = [];
      for (var media in node.media) {
        if (media.isLocal) {
          // 👇 Web par local file read nahi hoti, isliye skip kar rahe hain
          if (kIsWeb) {
            updatedMedia.add(media);
            continue;
          }

          try {
            final file = File(media.url);
            final bytes = await file.readAsBytes();

            final url = await uploadMedia(bytes, file.path.split('/').last);

            if (url != null) {
              updatedMedia
                  .add(MediaItem(url: url, type: media.type, isLocal: false));
            } else {
              updatedMedia.add(media);
            }
          } catch (e) {
            debugPrint("Error uploading local media: $e");
            updatedMedia.add(media);
          }
        } else {
          updatedMedia.add(media);
        }
      }
      node.media = updatedMedia;
      updatedNodes.add(node);
    }
    return updatedNodes;
  }

  // Cloud par saare nodes save/update karein
  Future<void> saveNodes(List<MindMapNode> nodes) async {
    if (_uid == null) return;

    try {
      final colRef = _db.collection('users').doc(_uid).collection('nodes');
      final batch = _db.batch();

      // Purane nodes fetch karein taaki delete hue nodes cloud se hat sakein
      final existing = await colRef.get();
      final newIds = nodes.map((n) => n.id).toSet();

      // Jo nodes delete ho chuke hain unhe cloud se delete karein
      for (var doc in existing.docs) {
        if (!newIds.contains(doc.id)) {
          batch.delete(doc.reference);
        }
      }

      // Naye/Updated nodes ko batch mein add karein
      for (var node in nodes) {
        batch.set(colRef.doc(node.id), node.toJson());
      }

      await batch.commit();
    } catch (e) {
      debugPrint("Error saving to cloud: $e");
    }
  }

  // ==========================================
  // 👇 NAYA CODE: Share to Store Feature
  // ==========================================

  /// Map ko Community Store par share karne ke liye.
  /// Returns: "Success", "Duplicate" (agar pehle se hai), ya error message.
  Future<String?> shareTemplateToCloud({
    required String title,
    required String description,
    required List<MindMapNode> nodes,
  }) async {
    if (_uid == null) return "User not logged in";

    try {
      final colRef = _db.collection('shared_templates');

      // 1. Duplicate Check: Kya is user ne same title se map share kiya hai?
      final existing = await colRef
          .where('authorId', isEqualTo: _uid)
          .where('title', isEqualTo: title)
          .get();

      if (existing.docs.isNotEmpty) {
        return "Duplicate";
      }

      // 2. Naya document create karein Store ke liye
      await colRef.add({
        'title': title,
        'description': description,
        'authorId': _uid,
        'authorEmail':
            FirebaseAuth.instance.currentUser?.email ?? 'Unknown User',
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
        'downloads': 0, // Future mein track karne ke liye
      });

      return "Success";
    } catch (e) {
      debugPrint("Error sharing template to cloud: $e");
      return e.toString();
    }
  }
}
