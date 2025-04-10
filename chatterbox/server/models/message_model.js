const mongoose = require('mongoose');

const messageSchema = mongoose.Schema({
    message:{
        type: String,
        required: true,
        trim: true,
    },
    senderId:{
        type: String,
        required: true,
    },
    receiverId:{
        type: String,
        required: true,
    },
    timeStamp:{
        type: Date,
        required: true,
        default: Date.now,
    }
});

const Message = mongoose.model('Message', messageSchema);

module.exports = Message;