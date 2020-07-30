import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:insta/model/user.dart';
import 'package:insta/pages/EditProfilePage.dart';
import 'package:insta/pages/HomePage.dart';
import 'package:insta/widget/postTile.dart';
import 'package:insta/widget/postWidget.dart';
import 'package:insta/widget/progressWidget.dart';
import 'package:flutter/material.dart';
import 'package:insta/widget/HeaderPage.dart';
class TimeLinePage extends StatefulWidget {
  final String userProfileId;
  TimeLinePage({this.userProfileId});
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  //final String currentOnLineUserId = currentUser.id;
  bool loading = false;
 // int countPost = 0;
  List<Post> postsList = [];
  String postOrientation = "list";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllProfilePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Instagram"),
      body: ListView(
        children: <Widget>[
         // createProfileTopView(),
         // Divider(),
          //createListAndGridPostOrientation(),
          Divider(height: 0.0,),
          displayProfilePost(),

        ],
      ),
    );
  }
  displayProfilePost(){
    if(loading){
      return circularProgress();
    }
    else if(postsList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Icon(Icons.photo_library,color: Colors.grey,size: 100.0,),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text('No Posts',style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold
              ),),
            ),
          ],
        ),
      );
    }

    else {

      return Column(
        children: postsList,
      );
    }

  }
  getAllProfilePosts() async{
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference.document(widget.userProfileId).
    collection('usersPosts').orderBy("timestamp",descending: true).getDocuments();

    setState(() {
      loading = false;
      //countPost = querySnapshot.documents.length;
      postsList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();

    });
  }

}
