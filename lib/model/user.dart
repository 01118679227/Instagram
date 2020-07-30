import 'package:cloud_firestore/cloud_firestore.dart';
class User{
  final String id;
  final String profileName;
  final String username;
  final String url;
  final String mail;
  final String bio;

  User({
    this.id,this.username,this.url,this.bio,this.mail,this.profileName
});
  factory User.fromDocument(DocumentSnapshot doc){
    return User(
      id: doc.documentID,
      mail: doc['email'],
      username: doc['username'],
      url: doc['url'],
      profileName: doc['profileName'],
      bio: doc['bio'],
    );
  }
}