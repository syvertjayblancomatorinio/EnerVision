const express = require('express');
const User = require('../models/user.model');
const Posts = require('../models/posts.model');
const router = express.Router();
const asyncHandler = require('../centralized_codes/authMiddleware');

router.post('/addPost', async (req, res) => {
  try {
    const { userId, postData } = req.body;

    const newPost = new Posts({ ...postData, userId: userId });
    await newPost.save();

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.posts.push(newPost._id);
    await user.save();

    res.status(201).json({ message: 'Post added to user', post: newPost });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

// Get all posts of all users
router.get('/displayPosts', asyncHandler(async (req, res) => {
    const posts = await Posts.find();  // Ensure this variable is named 'posts'

    res.status(200).json({ message: 'Posts are retrieved', posts });  // Use 'posts' here as well
}));

// Get all posts of a user
router.get('/getAllPosts/:userId/posts', asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.userId).populate('posts');

    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    // Respond with the user's posts
    res.status(200).json({ message: 'Posts retrieved successfully', posts: user.posts });
}));

// Get a specific post of a user
router.get('/posts/:userId/:postId', async (req, res) => {
    try {
        const user = await User.findById(req.params.userId).populate('posts');

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        const post = user.posts.find(post => post._id.toString() === req.params.postId);

        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }
        res.status(200).json({ message: 'Post retrieved successfully', post });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});


// Delete a specific posts of a user
router.delete('/posts/:userId/:postId', async (req, res) => {
});
// Update a specific posts of a user
router.put('/posts/:userId/:postId', async (req, res) => {
});

// Update a specific posts of a user (with partial update)
router.patch('/posts/:userId/:postId', async (req, res) => {
});

// Delete all posts of a user
router.delete('/posts/:userId', async (req, res) => {
});
module.exports = router;
