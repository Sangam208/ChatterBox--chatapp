const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const authRouter = require('./routes/auth');
require('dotenv').config();

const PORT = process.env.PORT;
const DB = process.env.DB_URL;

const app = express();
const server = http.createServer(app);
const io = require('socket.io')(server, {
    cors: { origin: "*" }
});
app.use(cors());
app.use(express.json());
app.use(authRouter);

mongoose.connect(DB).then(() => {
    console.log('Connected to DB');
}).catch((err) => {
    console.log(err);
});

io.on('connection', (socket) => {
    socket.on('join', ({ senderId, receiverId }) => {
        const room = [senderId, receiverId].sort().join("_");
        socket.join(room);
        console.log('Joined Room');
        io.to(room).emit('user_joined', {
            message: "A user has joined the room"
        });
    });

    socket.on('message', (message) => {
        const room = [message.senderId, message.receiverId].sort().join("_");
        io.to(room).emit('changes', {
            senderId: message.senderId,
            receiverId: message.receiverId,
            message: message.message,
        });
    });
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Connected at port ${PORT}`);
});