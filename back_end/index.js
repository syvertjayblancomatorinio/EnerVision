const express = require('express');
const app = express();
const profileRoutes = require('./routes/profile');
const port = process.env.PORT || 8080;
const cors = require('cors');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const MonthlyConsumption = require('./models/monthly_consumption.model'); // Import model
const cron = require('node-cron');
const winston = require('winston');

const User = require('./models/user.model'); // Adjust the path as needed
const Appliance = require('./models/appliances.model');

// Cron job to save monthly consumption on the last day of each month
cron.schedule('0 0 1 * *', async () => {
    const users = await User.find(); // Get all users
    for (const user of users) {
        const appliances = await Appliance.find({ userId: user._id });

        // Debugging: Log the appliances and their monthly costs
        console.log('Appliances for user:', user._id, appliances);

        const totalMonthlyCost = appliances.reduce((total, appliance) => {
            return total + (appliance.monthlyCost || 0);
        }, 0);

        // Debugging: Log the total monthly cost
        console.log('Total Monthly Cost for user:', user._id, totalMonthlyCost);

        const month = new Date().getMonth() + 1; // Get the current month (1-12)
        const year = new Date().getFullYear(); // Get the current year

        const monthlyConsumption = new MonthlyConsumption({
            userId: user._id,
            month,
            year,
            totalMonthlyConsumption: totalMonthlyCost
        });

        // Debugging: Log before saving to the database
        console.log('Saving Monthly Consumption:', monthlyConsumption);

        await monthlyConsumption.save(); // Save to database
    }
});



// Connect to MongoDB with error handling
mongoose.connect(
  "mongodb+srv://22104647:J%40mes2004@enervision-main.elxae.mongodb.net/enervision",
//  { useNewUrlParser: true, useUnifiedTopology: true }
).then(() => {
  console.log('Connected to MongoDB');
}).catch((error) => {
  console.error('MongoDB connection error:', error);
});

// Middleware
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.json()); // Move this before your route handlers

// Static file serving
app.use('/uploads', express.static('uploads'));
app.use('/images', express.static('C:/Users/SyvertJayMartorinio/OneDrive - Geidi/Desktop/auth/back_end/images'));

// Route definitions
app.use('/', require('./routes/user.route'));
app.use('/', require('./routes/appliances.route'));
app.use('/', require('./routes/post.route'));
app.use('/', require('./routes/suggestions.route'));
app.use('/', require('./routes/profile.route'));
app.use('/', require('./routes/profiles.route'));
app.use('/', require('./routes/compared_appliance.route'));
app.use('/', require('./routes/monthly_consumption.route'));

// Profile route usage
app.use('/api', profileRoutes); // Decide to use either this or the following
// app.use('/', profileRoutes); // Comment out if using '/api' path

// Upload avatar route (ensure Avatar model is defined and imported)
app.post('/uploadAvatar', async (req, res) => {
  const { userId, imageUrl } = req.body;

  try {
    const avatar = await Avatar.findOneAndUpdate(
      { userId: userId },
      { imageUrl: imageUrl },
      { new: true, upsert: true }
    );
    res.status(200).json(avatar);
  } catch (error) {
    res.status(500).json({ error: 'Failed to upload avatar' });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  winston.error(err.message, err); // Ensure winston is correctly configured
  res.status(500).send('Something failed');
});

// Start server
app.listen(port, () => {
  console.log('Server running on port ' + port);
});


/*
//mongoose.connect("mongodb://localhost:27017/enervision", {
////    useNewUrlParser: true,
////    useUnifiedTopology: true
//});
//const { MongoClient, ServerApiVersion } = require('mongodb');
//const uri = "mongodb+srv://22104647:J@mes2004@enervision-main.elxae.mongodb.net/?retryWrites=true&w=majority&appName=EnerVision-Main";
//// Create a MongoClient with a MongoClientOptions object to set the Stable API version
//const client = new MongoClient(uri, {
//  serverApi: {
//    version: ServerApiVersion.v1,
//    strict: true,
//    deprecationErrors: true,
//  }
//});
*/