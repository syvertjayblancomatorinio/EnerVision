const express = require("express");
const multer = require("multer");
const User = require("../models/user.model");
const UserProfile = require("../models/profile.model");
const router = express.Router();
const path = require("path");
const fs = require('fs');

// Ensure the uploads directory exists
const uploadDir = path.join(__dirname, 'uploads'); // Using __dirname for portability
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true }); // Recursive option ensures parent directories are created
}

// Set up multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const username = req.decoded?.username || 'user'; // Fallback to 'user' if username is not available
    cb(null, `${username}-${Date.now()}${path.extname(file.originalname)}`); // Use timestamp for uniqueness
  },
});

// Configure multer
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 1024 * 1024 * 6, // 6MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedMimeTypes = ['image/jpeg', 'image/png'];
    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG and PNG are allowed.'), false);
    }
  },
});

// Error handling middleware
const errorHandler = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    return res.status(400).send({ error: err.message });
  } else if (err) {
    return res.status(400).send({ error: err.message });
  }
  next();
};


router.post("/signup", async (req, res) => {
  try {
    const existingUser = await User.findOne({ email: req.body.email });
    if (!existingUser) {
      const newUser = new User({
        email: req.body.email,
        password: req.body.password, // Password will be hashed by Mongoose middleware
        username: req.body.username,
        kwhRate: req.body.kwhRate
      });

//      await newUser.save({ validateBeforeSave: false });
      await newUser.save();

      console.log(newUser);
      res.status(201).json({ message: "User created successfully", user: newUser });
    } else {
      res.status(400).json({ message: "Email is not available" });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error", error: err.message });
  }
});


router.post("/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Compare the entered password with the stored hashed password
    const isMatch = await user.comparePassword(password);  // Assuming comparePassword is implemented
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Check if the user has a profile
    const profile = await UserProfile.findOne({ userId: user._id });

    // Successful login response
    return res.status(200).json({
      user: {
        _id: user._id,
        profiles: profile ? true : false,  // Send true if profile exists, false otherwise
      },
    });
  } catch (err) {
    console.error("Error during signin: ", err.message);
    res.status(500).json({ message: "Internal server error", error: err.message });
  }
});




router.post(
  "/updateProfile",
  upload.single("profilePicture"),
  async (req, res) => {
    console.log("Update profile endpoint hit");
    console.log("Received userId:", req.body.userId);

    try {
      const userId = req.body.userId;
      const { countryLine, cityLine, streetLine, mobileNumber, appliances } = req.body;
      let profilePicturePath;
      if (req.file) {
        profilePicturePath = path.relative(__dirname, req.file.path);
      }

      const updateUser = await User.findByIdAndUpdate(
        userId,
        {
          countryLine,
          cityLine,
          streetLine,
          mobileNumber,
          profilePicture: profilePicturePath,
//          appliances : [{}]
        },
        { new: true }
      );

      if (updateUser) {
        console.log("User Profile Updated", updateUser);
        res.json(updateUser);
      } else {
        console.log("User not found");
        res.status(404).json({ message: "User not found" });
      }
    } catch (error) {
      console.log("Error:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  }
);

router.patch('/updateKwh/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const updates = req.body;

    // Find and update the appliance
    const updateKWHRate = await User.findByIdAndUpdate(userId, updates, { new: true });

    if (!updateKWHRate) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User updated successfully', user: updateKWHRate });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});


router.get("/user/:userId", async (req, res) => {
  try {
    const user = await User.findById(req.params.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
  res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

router.get('/users/:userId', async (req, res) => {
  try {
    const { fields } = req.query;

    let user;
    if (fields === 'username') {
      user = await User.findById(req.params.userId).select('username');
    } else {
      user = await User.findById(req.params.userId);
    }

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(user);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});

router.delete('/users/:userId',async (req, res) => {
try {
const user = await User.findByIdAndDelete(req.params.userId);
if (!user) {
return res.status(404).json({message: "User not found"});
}
res.json({message : 'User deleted successfully'});
}catch(err) {
    console.error(err);
    res.status(500).json({message: 'Internal server error'})
        }
});

module.exports = router;


//
//router.post("/signup", async (req, res) => {
//  try {
//    const user = await User.findOne({ email: req.body.email });
//    if (user == null) {
//      const newUser = new User({
//        email: req.body.email,
//        password: req.body.password,
//        username: req.body.username,
//        kwhRate : req.body.kwhRate
//      });
//      await newUser.save();
//      console.log(newUser);
//      res.json(newUser);
//    } else {
//      res.json({ message: "Email is not available" });
//    }
//  } catch (err) {
//    console.log(err);
//    res.json(err);
//  }
//});
//
//router.post("/signin", async (req, res) => {
//  try {
//    const user = await User.findOne({
//      email: req.body.email,
//      password: req.body.password,
//    });
//    res.json(user);
//  } catch (err) {
//    console.log(err);
//    res.json(err);
//  }
//});