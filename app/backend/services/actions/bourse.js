const axios = require('axios');
require("dotenv").config();
const User = require('../../models/users');
const send = require('../reactions/email')

const KEY = process.env.ALPHA_KEY

let intervalId;

async function bourse(symbol) {
    try {
        const response = await axios.get(`https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=${symbol}&interval=1min&apikey=${KEY}`);
        return response.data;
    } catch (error) {
        console.error('Erreur lors de la récupération de la bourse:', error.message);
        throw error;
    }
}

async function callBourse(email, symbol, interval, user) {
    const time = interval;

    intervalId = setInterval(async () => {
        console.log('Inside setInterval:', user.areas.norris);
        if (user.areas.bourse == false) {
            clearInterval(intervalId);
            console.log('Norris area switch to false. Area disable.');
        } else {
            const data = await bourse(symbol);
            const codeString = `
                Prix actuel de l'action ${symbol}: ${data['Time Series (1min)']['2024-01-12 19:59:00']['4. close']}
                Prix le plus élevé : ${data['Time Series (1min)']['2024-01-12 19:59:00']['2. high']}
                Prix le plus bas : ${data['Time Series (1min)']['2024-01-12 19:59:00']['3. low']}
                Volume : ${data['Time Series (1min)']['2024-01-12 19:59:00']['5. volume']}
                `;
            send.sendEmail(email, `Bourse de ${symbol}`, codeString)

            try {
                const updatedUser = await User.findById(user._id).populate("areas");
                // console.log('User updated:', updatedUser.areas);

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

module.exports = {
    callBourse: callBourse
}