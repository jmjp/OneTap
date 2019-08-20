import 'package:flutter/material.dart';
import 'package:onetap/view/indexPage.dart';
import 'package:onetap/view/publishPage.dart';


class DashboardRouter extends StatefulWidget {
  DashboardRouter({Key key}) : super(key: key);

  _DashboardRouterState createState() => _DashboardRouterState();
}

class _DashboardRouterState extends State<DashboardRouter> with SingleTickerProviderStateMixin{
  TabController _tabcontroller;
  @override
  void initState() { 
    super.initState();
    _tabcontroller = new TabController(vsync: this,length: 4);
     
  }
  @override
  void dispose() { 
    _tabcontroller.dispose();
    super.dispose();
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabcontroller,
        children: <Widget>[
          IndexPage(),
          Text("data.data['username']"),
          Text("page 03"),
          Text("page 04"),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.control_point),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => PublishPage(context: this.context,)
          ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: TabBar(
          controller: _tabcontroller,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.search)),
            Tab(icon: Icon(Icons.control_point)),
            Tab(icon: Icon(Icons.textsms))
          ],
        ),
      ),
    );
  }
}