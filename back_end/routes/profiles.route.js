const express = require("express");
const UserProfile = require("../models/profile.model"); // Adjust the path as necessary
const multer = require("multer");
const path = require("path"); // Import path module for file extension handling
const fs = require("fs");
const router = express.Router();

// Ensure the uploads directory exists
const uploadDir = "./uploads";
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir);
}

// Set up multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    cb(null, req.decoded.username + path.extname(file.originalname)); // Include the original file extension
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 6, // 6MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype === "image/jpeg" || file.mimetype === "image/png") {
      cb(null, true);
    } else {
      cb(null, false);
    }
  },
});

// Route to create or update user profile
router.post('/updateUserProfile', upload.single('img'), async (req, res) => {
  const { username, name, profession, DOB, titleline, about } = req.body;

  try {
    // Check if the user profile exists
    let userProfile = await UserProfile.findOne({ username });

    const avatar = req.file ? req.file.path : null; // Get avatar path if available

    if (userProfile) {
      // Update existing profile
      userProfile.name = name || userProfile.name;
      userProfile.profession = profession || userProfile.profession;
      userProfile.DOB = DOB || userProfile.DOB;
      userProfile.titleline = titleline || userProfile.titleline;
      userProfile.about = about || userProfile.about;
      userProfile.img = avatar || userProfile.img; // Update image if provided

      await userProfile.save(); // Save updated profile
      return res.status(200).json({ message: 'User profile updated successfully!', userProfile });
    } else {
      // Create new profile
      userProfile = new UserProfile({
        username,
        name,
        profession,
        DOB,
        titleline,
        about,
        img: avatar, // Include avatar if provided
      });

      await userProfile.save(); // Save new profile
      return res.status(201).json({ message: 'User profile created successfully!', userProfile });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Failed to update or create user profile', error: error.message });
  }
});

// Route to get user profile
router.get('/getUserProfile', async (req, res) => {
  const { username } = req.query; // Get username from query parameters

  try {
    // Find the user profile by username
    const userProfile = await UserProfile.findOne({ username });

    if (userProfile) {
      return res.status(200).json(userProfile);
    } else {
      return res.status(404).json({ message: 'User profile not found' });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch user profile', error: error.message });
  }
});

// Route to get user avatar
router.get('/getUserAvatar', async (req, res) => {
  const { username } = req.query; // Get username from query parameters

  if (!username) {
    return res.status(400).json({ message: 'Username is required' });
  }

  try {
    // Find the user profile by username
    const userProfile = await UserProfile.findOne({ username });

    if (userProfile && userProfile.img) {
      return res.status(200).json({ avatar: userProfile.img });
    } else {
      return res.status(404).json({ message: 'User profile or avatar not found' });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Failed to fetch user avatar', error: error.message });
  }
});

module.exports = router;
