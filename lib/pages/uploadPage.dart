import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/model/user.dart';
import 'package:insta/widget/progressWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:insta/pages/HomePage.dart';
import 'package:image/image.dart' as ImD;

class UploadPage extends StatefulWidget {
  final User gCurrentUser;
  UploadPage({this.gCurrentUser});
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>  with AutomaticKeepAliveClientMixin<UploadPage>{
File file;
bool uploading = false;
String postId = Uuid().v4();
TextEditingController descriptionTextEditingController = TextEditingController();
TextEditingController locationTextEditingController = TextEditingController();


CaptureImagewithCamera() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera,
    maxHeight: 600,
    maxWidth: 970,
    );
    setState(() {
      this.file = imageFile;
    });
  }

pickImageFromGallery() async{
  Navigator.pop(context);
  File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery,
  );
  setState(() {
    this.file = imageFile;
  });
}

takeImage(context){
    return showDialog(
    context: context,
    builder: (context){
      return SimpleDialog(
        title: Text("New Post",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        children: <Widget>[
          SimpleDialogOption(
            child: Text('Capture Image with Camera',style: TextStyle(color: Colors.white),),
            onPressed: CaptureImagewithCamera,
          ),
          SimpleDialogOption(
            child: Text('Select Image from Gallery',style: TextStyle(color: Colors.white),),
            onPressed: pickImageFromGallery,
          ),
          SimpleDialogOption(
            child: Text('Cancel',style: TextStyle(color: Colors.white),),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ],
      );
    }
    );
  }
  
displayUploadScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add_photo_alternate,color: Colors.grey,size: 200.0,),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0)
              ),
                child: Text("Upload Image",
                style: TextStyle(color: Colors.white,fontSize: 20.0),
                ),
                onPressed: ()=> takeImage(context),
            ),
          ),
        ],
      ),
    );
  }

    controlUploadAndSave() async{
     setState(() {
       uploading = true;
     });

     await compressingPhoto();
     String downloadUrl = await uploadPhoto(file);

     savePostInfoToFirestore(url: downloadUrl,location : locationTextEditingController.text,description : descriptionTextEditingController.text);

     locationTextEditingController.clear();
     descriptionTextEditingController.clear();

     setState((){
       file = null;
       uploading = null;
       postId = Uuid().v4();
     });

    }

    savePostInfoToFirestore({String url,String location,String description}) async{
      postsReference.document(widget.gCurrentUser.id).collection('usersPosts').document(postId).setData({
        'postId' : postId,
        'ownerId' : widget.gCurrentUser.id,
        'timestamp' : timestamp,
        'likes' :{},
        'username':widget.gCurrentUser.username,
        'description': description,
        'location': location,
        'url' : url,
      });
    }

    compressingPhoto() async{
      final tDirectory = await getTemporaryDirectory();
      final path = tDirectory.path;
      ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
      final compressImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile,quality: 60));
      setState(() {
        file = compressImageFile;
      });
    }

    Future<String> uploadPhoto(mImageFile) async{
      StorageUploadTask mStorageUploadTask = storageReference .child('post_$postId.jpg').putFile(mImageFile);
      StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
      String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    }

clearPostInfo(){
  locationTextEditingController.clear();
  descriptionTextEditingController.clear();
  setState(() {
    file = null;
  });
}

getUserCurrentLocation() async{

  final position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placeMark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark mPlaceMark = placeMark[0];
  String completeAddressInfo =
      '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
      '${mPlaceMark.subLocality} ${mPlaceMark.locality},'
      '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}'
      ',${mPlaceMark.postalCode} ${mPlaceMark.country}';
  String specificAddress  = '${mPlaceMark.locality}, ${mPlaceMark.country}';
  setState(() {
    locationTextEditingController.text = specificAddress;
  });
}

displayUploadForm(){
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,), onPressed: clearPostInfo),
      title: new Text("New Post",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24.0,color: Colors.white),),
      actions: <Widget>[
        FlatButton(
            onPressed: uploading  ? null : ()=> controlUploadAndSave(),
            child: Text("Share",
              style: TextStyle(color: Colors.lightGreenAccent,fontWeight: FontWeight.bold,fontSize: 16.0,),),
        ),
      ],
    ),
    body: ListView(
      children: <Widget>[
        uploading ? LinearProgress() : Text(''),
        Container(
          height: 230.0,
          width: MediaQuery.of(context).size.width ,
          child: Center(
            child: AspectRatio(
                aspectRatio: 16/9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(file),
                  fit: BoxFit.cover
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.0),
        ),
        ListTile(
          leading: CircleAvatar(backgroundImage: Image.network(widget.gCurrentUser.url).image,),
          title: Container(
            width: 250.0,
            child: TextField(
              style: TextStyle(
                color: Colors.white
              ),
              controller: descriptionTextEditingController,
              decoration: InputDecoration(
                hintText: "Say something about image.",
                hintStyle: TextStyle(
                  color: Colors.white
                ),
                border: InputBorder.none
              ),
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.person_pin_circle,color: Colors.white,size: 36.0,),
          title: Container(
            width: 250.0,
            child: TextField(
              style: TextStyle(
                  color: Colors.white
              ),
              controller: locationTextEditingController,
              decoration: InputDecoration(
                  hintText: "Write the location here.",
                  hintStyle: TextStyle(
                      color: Colors.white
                  ),
                  border: InputBorder.none
              ),
            ),
          ),
        ),
        Container(
          width: 220.0,
          height: 110.0,
          alignment: Alignment.center,
          child: RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35.0),
            ),
              color: Colors.green,
              icon: Icon(Icons.location_on,color: Colors.white,),
              label: Text("Get my Current location",style: TextStyle(color: Colors.white),),
              onPressed: getUserCurrentLocation,
          ),
        )
      ],
    ),
  );
}


bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadForm();
  }
}
