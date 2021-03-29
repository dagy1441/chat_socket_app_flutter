const app = require('express')()
const server = require('http').createServer(app)
const io = require('socket.io')(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
})

app.get('/', (req, res) => {
   res.send("Node Server is running. Yay!!")
})

app.use(function (req, res, next) {

  // Website you wish to allow to connect
  res.setHeader('Access-Control-Allow-Origin', '*');

  // Request methods you wish to allow
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

  // Request headers you wish to allow
  res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

  // Set to true if you need the website to include cookies in the requests sent
  // to the API (e.g. in case you use sessions)
  res.setHeader('Access-Control-Allow-Credentials', true);

  // Pass to next layer of middleware
  next();
});


// // logic socket
// io.on("connection", (userSocket) => {
//     userSocket.on("send_message", (data) => {
//         userSocket.broadcast.emit("receive_message", data)
//     })
// })

io.on("connection", (socket) => {
  
  console.log("Client Connecté : " + socket.id)
  socket.broadcast.emit("greeting", { msg: "Welcome, ", user: "user_" + socket.id });
  socket.emit("greeting", { msg: "Welcome, ", user: "user_" + socket.id });
  
  socket.on("msg", (data) => {
      console.log(data);
      socket.broadcast.emit("msg", data);
      socket.emit("msg", data);
  });

});

// io.on("msg", (data) =>  {
//   console.log(data);
// });

  //   io.on('connection', function (client) {

  //   console.log('client connect...', client.id);
  
  //   client.on('typing', function name(data) {
  //     console.log(data);
  //     io.emit('typing', data)
  //   })
  
  //   client.on('message', function name(data) {
  //     console.log(data);
  //     io.emit('message', data)
  //   })
  
  //   client.on('location', function name(data) {
  //     console.log(data);
  //     io.emit('location', data);
  //   })
  
  //   client.on('connect', function () {
  //       console.log('client connect...', client.id)
  //   })
  
  //   client.on('disconnect', function () {
  //     console.log('client disconnect...', client.id)
  //     // handleDisconnect()
  //   })
  
  //   client.on('error', function (err) {
  //     console.log('received error from client:', client.id)
  //     console.log(err)
  //   })
  // });

 
  
  var server_port = process.env.PORT || 3000;
  server.listen(server_port, function (err) {
    if (err) throw err
    console.log('Listening on port %d', server_port);
  }); 