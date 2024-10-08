const cron = require('node-cron');
const Appliance = require('./models/Appliance');
const User = require('./models/User');
const MonthlyConsumption = require('./models/MonthlyConsumption');

// Function to calculate and save total monthly consumption for all users
async function saveMonthlyConsumption() {
    try {
        const users = await User.find();

        for (const user of users) {
            const appliances = await Appliance.find({ userId: user._id });
            if (!appliances || appliances.length === 0) {
                console.log(`No appliances found for user: ${user._id}`);
                continue;
            }

            const kwhRate = user.kwhRate;
            let totalMonthlyConsumption = 0;

            for (const appliance of appliances) {
                const kwh = appliance.wattage / 1000;
                const totalDailyKwh = kwh * appliance.usagePatternPerDay;
                const dailyConsumption = totalDailyKwh * kwhRate;

                const hoursUsedPerWeek = appliance.usagePatternPerDay * appliance.usagePatternPerWeek;
                const kwhUsedPerWeek = hoursUsedPerWeek * kwh;
                const costPerWeek = kwhUsedPerWeek * kwhRate;

                const monthlyConsumption = costPerWeek * 4.345;
                totalMonthlyConsumption += monthlyConsumption;
            }

            const currentMonth = new Date().toLocaleString('default', { month: 'long', year: 'numeric' });

            let monthlyConsumptionRecord = await MonthlyConsumption.findOne({ userId: user._id, month: currentMonth });

            if (monthlyConsumptionRecord) {
                monthlyConsumptionRecord.totalMonthlyConsumption = totalMonthlyConsumption;
            } else {
                monthlyConsumptionRecord = new MonthlyConsumption({
                    userId: user._id,
                    month: currentMonth,
                    totalMonthlyConsumption
                });
            }

            await monthlyConsumptionRecord.save();
            console.log(`Saved monthly consumption for user: ${user._id} for ${currentMonth}`);
        }
    } catch (err) {
        console.error('Error saving monthly consumption:', err);
    }
}

// Schedule the task to run on the 30th of every month at midnight
cron.schedule('0 0 30 * *', () => {
    console.log('Running monthly consumption save task');
    saveMonthlyConsumption();
});
