const axios = require('axios');
const emailService = require('../reactions/email');
const User = require('../../models/users');

let intervalId;

async function getPrice(coin) {
    try {
        const response = await axios.get(`https://api.coingecko.com/api/v3/simple/price?ids=${coin}&vs_currencies=usd`);
        return response.data.bitcoin.usd;
    } catch (error) {
        console.error(`Erreur lors de la récupération du prix du ${coin}:`, error.message);
        throw error;
    }
}

async function performReaction(price, limit, mail, value, coin) {
    try {
        console.log('value: ', value)
        if (value == 0 && price > limit) {
            console.log(`Le prix du ${coin} a dépassé ${limit} USD. Réaction en cours...`);
    
            subject = `Réaction à l\'action ${coin}`;
            textpart = `Détails de l'action ${coin} :\n\nLe prix fixé de ${limit} USD à été dépassé.\nLe prix est maintenant de ${price} USD`;
    
            const mailSent = emailService.sendEmail(mail, subject, textpart);
            if (mailSent) {
                clearInterval(intervalId);
            }
            return mailSent;
        }
        if (value == 1 && price < limit) {
            console.log(`Le prix du ${coin} a atteint ${limit} USD. Réaction en cours...`);
    
            subject = `Réaction à l\'action ${coin}`;
            textpart = `Détails de l'action ${coin} :\n\nLe prix fixé de ${limit} USD à été atteint.\nLe prix est maintenant de ${price} USD`;
    
            const mailSent = emailService.sendEmail(mail, subject, textpart);
            if (mailSent) {
                clearInterval(intervalId);
            }
            return mailSent;
        }
        if (value == 2) {
            console.log(`Le prix du ${coin} est de ${price} USD. Réaction en cours...`);
    
            subject = `Réaction à l\'action ${coin}`;
            textpart = `Détails de l'action ${coin} :\n\nLe prix est de ${price} USD.`;
    
            const mailSent = emailService.sendEmail(mail, subject, textpart);
            return mailSent;
        }
        console.log(`Le prix du ${coin} n'a pas atteint ${limit} USD. Aucune réaction nécessaire.`);
    } catch (error) {
        console.error('Erreur lors de la récupération de la crypto', error.message);
    }
    // 0  = positive trigger
    // 1  = negative trigger
}

// async function checkBitcoinPricePeriodically(mail, limit, interval, value, coin) {
//     const time = interval;

//     intervalId = setInterval(async () => {
//         await monitorBitcoinPrice(mail, limit, value, coin);
//     }, time * 1000);
// }

async function checkBitcoinPricePeriodically(mail, limit, interval, value, coin, user) {
    const time = interval;

    intervalId = setInterval(async () => {
        console.log('Inside setInterval:', user.areas.crypto);
        if (user.areas.crypto == false) {
            clearInterval(intervalId);
            console.log('Crypto area switch to false. Area disable.');
        } else {
            await monitorBitcoinPrice(mail, limit, value, coin);
    
            try {
                const updatedUser = await User.findById(user._id).populate("areas");

                if (updatedUser) {
                    user = updatedUser;
                } else {
                    console.error('User not found after update.');
                }
            } catch (error) {
                console.error('Error fetching updated user:', error);
            }
        }
    }, time * 1000);
}

async function monitorBitcoinPrice(mail, limit, value, coin) {
    try {
        const bitcoinPrice = await getPrice(coin);
        console.log(`Prix actuel du ${coin}:`, bitcoinPrice, 'USD');
        const mailSent = await performReaction(bitcoinPrice, limit, mail, value, coin);
        if (mailSent) {
            clearInterval(intervalId);
        }
    } catch (error) {
        console.error(`Erreur lors de la surveillance du prix du ${coin}:`, error.message);
    }
}

module.exports = {
    checkBitcoinPricePeriodically: checkBitcoinPricePeriodically,
};
