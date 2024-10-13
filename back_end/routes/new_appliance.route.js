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
    const lastDay = new Date(year, month, 0); // Get the last day of the month

    for (let day = currentDate; day <= lastDay; day.setDate(day.getDate() + 1)) {
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

    const user = await User.findById(userId); // Ensure you have the user model imported and available
    if (!user) {
        return res.status(404).json({ error: 'User not found' });
    }

    const kwhRate = user.kwhRate || 0; // Default to 0 if kWh rate is not set
    const createdDate = createdAt ? new Date(createdAt) : new Date();

    const startDay = createdDate.getDate();
    const startMonth = createdDate.getMonth() + 1; // +1 to make it 1-based (January = 1)
    const startYear = createdDate.getFullYear();

    const daysUsed = getRemainingOccurrences(startYear, startMonth, startDay, selectedDays);
    const totalDaysUsed = Object.values(daysUsed).reduce((sum, count) => sum + count, 0);

    const totalHoursUsed = totalDaysUsed * usagePatternPerDay;
    const energyKwh = (wattage / 1000) * totalHoursUsed; // Convert wattage to kWh

    const monthlyCost = kwhRate * energyKwh;

    const newAppliance = new Appliance({
        applianceName: applianceName.trim(),
        applianceCategory,
        wattage,
        usagePatternPerDay,
        createdAt: createdDate,
        monthlyCost,
        userId
    });

    // Save the new appliance and update the user's appliance list
    await newAppliance.save();
    user.appliances.push(newAppliance._id);
    await user.save({ validateBeforeSave: false });

    res.status(201).json({ message: 'Appliance added to user', appliance: newAppliance });
}));

function getOccurrencesBetweenDates(year, month, startDate, endDate, selectedDays) {
    let dayOccurrences = {};
    selectedDays.forEach(day => {
        dayOccurrences[day] = 0;
    });

    let currentDate = new Date(year, month - 1, startDate);
    let lastDate = new Date(year, month - 1, endDate);

    // Loop from startDate to endDate
    for (let day = currentDate; day <= lastDate; day.setDate(day.getDate() + 1)) {
        const currentDayOfWeek = day.getDay();
        if (selectedDays.includes(currentDayOfWeek)) {
            dayOccurrences[currentDayOfWeek]++;
        }
    }

    return dayOccurrences;
}

router.post('/calculate-occurrences-update', (req, res) => {
    const { year, month, originalStartDay, updateDay, originalSelectedDays, newSelectedDays } = req.body;

    if (!year || !month || !originalStartDay || !updateDay || !originalSelectedDays || !newSelectedDays) {
        return res.status(400).send({ error: 'Missing required parameters' });
    }

    // 1. Calculate occurrences from original start date to the day before the update using original selected days
    const occurrencesBeforeUpdate = getOccurrencesBetweenDates(year, month, originalStartDay, updateDay - 1, originalSelectedDays);

    // 2. Calculate occurrences from update day to the end of the month using new selected days
    const lastDayOfMonth = new Date(year, month, 0).getDate();  // Get the last day of the month
    const occurrencesAfterUpdate = getOccurrencesBetweenDates(year, month, updateDay, lastDayOfMonth, newSelectedDays);

    // 3. Sum the occurrences from both periods
    const totalOccurrencesBeforeUpdate = Object.values(occurrencesBeforeUpdate).reduce((sum, count) => sum + count, 0);
    const totalOccurrencesAfterUpdate = Object.values(occurrencesAfterUpdate).reduce((sum, count) => sum + count, 0);

    const totalOccurrences = totalOccurrencesBeforeUpdate + totalOccurrencesAfterUpdate;

    // Respond with detailed occurrences and total count
    res.send({
        occurrencesBeforeUpdate,
        occurrencesAfterUpdate,
        totalOccurrencesBeforeUpdate,
        totalOccurrencesAfterUpdate,
        totalOccurrences
    });
});


module.exports = router;
