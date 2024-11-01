const express = require('express');
const router = express.Router();
const Chat = require('../models/chats.model');
const User = require('../models/user.model');



// Save a new chat message
router.post('/chats', async (req, res) => {
  const { user, message } = req.body;

  if (!user || !message) {
    return res.status(400).json({ message: 'User ID and message are required' });
  }

  try {
    let chatMessage = await Chat.findOne({ 'messages.userId': user });

    if (!chatMessage) {
      chatMessage = new Chat({
        messages: [{ userId: user, sender: user, message }],
        adminReplies: [],
      });
    } else {
      chatMessage.messages.push({ userId: user, sender: user, message });
    }

    await chatMessage.save();
    res.status(201).json(chatMessage);
  } catch (err) {
    console.error('Error saving message:', err);
    res.status(500).json({ message: 'Error saving message', error: err.message });
  }
});

// Fetch all chat messages
router.get('/chats', async (req, res) => {
  try {
    const chats = await Chat.find();
    res.json(chats);
  } catch (err) {
    res.status(500).json({ message: 'Server Error' });
  }
});



// Send an admin reply
router.post('/:userId/reply', async (req, res) => {
  const userId = req.params.userId;
  const { message } = req.body;

  if (!message || !message.trim()) {
    return res.status(400).json({ error: 'Message content is required' });
  }

  try {
    const chat = await Chat.findOne({ 'messages.userId': userId });
    if (!chat) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    chat.adminReplies.push({
      userId: 'admin-id',
      message: message,
      timestamp: new Date()
    });

    await chat.save();
    res.status(200).json({ message: 'Admin reply sent successfully' });
  } catch (error) {
    console.error('Error sending admin reply:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
