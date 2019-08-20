import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onetap/router.dart';
import 'package:onetap/view/registerPage.dart';
import 'package:onetap/widgets/userWidget.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _password, _email;
  bool _isLogging = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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
                          padding: EdgeInsets.all(5),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: MaterialButton(
                            color: Colors.blue,
                            height: 50,
                            child: _isLogging ? CircularProgressIndicator(backgroundColor: Colors.white) : Text("Login",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700),),
                            onPressed: (){
                               if(_formKey.currentState.validate()){
                                  _login(_email, _password);
                               }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(),
                InkWell(
                  child: Center(child: Text("Registre-se")),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RegisterPage()
                    ));
                  },
                )
              ],
            )
        ),
      )
    );
  }
  Future<void> _login(String email, String password)async {
      try{
        setState(() {
         _isLogging = true; 
        });
        AuthResult authRes = await _auth.signInWithEmailAndPassword(email: email,password: password);
        if(authRes.user != null){
          final user = authRes.user;
          DocumentSnapshot userData = await Firestore.instance.collection('users').document(user.uid).get().then((onValue){
            return onValue;
          });
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => UserWidget(user: user,userData: userData,child: DashboardRouter())
          ));
        }
      }catch(e){
        setState(() {
          _isLogging = false; 
        });
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text(e.message))
        );
    }
  }
}