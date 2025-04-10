const express = require('express');
const User = require('../models/user_model');
const jwt = require('jsonwebtoken');
const auth = require('../middlewares/auth');
const Message = require('../models/message_model');

const authRouter = express.Router();

// POST user data to DB
authRouter.post('/signup', async (request, response) => {
    try {
        const { name, email, profilePic } = request.body;
        let user = await User.findOne({ email });
        if (!user) {
            user = new User({
                name,
                email,
                profilePic
            });
            user = await user.save();
        }
        const token = jwt.sign({ id: user._id }, "passKey");
        response.json({ user, token });
    } catch (e) {
        response.status(500).json({ error: e.message });
    }
});

// GET user data from DB
authRouter.get('/', auth, async (request, response) => {
    try {
        const user = await User.findById(request.user);
        if (!user) return response.status(404).json({ msg: "User not found" });
        response.json({ user, token: request.token });
    } catch (e) {
        response.status(500).json({ error: e.message });
    }
});

// GET all users
authRouter.get('/users', auth, async (request, response) => {
    try {
        const users = await User.find({ _id: { $ne: request.user } });
        if (users.length === 0) return response.status(404).json({ msg: "No users as of now" });
        response.json({users, totalUsers: users.length});
    } catch (e) {
        response.status(500).json({ error: e.message });
    }
});

// store messages between two users
authRouter.post('/messages', auth, async (request, response) => {
    try {
        const { message, senderId, receiverId, timeStamp } = request.body;
        if (!senderId || !receiverId || !message) return response.status(400).json({ error: `Missing required fields` }); 
        const newMessage = new Message({
            message,
            senderId,
            receiverId,
            timeStamp
        });
        const savedMessage = await newMessage.save();
        response.json({ savedMessage });
    } catch (e) {
        response.status(500).json({ error: e.message });
    }
});

// fetch messages between two users
authRouter.get('/c/:senderId/:receiverId', auth, async (request, response) => {
    try {
        const { senderId, receiverId } = request.params;
        if(!senderId || !receiverId) return response.status(400).json({ error: `Missing id` });
        const messages = await Message.find({ 
            $or:[
                { senderId, receiverId },
                { senderId: receiverId, receiverId: senderId },
            ]
        }).sort({ timeStamp: -1 });
        response.json({ messages });
    } catch (error) {
        response.status(500).json({ error: e.message });
    }
});

module.exports = authRouter;