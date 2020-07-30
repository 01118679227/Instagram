import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:insta/model/user.dart';
import 'package:insta/pages/CreateAccountPage.dart';
import 'package:insta/pages/profilePage.dart';
import 'package:insta/pages/searchPage.dart';
import 'package:insta/pages/timeLinePage.dart';
import 'package:insta/pages/uploadPage.dart';
import 'package:insta/pages/notificationspage.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final GoogleSignIn gSignIn = GoogleSignIn();
final usersReference = Firestore.instance.collection('users');
final StorageReference storageReference = FirebaseStorage.instance.ref().child('Posts Pictures');
final postsReference = Firestore.instance.collection('posts');
final DateTime timestamp = DateTime.now();
User currentUser;

class _HomePageState extends State<HomePage> {
  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;
  void initState() {
    super.initState();
    pageController = PageController();
    gSignIn.onCurrentUserChanged.listen((gSignInAccount) {
      controlSignIn(gSignInAccount);
    }, onError: (gError) {
      print("error Message" + gError);
    });

  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    if (signInAccount != null) {
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
    } else {
      setState(() {
        isSignedIn = false;
      });
    }
  }
  saveUserInfoToFireStore() async{
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    DocumentSnapshot documentSnapshot = await usersReference.document(gCurrentUser.id).get();

    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=> CreateAccountPage()));
      usersReference.document(gCurrentUser.id).setData({
        'id' : gCurrentUser.id,
        'profileName': gCurrentUser.displayName,
        'username' :username,
        'url': gCurrentUser.photoUrl,
        'mail':gCurrentUser.email,
        'bio': "",
        'timestamp': timestamp,
      });
      documentSnapshot = await usersReference.document(gCurrentUser.id).get();
    }

    currentUser = User.fromDocument(documentSnapshot);
  }

  loginUser() {
    gSignIn.signIn();
  }

  logOutUser() {
    gSignIn.signOut();
  }

  OnTapChangePage(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  whenPageChanged(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  void dispose(){
    super.dispose();
    pageController.dispose();
  }

  Scaffold buildHomeScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          TimeLinePage(userProfileId: currentUser.id),
          SearchPage(),
          UploadPage(gCurrentUser: currentUser,),
          NotificationsPage(),
          ProfilePage(userProfileId: currentUser.id),
        ],
        controller: pageController,
        onPageChanged: whenPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getPageIndex,
        onTap: OnTapChangePage,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blueGrey,
        //activeColor: Colors.white,
        //inactiveColor: Colors.blueGrey,
        backgroundColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),title: Text('')),
          BottomNavigationBarItem(icon: Icon(Icons.search),title: Text('')),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 37.0,),title: Text('')),
          BottomNavigationBarItem(icon: Icon(Icons.notifications),title: Text('')),
          BottomNavigationBarItem(icon: Icon(Icons.person),title: Text('')),
        ],
      ),
    );
  }

  Scaffold buildSignInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'InstaGram',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 92.0,
                  fontFamily: "Signatra",
                ),
              ),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270.0,
                height: 65.0,
                decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(50.0),
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
