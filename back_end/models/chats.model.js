const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
    userId: { type: String, required: true },
    sender: { type: String, required: true },
    message: { type: String, required: true },
    timestamp: { type: Date, default: Date.now }
});

const chatSchema = new mongoose.Schema({
    messages: [messageSchema],
    adminReplies: [messageSchema]
}, { timestamps: true });


const Chat = mongoose.model('Chat', chatSchema);
module.exports = Chat;