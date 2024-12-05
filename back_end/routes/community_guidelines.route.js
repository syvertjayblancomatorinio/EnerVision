const express = require('express');
const router = express.Router();
const User = require('../models/user.model'); // Adjust the path if needed

// Route to check if the user has accepted the guidelines
router.get('/community-guidelines/:userId', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json({ accepted: user.communityGuidelinesAccepted });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/community-guidelines/:userId', async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    user.communityGuidelinesAccepted = true; // Update the status
    await user.save();
    res.status(200).json({ message: 'Community guidelines accepted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
