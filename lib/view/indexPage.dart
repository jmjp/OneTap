import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:onetap/widgets/postCard.dart';
import 'package:onetap/widgets/userWidget.dart';
import 'package:percent_indicator/percent_indicator.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  var db = Firestore.instance;
  int limitPosts = 2;
  List<String> friends;
  ScrollController _scrollController = new ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
       int value = limitPosts + 1;
       setState(() {
        limitPosts = value; 
       });
      }
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final user = UserWidget.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text("OneTap"),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
         StreamBuilder<DocumentSnapshot>(
           stream: db.collection('users').document(user.uid).snapshots(),
           builder: (context,snapshot){
             if(snapshot.hasData){
               List<dynamic> seguindo = snapshot.data.data['seguindo'];
               return StreamBuilder<QuerySnapshot>(
                 stream: db.collection('posts').orderBy('data',descending: true).limit(limitPosts).snapshots(),
                 builder: (context,snapshot){
                   if(snapshot.hasData){
                     return ListView.builder(
                       shrinkWrap: true,
                       physics: NeverScrollableScrollPhysics(),
                       itemCount: snapshot.data.documents.length,
                       itemBuilder: (context,int index){
                         if(seguindo.contains(snapshot.data.documents[index].data['creator']['uid'])){
                           return PostCard(data: snapshot.data.documents[index]);
                         }
                       },
                     );
                   }else if(snapshot.hasError){
                     return Text("Error");
                   }
                   return CircularProgressIndicator();
                 },
               );
             }else if(snapshot.hasError){
               return Text("Error");
             }
             return Center(child: CircularProgressIndicator());
           },
         )
        ],
      ),
    );
  }
}