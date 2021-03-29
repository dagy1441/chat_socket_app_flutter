import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  ChatPage({Key key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // SocketIO socketIO;
  // List<String> messages;
  List<String> messages = [];

  String _user = "";

  double height, width;
  TextEditingController textController;
  ScrollController scrollController;

  IO.Socket socket;

  @override
  void initState() {
    print(" the user " + _user);
    //Initializing the message list
    //messages = List<String>();
    //Initializing the TextEditingController and ScrollController
    textController = TextEditingController();
    scrollController = ScrollController();
    socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            //.setExtraHeaders({'foo': 'bar'}) // optional
            .build());

    // socket = IO.io('http://10.0.2.2:3000', <String, dynamic>{
    //   'transports': ['websocket'],
    // });

    //Creating the socket with flutter socket.io.client

    socket.on('greeting', (data) {
      Map<String, dynamic> d = data;
      setState(() {
        _user += d['user'];
      });
    });

    socket.on('connection', (_) {
      print('connect ');
      socket.emit('msg', 'text');
    });

    socket.on('disconnect', (_) => print('disconnect'));

    socket.on('msg', (data) {
      print("Init data: $data");
      Map<String, dynamic> d = data;
      setState(() {
        // String pesan = d['user'] + ":" + d['msg'];
        // print(pesan);
        messages.add(d['msg']);
      });
    });

    socket.connect();

    //Creating the socket with flutter socket.io
    // socketIO = SocketIOManager().createSocketIO(
    //   '172.31.240.102:3000',
    //   '/server/',
    // );
    // //Call init before doing anything with socket
    // socketIO.init();

    // //Subscribe to an event to listen to
    // socketIO.subscribe('receive_message', (jsonData) {
    //   //Convert the JSON data received into a Map
    //   Map<String, dynamic> data = json.decode(jsonData);
    //   this.setState(() => messages.add(data['message']));
    //   scrollController.animateTo(
    //     scrollController.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 600),
    //     curve: Curves.ease,
    //   );
    // });

    // //Connect to the socket
    // socketIO.connect();
    super.initState();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  void _sendMessage(String message) {
    print("Send Message  $message");
    socket.emit("msg", {'msg': message, 'type': "text"});
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          messages[index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: height * 0.8,
      width: width,
      child: ListView.builder(
        controller: scrollController,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () {
        //Check if the textfield has text or not
        String msg = textController.text;
        if (msg.isNotEmpty || msg.trim().length > 0) {
          _sendMessage(msg);
          //Send the message as JSON data to send_message event
          // socketIO.sendMessage(
          //     'send_message', json.encode({'message': textController.text}));

          //Add the message to the list
          this.setState(() => messages.add(textController.text));
          textController.text = '';

          //Scrolldown the list to show the latest message
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: height * 0.1,
      width: width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: height * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }
}
