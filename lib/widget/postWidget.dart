
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta/model/user.dart';
import 'package:insta/pages/HomePage.dart';
import 'package:insta/widget/progressWidget.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  //final String timestamp;
  final dynamic likes;
  final String description;
  final String username;
  final String location;
  final String url;
  Post(
      {this.postId,
      this.url,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.ownerId});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot['postId'],
      ownerId: documentSnapshot['ownerId'],
      likes: documentSnapshot['likes'],
      description: documentSnapshot['description'],
      username: documentSnapshot['username'],
      location: documentSnapshot['location'],
      url: documentSnapshot['url'],
    );
  }

  getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        likes: this.likes,
        description: this.description,
        username: this.username,
        location: this.location,
        url: this.url,
        likeCount: getTotalNumberOfLikes(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  //final String timestamp;
  Map likes;
  final String description;
  final String username;
  final String location;
  final String url;
  int likeCount;
  bool isLike;
  bool showHeart = false;
  final String currentOnLineUserId = currentUser.id;
  _PostState(
      {this.postId,
      this.url,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.ownerId,
      this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data);
        bool isPostOwner = currentOnLineUserId == ownerId;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.url),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("show Profile"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: isPostOwner
              ? IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () => print("deleted"),
                )
              : Text(""),
        );
      },
    );
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => print('post liked'),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20.0),
            ),
            GestureDetector(
              onTap: () => print('liked post'),
              child: Icon(
                Icons.favorite,color: Colors.grey,
                //isLike ? Icons.favorite : Icons.favorite_border,
                //color: Colors.pink,
                //size: 28.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
            GestureDetector(
              onTap: () => print('show  commit'),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 28.0,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$likeCount likes',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                '$username likes',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
