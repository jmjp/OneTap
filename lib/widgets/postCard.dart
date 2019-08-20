import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:onetap/widgets/userWidget.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  DocumentSnapshot data;
  PostCard({Key key,@required this.data}) : super(key: key);
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin{
  AnimationController _animationController;
  Animation<double> _animation;
  String commentText;
  VideoPlayerController _videoController;
  bool _iconPlaying = false;
  bool _volumeStatus = true;
  @override
  void initState() { 
    super.initState();
    _animationController = AnimationController(vsync: this,duration: Duration(milliseconds: 210));
    _animation = Tween<double>(begin: 20,end: 24).animate(_animationController)..addListener((){
      setState(() {

      });
    });
    _videoController = VideoPlayerController.network(widget.data.data['photo'])..initialize().then((_){
        setState(() {
          
        });
      });
  }
  @override
  Widget build(BuildContext context) {
    List<dynamic> comments = widget.data.data['comments'];
    List<dynamic> like = widget.data.data['like'];
    Timestamp postData = widget.data.data['data'];
   
    final user = UserWidget.of(context).user;
    final userData = UserWidget.of(context).userData;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color:Color(0xFFBCBBC1), width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.grey,
          blurRadius: 10.0,
          spreadRadius: 0.1
        )]
      ),
      padding: EdgeInsets.all(3),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10), 
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10,bottom: 5),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.data.data['creator']['photo']),
                    ),
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
          
                  Padding(
                    padding: EdgeInsets.only(left: 10,top: 0),
                    child: Text(widget.data.data['creator']['username'],style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),),
                  ),
                ],
              ),
              widget.data.data['creator']['uid'] == user.uid ? IconButton(
                icon: Icon(SimpleLineIcons.trash,size: 14,),
                onPressed: (){
                  //exclui post
                  FirebaseStorage.instance.ref().child(widget.data.data['photoRef']).delete();
                  Firestore.instance.document(widget.data.reference.path).delete();
                },
              ) : IconButton(
                icon: Icon(MaterialCommunityIcons.dots_horizontal,size: 14,),
                onPressed: (){
                  //exclui post
                },
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 2),
            child: _videoController == null ? Center(child: CircularProgressIndicator()) : Stack(
              children: <Widget>[
              VideoPlayer(_videoController),
              IconButton(
                icon: _iconPlaying ? Icon(Icons.pause_circle_outline, color: Colors.white) : Icon(Icons.play_circle_outline, color: Colors.white),
                onPressed: (){
                  if(_videoController.value.isPlaying){
                     _videoController.pause();
                     setState(() {
                     _iconPlaying = false; 
                    });
                  }else{
                    _videoController.play();
                    setState(() {
                     _iconPlaying = true; 
                    });
                  }
                },
              ),
              Positioned(
                top: 30,
                child: IconButton(
                  icon: _volumeStatus ? Icon(Icons.volume_up, color: Colors.white) : Icon(Icons.volume_off, color: Colors.white),
                  onPressed: (){
                    if(_videoController.value.volume == 0){
                      _videoController.setVolume(100);
                      setState(() {
                      _volumeStatus = true; 
                      });
                    }else{
                      _videoController.setVolume(0);
                      setState(() {
                      _volumeStatus = false; 
                      });
                    }
                  },
                ),
              )
              ],
            ),
            height: 220,
            width: MediaQuery.of(context).size.width,
          ),
          widget.data.data['text'].toString().isNotEmpty == true ? Text('${widget.data.data['creator']['username']}: ${widget.data.data['text']}',overflow: TextOverflow.ellipsis) : Text(""),
          Row(
            children: <Widget>[
              !like.contains(user.uid) ? FlatButton.icon(
                icon: Icon(AntDesign.hearto,size: _animation.value),
                label: Text(like.length.toString()),
                onPressed: (){
                  _animationController.forward();
                  Firestore.instance.document(widget.data.reference.path).updateData(
                    {
                      "like": FieldValue.arrayUnion([user.uid])
                    }
                  );
                },
              ) : FlatButton.icon(
                icon: Icon(AntDesign.heart,color: Colors.redAccent,size: _animation.value != 24 ? _animation.value : 24),
                label: Text(like.length.toString()),
                onPressed: (){
                  _animationController.reverse();
                  Firestore.instance.document(widget.data.reference.path).updateData(
                    {
                      "like": FieldValue.arrayRemove([user.uid])
                    }
                  );
                },
              ),
              FlatButton.icon(
                icon: Icon(MaterialCommunityIcons.comment_outline),
                label: Text(comments.length.toString()),
                onPressed: (){
                  
                },
              )
            ],
          ),
          comments.length > 0 ? Container(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20,right: 5),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(comments[comments.length - 1]['photo'].toString()),
                    radius: 10,
                  ),
                ),
               Flexible(
                 child: Text(comments[comments.length - 1]['text'].toString(),overflow: TextOverflow.ellipsis),
               )
              ],
            ),
          ) : Container(),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userData.data['photo']),
                  radius: 15,
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 115
                ),
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10),
                    border: InputBorder.none,
                    hintText: "Adicione um comentario.."
                  ),
                  onChanged: (value){
                    setState(() {
                     commentText = value; 
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(MaterialCommunityIcons.send_circle_outline),
                onPressed: (){
                  if(commentText.isNotEmpty){
                    Map<String,dynamic> comment = new Map<String,dynamic>();
                    comment['data'] = Timestamp.now();
                    comment['photo'] = userData.data['photo'];
                    comment['text'] = commentText;
                    comment['username'] = userData.data['username'];
                    comment['uid'] = user.uid;
                    Firestore.instance.document(widget.data.reference.path).updateData({
                      "comments": FieldValue.arrayUnion([comment])
                    });
                  }
                },
              )
            ],
          ),
          Text(getTime(postData),style: TextStyle(color: Colors.grey),)
        ],
      )
      );
  }
  String getTime(Timestamp time){
    Duration date = Timestamp.now().toDate().difference(time.toDate());
    if(date.inDays > 0){
      return "${date.inDays} dias atrás.";
    }
    if(date.inHours > 0){
      return "${date.inHours} horas atrás.";
    }
    if(date.inMinutes > 0 && date.inMinutes < 60){
      return "${date.inMinutes} minutos atrás.";
    }
    if(date.inSeconds > 0 && date.inSeconds < 60){
      return "${date.inSeconds} segundos atrás.";
    }
    return "Agora mesmo";
 
  }
}