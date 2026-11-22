const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
require('dotenv').config({ path: path.resolve(__dirname, '.env') });
const authRouter = require('./routes/auth');

const PORT = process.env.PORT;
const DB = process.env.DB_URL;
const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) throw new Error('JWT_SECRET must be set in server/.env');
if (!DB) throw new Error('DB_URL must be set in server/.env');

const app = express();
const server = http.createServer(app);
const io = require('socket.io')(server, { cors: { origin: '*' } });
app.use(cors());
app.use(express.json());
app.use(authRouter);

mongoose.connect(DB).then(() => {
    console.log('Connected to DB');
}).catch((err) => {
    console.log(err);
});

const jwt = require('jsonwebtoken');
const User = require('./models/user_model');

io.use((socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error('Authentication required'));
    try {
        const verified = jwt.verify(token, JWT_SECRET);
        socket.data.userId = String(verified.id);
        next();
    } catch (_) {
        next(new Error('Invalid authentication token'));
    }
});

const roomFor = (firstUserId, secondUserId) =>
    [String(firstUserId), String(secondUserId)].sort().join('_');

io.on('connection', (socket) => {
    socket.on('join', async ({ senderId, receiverId } = {}) => {
        if (String(senderId) !== socket.data.userId || !receiverId ||
            String(receiverId) === socket.data.userId) return;
        if (!(await User.exists({ _id: receiverId }))) return;
        const room = roomFor(senderId, receiverId);
        await socket.join(room);
    });

    socket.on('message', async (message = {}) => {
        const { senderId, receiverId, message: text } = message;
        if (String(senderId) !== socket.data.userId || !receiverId ||
            String(receiverId) === socket.data.userId ||
            typeof text !== 'string' || !text.trim()) return;
        if (!(await User.exists({ _id: receiverId }))) return;
        const room = roomFor(senderId, receiverId);
        if (!socket.rooms.has(room)) return;
        io.to(room).emit('changes', {
            senderId: socket.data.userId,
            receiverId: String(receiverId),
            message: text.trim(),
        });
    });
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Connected at port ${PORT}`);
});
