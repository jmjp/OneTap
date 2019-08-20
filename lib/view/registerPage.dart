import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onetap/router.dart';
import 'package:onetap/widgets/userWidget.dart';
import 'dart:io';

class RegisterPage extends StatefulWidget {
 RegisterPage({Key key}) : super(key: key);

  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _password, _email,_username;
  bool _isLogging = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Center(
          child:
          ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(10),
                          height: 129,
                          width: 130,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[200],Colors.white],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter
                            ),
                            border: Border.all(color:Color(0xFFBCBBC1), width: 0.5),
                            borderRadius: BorderRadius.circular(100),
                            image: _image == null ? null : DecorationImage(
                              image: FileImage(_image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                            )
                          ),
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color: _image == null ? Colors.black : Colors.white),
                            onPressed: (){
                              getImage();
                            },
                          ),
                        ),
                        TextFormField(
                          validator: (value){
                            if(value.isEmpty || value.length < 10 || !value.contains('@')){
                              return "Verifique o email digitado";
                            }else{
                              setState(() {
                               _email = value; 
                              });
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            ),
                            suffixIcon: Icon(Icons.alternate_email,color: Colors.grey,),
                            hintText: "Email@Provedor.com"
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        TextFormField(
                          obscureText: true,
                          validator: (value){
                            if(value.isEmpty || value.length < 3){
                              return "Verifique a senha digitada";
                            }else{
                              setState(() {
                               _password = value; 
                              });
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            ),
                            suffixIcon: Icon(Icons.security,color: Colors.grey,),
                            hintText: "1234mudar"
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10,bottom: 10),
                          child: TextFormField(
                            validator: (value){
                              if(value.isEmpty || value.length < 3){
                                return "Verifique o username digitado";
                              }else{
                                setState(() {
                                _username = value.toLowerCase(); 
                                });
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFBCBBC1), width: 0.5)
                            
                              ),
                              suffixIcon: Icon(Icons.face,color: Colors.grey,),
                              hintText: "LaBallita"
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            color: Colors.blue,
                            height: 50,
                            child: _isLogging ? CircularProgressIndicator(backgroundColor: Colors.white) : Text("Registrar",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),),
                            onPressed: (){
                               if(_formKey.currentState.validate()){
                                  _register(_email, _password, _username);
                               }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
      )
    );
  }
  Future<void> _register(String email, String password,String username)async {
        setState(() {
         _isLogging = true; 
        });
        if(_image != null){
          Firestore.instance.collection('users').where('username',isEqualTo: username).getDocuments().then((onValue)async{
            if(onValue.documents.length == 0){
               try{
                 AuthResult user = await _auth.createUserWithEmailAndPassword(email: email,password: password);
                if(user.user != null){
                final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child('/mediaFile/profile/${user.user.uid}/profile.jpg');
                  final StorageUploadTask task = firebaseStorageRef.putFile(_image);
                  StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;
                  String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
                  Firestore.instance.collection('users').document(user.user.uid).setData({
                    "photo": downloadUrl,
                    "username": username,
                    "verificado": false,
                    "seguindo": [],
                    "seguidores": []
                  });
                  DocumentSnapshot userData = await Firestore.instance.collection('users').document(user.user.uid).get().then((onValue){
                    return onValue;
                  });
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (_) => UserWidget(user: user.user,userData: userData,)
                  ));
                }
               }catch(e){
                _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text(e.message))
                );
                setState(() {
                _isLogging = false; 
              });
              }
            }else{
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Username ja utilizado"))
              );
               setState(() {
              _isLogging = false; 
            });
            }
          });
         
        }else{
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Selecione uma imagem de perfil"))
          );
           setState(() {
            _isLogging = false; 
          });
    }
  }
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }
}