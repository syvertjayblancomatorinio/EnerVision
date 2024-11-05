const express = require('express');
const router = express.Router();
const Suggestion = require('../models/suggestions.model');
const Post = require('../models/posts.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
// Add a new suggestion to a post
router.post('/addSuggestions/:postId', async (req, res) => {
  try {
    const { postId } = req.params; // Get postId from URL parameters
    const { suggestionData, userId } = req.body; // Extract suggestionData and userId from request body

    if (!userId) {
      return res.status(400).json({ message: 'User ID is required' });
    }

    const newSuggestion = new Suggestion({
      ...suggestionData,
      postId: postId,
      userId: userId,
    });

    await newSuggestion.save(); // Save the new suggestion
//    const username = user.username;
    const post = await Post.findById(postId); // Find the post by ID
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    post.suggestions.push(newSuggestion._id); // Add the suggestion to the post's suggestions array
    await post.save(); // Save the updated post

    res.status(201).json({ message: 'Suggestion added to Post',newSuggestion });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Retrieve all suggestions for a specific post
router.get('/getAllPostsSuggestions/:postId', async (req, res) => {
  try {
    // Populate suggestions and their associated usernames
    const post = await Post.findById(req.params.postId)
      .populate({
        path: 'suggestions',
        populate: { path: 'userId', select: 'username' } // Fetches the username from the user
      });

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Modify suggestions to include only relevant suggestion details and the username
    const suggestionsWithUsernames = post.suggestions.map(suggestion => ({
      ...suggestion.toObject(), // Convert to plain object to manipulate data
      username: suggestion.userId.username // Add the username from populated data
    }));

    res.status(200).json(suggestionsWithUsernames);
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

    res.status(200).json({ message: 'Suggestion updated successfully',suggestion });
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
