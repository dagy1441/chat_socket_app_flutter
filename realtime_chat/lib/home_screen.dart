import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> messages = [];

  // final IO.Socket socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
  //   'transports': ['websocket'],
  // });

  final IO.Socket socket =
      IO.io('http://172.31.240.102:3000', <String, dynamic>{
    'transports': ['websocket'],
  });

  final textEditingConntroller = TextEditingController();
  @override
  void initState() {
    socket.on('greeting', (data) {
      Map<String, dynamic> d = data;
      setState(() {
        // _users += d['user'];
      });
    });
    socket.on('disconnect', (_) => print('disconnect'));
    socket.on('msg', (data) {
      print("Ini data: $data");
      Map<String, dynamic> d = data;
      setState(() {
        // String pesan = d['user'] + ":" + d['msg'];
        // print(pesan);
        messages.add(d['msg']);
      });
    });
    socket.connect();
    super.initState();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  void _sendMessage(String message) {
    print("Message Envoyé : $message");
    socket.emit("msg", {'msg': message, 'type': "text"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Stack(
        children: [
          Align(
            child: Container(
              color: Colors.lightGreen,
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (BuildContext ctx, int i) {
                  if (messages.length > 0) {
                    return Align(child: Text(messages[i]));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.blue[50],
              height: MediaQuery.of(context).size.height * 0.1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingConntroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: "Type a Message Here",
                    suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {
                          String message = textEditingConntroller.text;
                          if (message.trim().length > 0) {
                            // _sendMessage(message);
                            socket
                                .emit('msg', {'msg': 'salut', 'type': 'text'});
                            textEditingConntroller.text = "";
                            textEditingConntroller.clear();
                          }
                        }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
