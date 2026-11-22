const express = require('express');
const User = require('../models/user_model');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const auth = require('../middlewares/auth');
const Message = require('../models/message_model');

const authRouter = express.Router();
const googleAuthClient = new OAuth2Client();

// POST user data to DB
authRouter.post('/signup', async (request, response) => {
    const serverClientId = process.env.GOOGLE_SERVER_CLIENT_ID;
    if (!serverClientId) {
        return response.status(500).json({ error: 'Google sign-in is not configured on the server' });
    }

    const authorization = request.get('authorization') || '';
    const idToken = authorization.startsWith('Bearer ')
        ? authorization.slice('Bearer '.length).trim()
        : '';
    if (!idToken) {
        return response.status(401).json({ error: 'Google ID token is required' });
    }

    let googleUser;
    try {
        const ticket = await googleAuthClient.verifyIdToken({
            idToken,
            audience: serverClientId,
        });
        const payload = ticket.getPayload();
        if (!payload || !payload.sub || !payload.email || payload.email_verified !== true) {
            return response.status(401).json({ error: 'Google account could not be verified' });
        }
        googleUser = {
            name: payload.name || payload.email,
            email: payload.email,
            profilePic: payload.picture || '',
        };
    } catch (_) {
        return response.status(401).json({ error: 'Google ID token is invalid or has the wrong audience' });
    }

    try {
        let user = await User.findOne({ email: googleUser.email });
        if (!user) {
            user = new User(googleUser);
            user = await user.save();
        }
        const jwtSecret = process.env.JWT_SECRET;
        if (!jwtSecret) {
            return response.status(500).json({ error: 'JWT_SECRET is not configured on the server' });
        }
        const token = jwt.sign({ id: user._id }, jwtSecret, { expiresIn: '30d' });
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
        if (String(senderId) !== String(request.user)) {
            return response.status(403).json({ error: 'Cannot send as another user' });
        }
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
        if (String(request.user) !== String(senderId) &&
            String(request.user) !== String(receiverId)) {
            return response.status(403).json({ error: 'Not a participant in this conversation' });
        }
        const messages = await Message.find({ 
            $or:[
                { senderId, receiverId },
                { senderId: receiverId, receiverId: senderId },
            ]
        }).sort({ timeStamp: -1 });
        response.json({ messages });
    } catch (error) {
        response.status(500).json({ error: error.message });
    }
});

module.exports = authRouter;
