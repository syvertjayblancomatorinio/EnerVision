const express = require('express');
const User = require('../models/user.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
const Appliance = require('../models/appliances.model');
const router = express.Router();
const MonthlyConsumption = require('../models/monthly_consumption.model');

router.post('/addApplianceToUser', asyncHandler(async (req, res) => {
    const { userId, applianceData } = req.body;

    const { applianceName, applianceCategory, wattage, usagePatternPerDay, usagePatternPerWeek, createdAt } = applianceData;

    // Validate applianceName
    if (!applianceName || applianceName.trim() === "") {
        return res.status(400).json({ message: 'Appliance name cannot be empty or just whitespace.' });
    }

    // Check if appliance already exists for this user
    const existingAppliance = await Appliance.findOne({ applianceName: applianceName.trim(), userId });
    if (existingAppliance) {
        return res.status(400).json({ message: 'Appliance already exists for this user.' });
    }

    // Find the user to get the kWh rate
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const kwhRate = user.kwhRate; // Assuming the user has a kWh rate

    // Use the provided createdAt date from applianceData or default to the current date if not provided
    const createdDate = createdAt ? new Date(createdAt) : new Date();

    // Calculate remaining days in the current month
    const currentYear = createdDate.getFullYear();
    const currentMonth = createdDate.getMonth(); // 0-indexed, so January is 0
    const totalDaysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate();
    const startDay = createdDate.getDate();
    const remainingDays = totalDaysInMonth - startDay + 1; // Days from createdAt to the end of the month

    // Calculate full weeks and remaining days
    const fullWeeks = Math.floor(remainingDays / 7);
    const extraDays = remainingDays % 7;

    // Calculate total days used based on the usage pattern
    const totalDaysUsed = (fullWeeks * usagePatternPerWeek) + Math.min(extraDays, usagePatternPerWeek);

    // Calculate total hours of usage
    const totalHoursUsed = totalDaysUsed * usagePatternPerDay;

    // Calculate energy consumption (in kWh) and monthly cost
    const energyKwh = (wattage * totalHoursUsed) / 1000; // Convert wattage to kWh
    const monthlyCost = calculateCost(createdDate, new Date(currentYear, currentMonth + 1, 0), wattage, { usagePatternPerDay, usagePatternPerWeek }, kwhRate);

    // Create a new appliance entry
    const newAppliance = new Appliance({
        applianceName: applianceName.trim(),
        applianceCategory,
        wattage,
        usagePatternPerDay,
        usagePatternPerWeek,
        createdAt: createdDate, // Set the created date, allowing you to modify it for testing
        monthlyCost, // Store the calculated monthly cost
        userId
    });

    // Save the new appliance and update the user's appliance list
    await newAppliance.save();
    user.appliances.push(newAppliance._id); // Assuming user has an 'appliances' array to store appliance references
    await user.save({ validateBeforeSave: false });

    res.status(201).json({ message: 'Appliance added to user', appliance: newAppliance });
}));
router.patch('/updateAppliance/:applianceId', asyncHandler(async (req, res) => {
    const applianceId = req.params.applianceId;
    const updates = req.body;

    // Find the appliance to update
    const appliance = await Appliance.findById(applianceId);
    if (!appliance) {
        return res.status(404).json({ message: 'Appliance not found' });
    }

    // Get the user's kWh rate from the appliance's userId
    const user = await User.findById(appliance.userId);
    if (!user) {
        return res.status(404).json({ message: 'User not found' });
    }

    const kwhRate = user.kwhRate; // Use the correct property name
    if (typeof kwhRate === 'undefined') {
        return res.status(400).json({ message: 'User kWh rate is not defined' });
    }

    // Dates for cost calculation
    const updateDate = new Date(req.body.updatedAt || Date.now()); // Allow updatedAt to be set via request body
    const endOfMonth = new Date(updateDate.getFullYear(), updateDate.getMonth() + 1, 0); // Last day of the month

    // Calculate costs for the period before the update (old usage pattern)
    const oldUsagePattern = {
        usagePatternPerDay: appliance.usagePatternPerDay,
        usagePatternPerWeek: appliance.usagePatternPerWeek,
    };

    // Use the appliance's createdAt date as the start of the period before the update
    const previousUpdateDate = new Date(appliance.updatedAt || appliance.createdAt);

    // Ensure correct cost calculation before the update (from createdAt to updateDate)
    const costBeforeUpdate = calculateCost(
        new Date(appliance.createdAt),  // From the created date (e.g., Oct 1)
        updateDate,                     // To the update date (e.g., Oct 15)
        appliance.wattage,
        oldUsagePattern,
        kwhRate
    );

    // Calculate costs for the period after the update (new usage pattern)
    const newUsagePattern = {
        usagePatternPerDay: updates.usagePatternPerDay || appliance.usagePatternPerDay,
        usagePatternPerWeek: updates.usagePatternPerWeek || appliance.usagePatternPerWeek,
    };

    // Ensure correct cost calculation after the update (from updateDate to the end of the month)
    const costAfterUpdate = calculateCost(
        updateDate,                      // From the update date (e.g., Oct 15)
        endOfMonth,                      // To the end of the month (e.g., Oct 31)
        appliance.wattage,
        newUsagePattern,
        kwhRate
    );

    // Total monthly cost
    const totalMonthlyCost = costBeforeUpdate + costAfterUpdate;

    // Prepare the updated appliance data
    const updatedApplianceData = {
        ...updates,
        monthlyCost: totalMonthlyCost, // Update the monthly cost
        updatedAt: updateDate, // Use the date provided in the request or the current date
    };

    // Update the appliance
    const updatedAppliance = await Appliance.findByIdAndUpdate(applianceId, updatedApplianceData, { new: true });

    res.json({ message: 'Appliance updated successfully', appliance: updatedAppliance });
}));

// Function to calculate the cost based on start and end dates without rounding
function calculateCost(startDate, endDate, wattage, usagePattern, kwhRate) {
    // Calculate the exact number of days between the start and end dates
    const totalDays = (endDate - startDate) / (1000 * 60 * 60 * 24); // Get exact number of days
    const fullWeeks = Math.floor(totalDays / 7); // Full weeks within the period
    const extraDays = totalDays % 7; // Remaining days after full weeks

    // Calculate usage based on the weekly pattern
    const totalDaysOfUsage = (fullWeeks * usagePattern.usagePatternPerWeek) + Math.min(extraDays, usagePattern.usagePatternPerWeek);

    // Calculate total energy consumed (kWh) without rounding
    const energyConsumed = (wattage * usagePattern.usagePatternPerDay * totalDaysOfUsage) / 1000; // Convert to kWh

    // Calculate total cost
    return energyConsumed * kwhRate;
}

router.get('/totalMonthlyCostOfUserAppliances/:userId', asyncHandler(async (req, res) => {
    const { userId } = req.params;

    // Check if the user exists
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    // Find all appliances for the user and sum their monthlyCost
    const appliances = await Appliance.find({ userId });
    const emissionFactor = 0.7;
    let totalMonthlyKwhConsumption = 0;
    let totalMonthlyCO2Emissions = 0;

    const totalMonthlyCost = appliances.reduce((total, appliance) => {
        return total + (appliance.monthlyCost || 0);
    }, 0);
    // Calculate the monthly kWh consumption
     totalMonthlyKwhConsumption = totalMonthlyCost / user.kwhRate;

    const monthlyCO2Emission = totalMonthlyKwhConsumption * emissionFactor;

    totalMonthlyCO2Emissions += monthlyCO2Emission;

    // Send the response with the total monthly cost
    res.status(200).json({ userId, totalMonthlyCost, totalMonthlyKwhConsumption,totalMonthlyCO2Emissions ,appliances });
}));






router.get('/getAllUsersAppliances/:userId/appliances', asyncHandler (async (req, res) => {
      const user = await User.findById(req.params.userId).populate('appliances');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user.appliances);
    res.status(200).json({ message: 'Appliance are retrieved'});

}));




// Get the Daily&Monthly Consumption for cost,kwh and CO2 emissions
router.get('/totalDailyData/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;

        const appliances = await Appliance.find({ userId });
        if (!appliances || appliances.length === 0) {
            return res.status(200).json({
                message: 'No appliances found for this user',
                totalDailyConsumptionCost: (0).toFixed(2),
                totalDailyKwhConsumption: (0).toFixed(2),
                totalMonthlyConsumption: (0).toFixed(2),
                totalMonthlyKwhConsumption: (0).toFixed(2),
                totalDailyCO2Emissions: (0).toFixed(2),
                totalMonthlyCO2Emissions: (0).toFixed(2)
            });
        }

        const user = await User.findById(userId);
        if (!user || !user.kwhRate) {
            return res.status(404).json({ message: 'User or kWh rate not found' });
        }

        const kwhRate = user.kwhRate;
        const emissionFactor = 0.7; // kg CO2/kWh for Cebu or the Philippines

        // Initialize totals to 0, ensuring we don't get undefined values
        let totalDailyConsumptionCost = 0;
        let totalDailyKwhConsumption = 0;
        let totalMonthlyConsumption = 0;
        let totalMonthlyKwhConsumption = 0;
        let totalDailyCO2Emissions = 0;
        let totalMonthlyCO2Emissions = 0;

        for (const appliance of appliances) {
            const wattage = appliance.wattage || 0; // Default to 0 if no wattage
            const usagePatternPerDay = appliance.usagePatternPerDay || 0; // Default to 0 if undefined
            const usagePatternPerWeek = appliance.usagePatternPerWeek || 0; // Default to 0 if undefined
            const kwh = wattage / 1000;

            const totalDailyKwh = kwh * usagePatternPerDay;

            // Calculate daily consumption cost
            totalDailyKwhConsumption += totalDailyKwh;
            totalDailyConsumptionCost += totalDailyKwh * kwhRate;

            // Calculate daily CO2 emissions
            const dailyCO2Emission = totalDailyKwh * emissionFactor;
            totalDailyCO2Emissions += dailyCO2Emission;

            // Calculate weekly consumption
            const hoursUsedPerWeek = usagePatternPerDay * usagePatternPerWeek;
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

        // Convert all totals to two decimal places using toFixed(2)
        res.json({
            message: 'Total daily and monthly data for all appliances',
            totalDailyConsumptionCost: totalDailyConsumptionCost.toFixed(2),
            totalDailyKwhConsumption: totalDailyKwhConsumption.toFixed(2),
            totalMonthlyConsumption: totalMonthlyConsumption.toFixed(2),
            totalMonthlyKwhConsumption: totalMonthlyKwhConsumption.toFixed(2),
            totalDailyCO2Emissions: totalDailyCO2Emissions.toFixed(2),
            totalMonthlyCO2Emissions: totalMonthlyCO2Emissions.toFixed(2)
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
    return res.status(500).json({ message: 'Server error' });
  }
}));

router.get('/getNewUsersCount/:userId/appliances', asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const { month, year } = req.query;

  if (!month || !year) {
    return res.status(400).json({ message: 'Month and year are required' });
  }

  try {
    const appliances = await Appliance.find({
      userId,
      createdAt: {
        $gte: new Date(`${year}-${month}-01`),
        $lt: new Date(`${year}-${month}-01`).setMonth(new Date(`${year}-${month}-01`).getMonth() + 1)
      }
    });

    if (!appliances) {
      return res.status(404).json({ message: 'No appliances found for this month and year' });
    }

    // Respond with the count of appliances for the specified month and year
    return res.status(200).json({
      message: 'Appliances retrieved successfully',
      count: appliances.length,
      appliances
    });
  } catch (error) {
    console.error(error); // Log the error to the console
    return res.status(500).json({ message: 'Server error' });
  }
}));


router.get('/monthlyData/:userId', async (req, res) => {
      try {
          const userId = req.params.userId;
          const monthlyData = await MonthlyConsumption.find({ userId })
              .sort({ year: -1, month: -1 });

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