import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:onetap/widgets/userWidget.dart';
import 'package:video_player/video_player.dart';

class PublishPage extends StatefulWidget {
  BuildContext context;
  PublishPage({Key key,this.context}) : super(key: key);

  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  VideoPlayerController _videocontroller;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _storageRef = FirebaseStorage.instance.ref();
  bool _uploading = false;
  File _image;
  String postText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     
  }
  @override
  Widget build(BuildContext context) {
    final user = UserWidget.of(widget.context).user;
    final userData = UserWidget.of(widget.context).userData;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Novo post"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Container(
        margin: EdgeInsets.all(5),
        height: 150,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color:Color(0xFFBCBBC1), width: 0.5),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
              Container(
                      margin: EdgeInsets.all(10),
                      height: 129,
                      width: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[200],Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                        ),
                        border: Border.all(color:Color(0xFFBCBBC1), width: 0.5),
                      ),
                      child: _image == null ? IconButton(
                        icon: Icon(Icons.videocam, color: _image == null ? Colors.black : Colors.white),
                        onPressed: (){
                          getImage();
                        }
                      ) : InkWell(
                        child: VideoPlayer(_videocontroller),
                        onTap: (){
                          _videocontroller.value.isPlaying ?_videocontroller.pause() : _videocontroller.play();
                        },
                      )
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 200
                      ),
                      child: TextField(
                        maxLines: 3,
                        maxLength: 120,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:Color(0xFFBCBBC1), width: 0.5)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:Color(0xFFBCBBC1), width: 0.5)
                          ),
                          hintText: "Digite um texto para sua foto"
                        ),
                        onChanged: (value){
                          setState(() {
                           postText = value; 
                          });
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          MaterialButton(
            child: _uploading == true ? CircularProgressIndicator(backgroundColor: Colors.white,) : Text("Publicar",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 18)),
            color: Colors.blue,
            height: 45,
            onPressed: ()async{
             if(_image != null){
                int fileSize = await _image.length();
                  setState(() {
                   _uploading = true; 
                  });
                  final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('/mediaFile/posts/${user.uid}/${Timestamp.now().toDate()}.mp4');
                  final StorageUploadTask task = firebaseStorageRef.putFile(_image);
                  StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;
                  String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
                  Firestore.instance.collection('posts').document().setData({
                    "creator": {
                      "photo": userData.data['photo'],
                      "uid": user.uid,
                      "username" : userData.data['username'],
                    },
                    "data": Timestamp.now(),
                    "photo": downloadUrl,
                    "text": postText,
                    "comments":[],
                    "like":[],
                    "photoRef": storageTaskSnapshot.ref.path
                  });
                  setState(() {
                   _uploading = false; 
                  });
                  Navigator.pop(context);
                }else{
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Você precisa utilizar uma foto até 5mb")));
                }
            },
          ),
        
        ],
      )
    );
  }
   Future getImage() async {
    var image = await ImagePicker.pickVideo(source: ImageSource.camera);

    setState(() {
      _image = image;

    });
    if(_image != null){
       _videocontroller = VideoPlayerController.file(_image)..initialize().then((_){
       setState(() {
         
       });
     });
    }
  }

}