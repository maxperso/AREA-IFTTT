const axios = require('axios');
require('dotenv').config();
const User = require('../../models/users');
const emailService = require('../reactions/email');
const url = require('url');

let intervalId;

async function getLastCommit(repoUrl, accessToken, mail) {
    // const githubUrl = "https://github.com/maxperso/company_trombi";
    const parsedUrl = new URL(repoUrl);
    
    const owner = parsedUrl.pathname.split('/')[1];
    const repo = parsedUrl.pathname.split('/')[2];
    
    console.log('User:', owner);
    console.log('Repo:', repo);

    const url = `https://api.github.com/repos/${owner}/${repo}/commits`;

    try {
        const response = await axios.get(url, {
            headers: {
                'Authorization': `Bearer ${accessToken}`,
                'User-Agent': 'Nom-de-votre-application' // Remplacez par un nom approprié
            }
        });

        const lastCommit = response.data[0]; // Le premier élément est le dernier commit

        const commitMessage = lastCommit.commit.message;
        const authorName = lastCommit.commit.author.name;
        const commitDate = lastCommit.commit.author.date;

        const subject = "Dernier commit du repo:"
        const text = `Le dernier commit à été fait par ${authorName}\nLe ${commitDate}\nCommit: ${commitMessage}`
        console.log(text);
        emailService.sendEmail(mail, subject, text)
        return lastCommit;
    } catch (error) {
        console.error('Erreur lors de la requête à l\'API GitHub :', error.response ? error.response.data : error.message);
        throw error;
    }
}

async function checkcommitPeriodically(repoUrl , interval, accessToken, mail, user) {
    const time = interval;

    intervalId = setInterval(async () => {
        console.log('Inside setInterval:', user.areas.github);
        if (user.areas.github == false) {
            clearInterval(intervalId);
            console.log('Meteo area switch to false. Area disable.');
        } else {
            await getLastCommit(repoUrl, accessToken, mail)
    
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

module.exports = {
    checkcommitPeriodically: checkcommitPeriodically
    // getLastCommit: getLastCommit
}
