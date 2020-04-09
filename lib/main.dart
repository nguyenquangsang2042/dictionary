import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dictionary',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Dictionary'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url="https://owlbot.info/api/v4/dictionary/";
  String _token="b591f8c6a4cd88fbd22bf4bad4eb07f2e36d906e";

  TextEditingController _controller=TextEditingController();

  StreamController _streamController;
  Stream _stream;

  Timer _timer;
  _search() async{
    if(_controller.text==null||_controller.text.length==0)
     {
       _streamController.add(null);
       return;
     }
    _streamController.add("waiting");
    Response response= await get(_url+_controller.text.trim(),headers:{"Authorization":"Token "+_token});
    _streamController.add(json.decode(response.body));
  }
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

    });
  }

  @override
  void initState() {
    super.initState();
    _streamController=StreamController();
    _stream=_streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title) ,
        bottom: PreferredSize(preferredSize: Size.fromHeight(48.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child:Container(
                  margin: const EdgeInsets.only(left: 12.0,bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0)
                  ),
                  child: TextFormField(
                    onChanged: (String text){
                      if(_timer?.isActive??false) _timer.cancel();
                      _timer=Timer(const Duration(microseconds: 1500),()
                      {
                        _search();
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a word",
                      contentPadding:  const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,


                    ),
                  ),
                ),
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: (){
                _search();
              },
            )
          ],
        ),),
      ),
      body:Container(
        margin: const EdgeInsets.all(8.0) ,
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx,AsyncSnapshot snapshot){
            if(snapshot.data==null||_controller.text.length==0)
            {
              return Center(
              
              );
            }
            if(snapshot.data=="waiting")
              {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            return ListView.builder(
              itemCount: snapshot.data["definitions"].length,
              itemBuilder: (BuildContext context,int index){
                return ListBody(
                  children: <Widget>[
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]["image_url"]==null? null:CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
                        ),
                        title: Text(_controller.text.trim()+"("+snapshot.data["definitions"][index]["type"]+")"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.data["definitions"][index]["definition"]),
                    ),

                  ],
                );
              },
            );
          },
        ),
      )

    );
  }
}
