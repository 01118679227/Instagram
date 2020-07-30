import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:insta/model/user.dart';
import 'package:insta/pages/HomePage.dart';
import 'package:insta/widget/progressWidget.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

 class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  emptyTheTextFormField(){
    searchTextEditingController.clear();
  }

  controlSearching(String str){
    Future<QuerySnapshot> allUsers = usersReference.where('profileName', isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white
        ),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "Search here....",
            hintStyle:TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(Icons.person_pin,color: Colors.white,size: 30.0,),
          suffixIcon: IconButton(icon: Icon(Icons.clear,color: Colors.white), onPressed: emptyTheTextFormField,),
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Container displayNoSearchResultScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group,color: Colors.grey,size: 200.0,),
            Text('Search Users',
            textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 65.0,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayUsersFoundScreen(){
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context,dataSnapShot){
        if(!dataSnapShot.hasData){
          return circularProgress();
        }

        List<UserResult> searchusersresult = [];
        dataSnapShot.data.documents.forEach((document){
          User eachuser = User.fromDocument(document);
          UserResult userResult = UserResult(eachuser);
          searchusersresult.add(userResult);
        });

        return ListView(
          children:  searchusersresult
        );
      },
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResults == null ? displayNoSearchResultScreen() : displayUsersFoundScreen(),
    );
  }
}
class UserResult extends StatelessWidget {
final User eachuser;
UserResult(this.eachuser);
  @override
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.all(3.0),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: ()=> print("Tapped"),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: Image.network(eachuser.url).image,
                ),
                title: Text(eachuser.profileName,style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold
                ),),
                subtitle: Text(eachuser.username,style: TextStyle(
                    color: Colors.black,
                    fontSize: 13.0,
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
