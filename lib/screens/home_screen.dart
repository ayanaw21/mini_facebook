import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/post_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mini Facebook")),
      body: StreamBuilder<QuerySnapshot>(
        stream: PostService().getPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                child: Column(
                  children: [
                    Text(doc['email']),
                    Text(doc['text']),
                    Image.network(doc['image']),
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: () {
                        doc.reference.update({
                          'likes': doc['likes'] + 1
                        });
                      },
                    ),
                    Text("Likes: ${doc['likes']}"),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
