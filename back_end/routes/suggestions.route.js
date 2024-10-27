const express = require('express');
const router = express.Router();
const Suggestion = require('../models/suggestions.model');
const Post = require('../models/posts.model');
const asyncHandler = require('../centralized_codes/authMiddleware');

// Add a new suggestion to a post
router.post('/addSuggestions', async (req, res) => {
  try {
    const { postId, suggestionData, userId } = req.body;

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    const newSuggestion = new Suggestion({
      ...suggestionData,
      postId: postId,
      userId: userId,
    });

    await newSuggestion.save();

    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    post.suggestions.push(newSuggestion._id);
    await post.save();

    res.status(201).json({ message: 'Suggestion added to Post', suggestion: newSuggestion });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Retrieve all suggestions for a specific post
router.get('/getAllPostsSuggestions/:postId/suggestions', async (req, res) => {
  try {
    const post = await Post.findById(req.params.postId).populate('suggestions');
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }
    res.status(200).json(post.suggestions);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Update a specific suggestion of a user
router.put('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
    const { userId, suggestionId } = req.params;
    const updatedData = req.body;

    const suggestion = await Suggestion.findOneAndUpdate(
      { _id: suggestionId, userId: userId },
      updatedData,
      { new: true }
    );

    if (!suggestion) {
      return res.status(404).json({ message: 'Suggestion not found' });
    }

    res.status(200).json({ message: 'Suggestion updated successfully', suggestion });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Delete a specific suggestion of a user
router.delete('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
    const { userId, suggestionId } = req.params;

    const suggestion = await Suggestion.findOneAndDelete({ _id: suggestionId, userId: userId });

    if (!suggestion) {
      return res.status(404).json({ message: 'Suggestion not found' });
    }

    res.status(200).json({ message: 'Suggestion deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

module.exports = router;
