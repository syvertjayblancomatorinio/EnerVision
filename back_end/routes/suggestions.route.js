const express = require('express');
const router = express.Router();
const Suggestion = require('../models/suggestions.model');
const Post = require('../models/posts.model');

router.post('/addSuggestions', async (req, res) => {
  try {
    const { postId, suggestionData } = req.body;

    const newSuggestion = new Suggestion({
      ...suggestionData,
      postId: postId
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




// Get all posts of a user
router.get('/suggestions/:suggestionId', async (req, res) => {
  try {
  } catch (err) {
  }
})

// Get a specific posts of a user
router.get('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
  } catch (err) {
  }
})


// Delete a specific posts of a user
router.delete('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
  } catch (err) {
  }
})
// Update a specific posts of a user
router.put('/suggestions/:userId/:suggestionId', async (req, res) => {
})

// Update a specific posts of a user (with partial update)
router.patch('/suggestions/:userId/:suggestionId', async (req, res) => {
  try {
  } catch (err) {
  }
})

// Delete all posts of a user
router.delete('/suggestions/:suggestionId', async (req, res) => {
  try {
  } catch (err) {
  }
})
module.exports = router;