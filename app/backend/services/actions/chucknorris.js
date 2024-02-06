const axios = require('axios');
const User = require('../../models/users');
const send = require('../reactions/email')

let intervalId;

async function noris(email) {
    try {
        const response = await axios.get('https://api.chucknorris.io/jokes/random');
        return response.data.value;
    } catch (error) {
        console.error('Erreur lors de la récupération de la Norris JOKE:', error.message);
        throw error;
    }
}

async function callNorris(email, interval, user) {
    const time = interval;

    intervalId = setInterval(async () => {
        console.log('Inside setInterval:', user.areas.norris);
        if (user.areas.norris == false) {
            clearInterval(intervalId);
            console.log('Norris area switch to false. Area disable.');
        } else {
            const joke = await noris(email);
            console.log(`Sending norris joke to ${email}`);
            send.sendEmail(email, "Chuck Norris Joke", joke)

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
    callNorris: callNorris
}