const express = require('express');
const User = require('../models/user.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
const Appliance = require('../models/appliances.model');
const router = express.Router();
const MonthlyConsumption = require('../models/monthly_consumption.model');

//router.post('/addApplianceToUser', asyncHandler(async (req, res) => {
//    const { userId, applianceData } = req.body;
//    const { applianceName } = applianceData;
//
//    // Trim the applianceName and check if it's empty
//    if (!applianceName || applianceName.trim() === "") {
//        return res.status(400).json({ message: 'Appliance name cannot be empty or just whitespace.' });
//    }
//
//    const existingAppliance = await Appliance.findOne({ applianceName: applianceName.trim(), userId });
//    if (existingAppliance) {
//        return res.status(400).json({ message: 'Appliance already exists for this user.' });
//    }
//
//    const newAppliance = new Appliance({ ...applianceData, applianceName: applianceName.trim(), userId });
//    await newAppliance.save();
//
//    const user = await User.findById(userId);
//    if (!user) return res.status(404).json({ message: 'User not found' });
//
//    user.appliances.push(newAppliance._id);
//    await user.save({ validateBeforeSave: false });
//
//    res.status(201).json({ message: 'Appliance added to user', appliance: newAppliance });
//}));
router.post('/addApplianceToUser', asyncHandler(async (req, res) => {
    const { userId, applianceData } = req.body;
    const { applianceName, applianceCategory, wattage, usagePatternPerDay, usagePatternPerWeek, createdAt } = applianceData;

    // Trim the applianceName and check if it's empty
    if (!applianceName || applianceName.trim() === "") {
        return res.status(400).json({ message: 'Appliance name cannot be empty or just whitespace.' });
    }

    // Validate other required fields
    if (!wattage || !usagePatternPerDay || !usagePatternPerWeek || !createdAt) {
        return res.status(400).json({ message: 'Wattage, daily usage pattern, weekly usage pattern, and creation date are required.' });
    }

    const existingAppliance = await Appliance.findOne({ applianceName: applianceName.trim(), userId });
    if (existingAppliance) {
        return res.status(400).json({ message: 'Appliance already exists for this user.' });
    }

    // Find the user to get the kWh rate
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const kwhRate = user.kwhRate; // Assume the user has a kWh rate

    // Parse the createdAt date
    const createdDate = new Date(createdAt);
    const currentYear = createdDate.getFullYear();
    const currentMonth = createdDate.getMonth(); // 0-indexed, so January is 0
    const totalDaysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate(); // Get total days in the month
    const startDay = createdDate.getDate();

    // Calculate the number of remaining days in the month
    const remainingDays = totalDaysInMonth - startDay + 1; // Days from createdAt to end of the month

    // Calculate full weeks and remaining days based on usage pattern (6 days per week)
    const fullWeeks = Math.floor(remainingDays / 7);
    const extraDays = remainingDays % 7;

    // Calculate the total hours the appliance is used for the remaining period in the month
    const totalDaysUsed = (fullWeeks * usagePatternPerWeek) + Math.min(extraDays, usagePatternPerWeek); // Total days the appliance is used
    const totalHours = totalDaysUsed * usagePatternPerDay; // Total hours used in the remaining period

    // Calculate Energy Consumption (kWh)
    const energyKwh = (wattage * totalHours) / 1000; // Convert wattage to kWh

    // Calculate Total Cost
    const monthlyCost = energyKwh * kwhRate; // Total cost based on energy consumed

    // Create new appliance with calculated monthly cost
    const newAppliance = new Appliance({
        applianceName: applianceName.trim(),
        applianceCategory,
        wattage,
        usagePatternPerDay,
        usagePatternPerWeek,
        createdAt: createdAt,
        monthlyCost, // Assign the calculated monthly cost
        userId
    });

    await newAppliance.save();
    user.appliances.push(newAppliance._id);
    await user.save({ validateBeforeSave: false });

    res.status(201).json({ message: 'Appliance added to user', appliance: newAppliance });
}));

router.get('/totalMonthlyCostOfUserAppliances/:userId', asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Check if the user exists
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Find all appliances for the user and sum their monthlyCost
    const appliances = await Appliance.find({ userId });

    // Calculate the total monthly cost
    const totalMonthlyCost = appliances.reduce((total, appliance) => {
        return total + (appliance.monthlyCost || 0); // Ensure to add only defined monthlyCost values
    }, 0);

    // Send the response with the total monthly cost
    res.status(200).json({ userId, totalMonthlyCost, appliances });
}));



router.get('/getAllUsersAppliances/:userId/appliances', asyncHandler (async (req, res) => {
      const user = await User.findById(req.params.userId).populate('appliances');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user.appliances);
    res.status(200).json({ message: 'Appliance are retrieved'});

}));

router.patch('/updateAppliance/:applianceId', asyncHandler (async (req, res) => {
    const applianceId = req.params.applianceId;
    const updates = req.body;

    const updatedAppliance = await Appliance.findByIdAndUpdate(applianceId, updates, { new : true});

    if (!updatedAppliance) {
    return res.status(404).json({message: 'Appliance not found'});
    }else{
    res.json({ message: 'Appliance updated successfully', appliance: updatedAppliance });
    }


}));


// Get the Daily&Monthly Consumption for cost,kwh and CO2 emissions
router.get('/totalDailyData/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;

        const appliances = await Appliance.find({ userId });
        if (!appliances || appliances.length === 0) {
            return res.status(404).json({ message: 'No appliances found for this user' });
        }

        const user = await User.findById(userId);
        if (!user || !user.kwhRate) {
            return res.status(404).json({ message: 'User or kWh rate not found' });
        }

        const kwhRate = user.kwhRate;
        const emissionFactor = 0.7; // kg CO2/kWh for Cebu or the Philippines

        let totalDailyConsumptionCost = 0;
        let totalDailyKwhConsumption = 0;
        let totalMonthlyConsumption = 0;
        let totalMonthlyKwhConsumption = 0;
        let totalDailyCO2Emissions = 0;
        let totalMonthlyCO2Emissions = 0;

        for (const appliance of appliances) {
            const kwh = appliance.wattage / 1000;
            const totalDailyKwh = kwh * appliance.usagePatternPerDay;

            // Calculate daily consumption cost
            totalDailyKwhConsumption += totalDailyKwh;
            totalDailyConsumptionCost += totalDailyKwh * kwhRate;

            // Calculate daily CO2 emissions
            const dailyCO2Emission = totalDailyKwh * emissionFactor;
            totalDailyCO2Emissions += dailyCO2Emission;

            // Calculate weekly consumption
            const hoursUsedPerWeek = appliance.usagePatternPerDay * appliance.usagePatternPerWeek;
            const kwhUsedPerWeek = hoursUsedPerWeek * kwh;
            const costPerWeek = kwhUsedPerWeek * kwhRate;

            // Assume 4.345 weeks in a month
            const monthlyConsumption = costPerWeek * 4.345;
            const monthlyKwhConsumption = kwhUsedPerWeek * 4.345;
            const monthlyCO2Emission = monthlyKwhConsumption * emissionFactor;

            // Add to total monthly consumption
            totalMonthlyConsumption += monthlyConsumption;
            totalMonthlyKwhConsumption += monthlyKwhConsumption;
            totalMonthlyCO2Emissions += monthlyCO2Emission;
        }

        res.json({
            message: 'Total daily and monthly data for all appliances',
            totalDailyConsumptionCost,
            totalDailyKwhConsumption,
            totalMonthlyConsumption,
            totalMonthlyKwhConsumption,
            totalDailyCO2Emissions,
            totalMonthlyCO2Emissions
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
});

// Get the Number of Appliances the User has
router.get('/getUsersCount/:userId/appliances', asyncHandler(async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).populate('appliances');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Send the retrieved appliances in the response
    return res.status(200).json({
      message: 'Appliances retrieved successfully',
      appliances: user.appliances,
    });
  } catch (error) {
    console.error(error); // Log the error to the console
    return res.status(500).json({ message: 'Server error' }); // Send server error response
  }
}));


router.get('/monthlyData/:userId', async (req, res) => {
      try {
          const userId = req.params.userId;
          const monthlyData = await MonthlyConsumption.find({ userId })
              .sort({ year: -1, month: -1 }); // Sort by year and month descending

        if (!monthlyData || monthlyData.length === 0) {
            return res.status(404).json({ message: 'No monthly data found for this user' });
        }

        res.json({
            message: 'Monthly consumption data retrieved successfully',
            data: monthlyData,
        });


    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
});

router.get('/monthlyDataNew/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        const { month, year } = req.query; // Use query parameters for month and year

        // Validate that both month and year are provided
        if (!month || !year) {
            return res.status(400).json({ message: 'Month and year are required' });
        }

        // Find the monthly data for the specified user, month, and year
        const monthlyData = await MonthlyConsumption.findOne({ userId, month, year });

        // If no data found, return 404
        if (!monthlyData) {
            return res.status(404).json({ message: 'No monthly data found for this user, month, and year' });
        }

        // Return the monthly data
        res.json({
            message: 'Monthly consumption data retrieved successfully',
            data: monthlyData,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
});




router.delete('/deleteAppliance/:applianceId', async (req, res) => {
  try {
    const applianceId = req.params.applianceId;

    // Find the appliance to delete
    const appliance = await Appliance.findByIdAndDelete(applianceId);
    if (!appliance) {
      return res.status(404).json({ message: 'Appliance not found' });
    }

    // Remove the appliance from the user's list
    await User.updateMany(
      { appliances: applianceId },
      { $pull: { appliances: applianceId } }
    );

    res.json({ message: 'Appliance deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error', error: err.message });
  }
});


module.exports = router;

/*
router.get('/totalConsumption/:applianceId', async (req, res) => {
    try {
        const applianceId = req.params.applianceId;

        // Find the appliance by ID
        const appliance = await Appliance.findById(applianceId);
        if (!appliance) {
            return res.status(404).json({ message: 'Appliance not found' });
        }

        // Assuming the user ID is stored in the appliance document
        const user = await User.findById(appliance.userId);
        if (!user || !user.kwhRate) {
            return res.status(404).json({ message: 'User or kWh rate not found' });
        }

        const kwhRate = user.kwhRate;

        // Calculate daily  consumption
        const kwh = appliance.wattage / 1000;
        totalDailyKwh = kwh * appliance.usagePatternPerDay;
        const totalDailyConsumption = totalDailyKwh * kwhRate;


        // get the monthly consumption
        const hoursUsedPerWeek = appliance.usagePatternPerDay * appliance.usagePatternPerWeek;
        const kwhUsedPerWeek = hoursUsedPerWeek * kwh;
        const  costPerWeek = kwhUsedPerWeek *  kwhRate;

        const monthlyConsumption = costPerWeek * 4.345;
        res.json({ message: 'Monthly consumption', monthlyConsumption });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
});

router.get('/totalMonthlyConsumption/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;

        // Find all appliances for the user
        const appliances = await Appliance.find({ userId });
        if (!appliances || appliances.length === 0) {
            return res.status(404).json({ message: 'No appliances found for this user' });
        }

        // Find the user to get the kWh rate
        const user = await User.findById(userId);
        if (!user || !user.kwhRate) {
            return res.status(404).json({ message: 'User or kWh rate not found' });
        }

        const kwhRate = user.kwhRate;

        let totalMonthlyConsumption = 0;

        for (const appliance of appliances) {
            // Calculate daily consumption
            const kwh = appliance.wattage / 1000;
            const totalDailyKwh = kwh * appliance.usagePatternPerDay;
            const dailyConsumption = totalDailyKwh * kwhRate;

            // Calculate weekly consumption
            const hoursUsedPerWeek = appliance.usagePatternPerDay * appliance.usagePatternPerWeek;
            const kwhUsedPerWeek = hoursUsedPerWeek * kwh;
            const costPerWeek = kwhUsedPerWeek * kwhRate;

            // Assume 4.345 weeks in a month
            const monthlyConsumption = costPerWeek * 4.345;

            // Add to total monthly consumption
            totalMonthlyConsumption += monthlyConsumption;
        }

        res.json({ message: 'Total monthly consumption for all appliances', totalMonthlyConsumption });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Internal server error', error: err.message });
    }
});
*/