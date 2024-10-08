const express = require('express');
const router = express.Router();
const MonthlyConsumption = require('../models/monthly_consumption.model'); // Import model
const Appliance = require('../models/appliances.model'); // Import appliance model
const User = require('../models/user.model'); // Import user model
const mongoose = require('mongoose');
const asyncHandler = require('../centralized_codes/authMiddleware');



router.post('/saveMonthlyData', asyncHandler(async (req, res) => {
    const { userId, year, month, monthlyConsumption, monthlyKwhConsumption } = req.body;

    if (!userId || !year || month === undefined || !monthlyConsumption) { // Check for month being undefined
        return res.status(400).json({ error: 'All fields are required: userId, year, month, and monthlyConsumption' });
    }

    try {
        const existingData = await MonthlyConsumption.findOne({ userId, year, month });

        if (existingData) {
            existingData.totalMonthlyConsumption = monthlyConsumption;
            existingData.totalMonthlyKwhConsumption = monthlyKwhConsumption;
            await existingData.save();
            return res.status(200).json({ message: 'Monthly consumption data updated successfully' });
        } else {
            const newMonthlyData = new MonthlyConsumption({
                userId,
                year,
                month,  // Ensure this is a number
                totalMonthlyConsumption: monthlyConsumption,
                totalMonthlyKwhConsumption: monthlyKwhConsumption
            });
            await newMonthlyData.save();
            return res.status(201).json({ message: 'Monthly consumption data saved successfully' });
        }
    } catch (error) {
        console.error('Error saving or updating monthly data:', error);
        return res.status(500).json({ error: 'Server error while saving or updating monthly data' });
    }
}));


router.post('/save-consumption', async (req, res) => {
    const { userId } = req.body;

    const currentDate = new Date();
    const day = currentDate.getDate();
    const month = currentDate.getMonth() + 1;
    const year = currentDate.getFullYear();

    try {
        const appliances = await Appliance.find({ userId });

        if (!appliances || appliances.length === 0) {
            return res.status(404).json({ message: 'No appliances found for this user' });
        }

        const user = await User.findById(userId);
        if (!user || !user.kwhRate) {
            return res.status(404).json({ message: 'User or kWh rate not found' });
        }

        const kwhRate = user.kwhRate;

        // Initialize totals
        let totalMonthlyWattage = 0;
        let totalMonthlyCost = 0;

        // Save consumption data
        const consumptionPromises = appliances.map(async (appliance) => {
            const dailyWattage = (appliance.wattage / 1000) * appliance.usagePattern;
            const dailyCost = dailyWattage * kwhRate;
            const monthlyWattage = appliance.monthlyUsagePattern;
            const monthlyCost = monthlyWattage * kwhRate;

            totalMonthlyWattage += monthlyWattage;
            totalMonthlyCost += monthlyCost;

            return calculateAndSaveConsumption(
                userId,
                appliance._id,
                day,
                month,
                year,
                dailyWattage,
                dailyCost,
                monthlyWattage,
                monthlyCost
            );
        });

        await Promise.all(consumptionPromises);

        res.status(201).json({
            message: 'Daily and monthly consumption saved',
            totalMonthlyWattage,
            totalMonthlyCost
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

const calculateAndSaveConsumption = async (userId, applianceId, day, month, year, dailyWattage, dailyCost, monthlyWattage, monthlyCost) => {
    const newConsumption = new MonthlyConsumption({
        userId,
        applianceId,
        day,
        month,
        year,
        dailyWattage,
        dailyCost,
        monthlyWattage,
        monthlyCost
    });
    await newConsumption.save();
};


router.get('/get-daily-consumption/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    // Fetch consumption data for the user
    const consumption = await MonthlyConsumption.findOne({ userId });

    // Check if consumption records exist
    if (!consumption) {
      return res.status(404).json({ message: 'No consumption records found for this user' });
    }

    // Assuming dailyCost is an array of daily consumption data
    res.status(200).json({
      message: 'Daily consumption records found',
      dailyCost: consumption.dailyCost, // Daily consumption data for each day
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});


router.get('/monthly-consumption/:userId', async (req, res) => {
    const { userId } = req.params;
    const { month, year } = req.query;

    try {
        const monthlyConsumptions = await MonthlyConsumption.find({
            userId,
            month,
            year
        });

        if (!monthlyConsumptions || monthlyConsumptions.length === 0) {
            return res.status(404).json({ message: 'No consumption records found for this user' });
        }

        let totalWattage = 0;
        let totalCost = 0;
        monthlyConsumptions.forEach(consumption => {
            totalWattage += consumption.monthlyWattage;
            totalCost += consumption.monthlyCost;
        });

        res.status(200).json({
            message: 'Monthly consumption retrieved successfully',
            totalWattage,
            totalCost,
            monthlyConsumptions
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});





module.exports = router;
