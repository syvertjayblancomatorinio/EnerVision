const express = require('express');
const router = express.Router();
const Suggestion = require('../models/suggestions.model');
const Post = require('../models/posts.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
// Add a new suggestion to a post
router.post('/addSuggestions/:postId', async (req, res) => {
  try {
    const { postId } = req.params; // Get postId from URL parameters
    const { suggestionText, userId } = req.body; // Extract suggestionText and userId from request body

    // Validate required fields
    if (!userId || !suggestionText) {
      return res.status(400).json({ message: 'User ID and suggestion text are required' });
    }

    // Check if the post exists
    const post = await Post.findById(postId);
    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Create a new suggestion
    const newSuggestion = new Suggestion({
      suggestionText,
      postId,
      userId,
    });

    // Save the new suggestion
    await newSuggestion.save();

    // Add the suggestion to the post's suggestions array
    post.suggestions.push(newSuggestion._id);
    await post.save();

    // Respond with success
    res.status(201).json({ message: 'Suggestion added to Post', suggestion: newSuggestion });
  } catch (err) {
    console.error('Error adding suggestion:', err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Retrieve all suggestions for a specific post
router.get('/getAllPostsSuggestions/:postId', async (req, res) => {
  try {
    // Fetch the post and populate suggestions along with usernames from the user collection
    const post = await Post.findById(req.params.postId)
      .populate({
        path: 'suggestions',
        populate: { path: 'userId', select: 'username' } // Fetches the username from the user
      });

    if (!post) {
      return res.status(404).json({ message: 'Post not found' });
    }

    // Extract suggestions with only necessary details and usernames
    const suggestionsWithUsernames = post.suggestions.map(({ _id, suggestionText, userId }) => ({
      _id,
      suggestionText, // Include the suggestion text field
      username: userId?.username || 'Unknown' // Use 'Unknown' if userId is missing
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
