const express = require('express');
const User = require('../models/user.model');
const router = express.Router();

router.post('/delete-account/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findByIdAndUpdate(userId, { status: 'deleted' }, { new: true });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.status(200).json({ message: 'Account has been marked as deleted.' });
  } catch (err) {
    res.status(500).json({ message: 'Failed to delete account', error: err.message });
  }
});


module.exports = router;
