const express = require('express');
const User = require('../models/user.model');
const asyncHandler = require('../centralized_codes/authMiddleware');
const Appliance = require('../models/appliances.model');
const router = express.Router();
const MonthlyConsumption = require('../models/monthly_consumption.model');

// Function to calculate remaining occurrences of selected days in a month
function getRemainingOccurrences(year, month, startDay, selectedDays) {
    let dayOccurrences = {};
    selectedDays.forEach(day => {
        dayOccurrences[day] = 0;
    });

    let currentDate = new Date(year, month - 1, startDay);
    const lastDay = new Date(year, month, 0);

    for (let day = currentDate; day <= lastDay; day.setDate(day.getDate() + 1)) {
        const currentDayOfWeek = day.getDay();
        if (selectedDays.includes(currentDayOfWeek)) {
            dayOccurrences[currentDayOfWeek]++;
        }
    }
    return dayOccurrences;
}
function getOccurrencesBetweenDates(startDate, endDate, selectedDays) {
    let dayOccurrences = {};
    selectedDays.forEach(day => {
        dayOccurrences[day] = 0;
    });

    for (let day = new Date(startDate); day <= endDate; day.setDate(day.getDate() + 1)) {
        const currentDayOfWeek = day.getDay();
        if (selectedDays.includes(currentDayOfWeek)) {
            dayOccurrences[currentDayOfWeek]++;
        }
    }

    return dayOccurrences;
}


router.post('/addApplianceNewLogic', asyncHandler(async (req, res) => {
    const { userId, applianceData } = req.body;
    const { applianceName, applianceCategory, wattage, usagePatternPerDay, createdAt, selectedDays } = applianceData;

    // Validate input
    if (!userId || !applianceData || !applianceName || !applianceCategory || !wattage || !usagePatternPerDay || !selectedDays) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    // Ensure wattage and usage pattern are numbers
    if (typeof wattage !== 'number' || typeof usagePatternPerDay !== 'number') {
        return res.status(400).json({ error: 'Wattage and usage pattern must be numbers' });
    }

    // Ensure selectedDays is an array of numbers
    if (!Array.isArray(selectedDays) || !selectedDays.every(Number.isInteger)) {
        return res.status(400).json({ error: 'Selected days must be an array of integers' });
    }

    const user = await User.findById(userId);
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    const kwhRate = user.kwhRate || 0;
    const createdDate = createdAt ? new Date(createdAt) : new Date();

    const startDay = createdDate.getDate();
    const startMonth = createdDate.getMonth() + 1;
    const startYear = createdDate.getFullYear();

    const daysUsed = getRemainingOccurrences(startYear, startMonth, startDay, selectedDays);
    const totalDaysUsed = Object.values(daysUsed).reduce((sum, count) => sum + count, 0);

    const totalHoursUsed = totalDaysUsed * usagePatternPerDay;
    const energyKwh = (wattage / 1000) * totalHoursUsed;

    const monthlyCost = kwhRate * energyKwh;

    const newAppliance = new Appliance({
        applianceName: applianceName.trim(),
        applianceCategory,
        wattage,
        usagePatternPerDay,
        createdAt: createdDate,
        monthlyCost,
        userId,
        selectedDays // Store selected days as an array of integers
    });

    // Save the new appliance and update the user's appliance list
    await newAppliance.save();
    user.appliances.push(newAppliance._id);
    await user.save({ validateBeforeSave: false });

    res.status(201).json({ message: 'Appliance added to user', appliance: newAppliance });
}));

router.patch('/updateApplianceOccurrences/:applianceId', asyncHandler(async (req, res) => {
    const applianceId = req.params.applianceId;

    const { userId, updatedAt, updatedData } = req.body;
    const { wattage, usagePatternPerDay, selectedDays } = updatedData;

    // Validate input
    if (!userId || !applianceId || !updatedAt || !updatedData || !wattage || !usagePatternPerDay || !selectedDays) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    // Ensure wattage and usage pattern are numbers
    if (typeof wattage !== 'number' || typeof usagePatternPerDay !== 'number') {
        return res.status(400).json({ error: 'Wattage and usage pattern must be numbers' });
    }

    // Ensure selectedDays is an array of numbers
    if (!Array.isArray(selectedDays) || !selectedDays.every(Number.isInteger)) {
        return res.status(400).json({ error: 'Selected days must be an array of integers' });
    }

    const user = await User.findById(userId);
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    const appliance = await Appliance.findById(applianceId);
    if (!appliance) {
        return res.status(404).json({ error: 'Appliance not found' });
    }
   const currentMonth = new Date().getMonth();
   const currentYear = new Date().getFullYear();
   const applianceLastUpdatedMonth = new Date(appliance.updatedAt).getMonth();
   const applianceLastUpdatedYear = new Date(appliance.updatedAt).getFullYear();

   // Check if the appliance has already been updated this month
   if (applianceLastUpdatedMonth === currentMonth && applianceLastUpdatedYear === currentYear) {
       return res.status(400).json({ error: 'Appliance can only be updated once per month' });
   }

//   // Proceed with checking for concurrent modification
//   const applianceVersion = appliance.__v;
//   if (applianceVersion !== updatedData.__v) {
//       return res.status(409).json({ error: 'Concurrent modification detected' });
//   }


    const kwhRate = user.kwhRate || 0;
    const createdDate = appliance.createdAt;
    const updatedDate = new Date(updatedAt);

    // Ensure the updatedAt date is not before the createdAt date
    if (updatedDate < createdDate) {
        return res.status(400).json({ error: 'Updated date cannot be before the created date' });
    }

    // --- First Calculation: From createdAt to day before updatedAt using old data ---
    const oldEndDate = new Date(updatedDate);
    oldEndDate.setDate(updatedDate.getDate() - 1);  // Exclude the updatedAt day

    const oldDaysUsed = getOccurrencesBetweenDates(createdDate, oldEndDate, appliance.selectedDays);
    const oldTotalDaysUsed = Object.values(oldDaysUsed).reduce((sum, count) => sum + count, 0);
    const oldTotalHoursUsed = oldTotalDaysUsed * appliance.usagePatternPerDay;
    const oldEnergyKwh = (appliance.wattage / 1000) * oldTotalHoursUsed;

    // --- Second Calculation: From updatedAt to end of the month using new data ---
    const updatedEndOfMonth = new Date(updatedDate.getFullYear(), updatedDate.getMonth() + 1, 0);
    const newDaysUsed = getOccurrencesBetweenDates(updatedDate, updatedEndOfMonth, selectedDays);
    const newTotalDaysUsed = Object.values(newDaysUsed).reduce((sum, count) => sum + count, 0);
    const newTotalHoursUsed = newTotalDaysUsed * usagePatternPerDay;
    const newEnergyKwh = (wattage / 1000) * newTotalHoursUsed;

    // Sum both energy consumptions
    const totalEnergyKwh = oldEnergyKwh + newEnergyKwh;

    // Calculate the final monthly cost
    const updatedMonthlyCost = kwhRate * totalEnergyKwh;

    // Update the appliance data with the new information
    appliance.wattage = wattage;
    appliance.usagePatternPerDay = usagePatternPerDay;
    appliance.selectedDays = selectedDays;
    appliance.updatedAt = updatedDate;
    appliance.monthlyCost = updatedMonthlyCost;

    await appliance.save();

    res.status(200).json({ message: 'Appliance updated successfully',newEnergyKwh, oldEnergyKwh ,newTotalDaysUsed, appliance});

}));

module.exports = router;
