import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final posts = FirebaseFirestore.instance.collection('posts');

  Future<void> addPost(String text, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;

    await posts.add({
      'text': text,
      'image': imageUrl,
      'userId': user!.uid,
      'email': user.email,
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPosts() {
    return posts.orderBy('timestamp', descending: true).snapshots();
  }
}
