const axios = require('axios');
const fs = require('fs');
const path = require('path');
const mailjet = require('node-mailjet');
require("dotenv").config();

async function getAPOD(apiKey) {
    const apiUrl = `https://api.nasa.gov/planetary/apod?api_key=${apiKey}`;
    try {
        const response = await axios.get(apiUrl);
        return response.data;
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'APOD', error.message);
        throw error;
    }
}

async function afficherImageEtEnvoyerEmail(apodData, email) {
    console.log(`Image du jour : ${apodData.title}`);

    if (apodData.media_type === 'image') {
        const imageUrl = apodData.url;
        console.log(`URL de l'image : ${imageUrl}`);

        const imageResponse = await axios.get(imageUrl, { responseType: 'arraybuffer' });
        const imageBuffer = Buffer.from(imageResponse.data);

        const imageFileName = path.join(__dirname, 'apod_image.jpg');
        fs.writeFileSync(imageFileName, imageBuffer);

        console.log(`L'image a été enregistrée localement à : ${imageFileName}`);

        const mailjetClient = mailjet.apiConnect(process.env.MJ_APIKEY_PUBLIC, process.env.MJ_APIKEY_SECRET);
        const request = mailjetClient.post('send', { version: 'v3.1' }).request({
            Messages: [{
                From: {
                    Email: 'area.epitech.jus@gmail.com',
                    Name: 'AREA',
                },
                To: [{
                    Email: email,
                    Name: email,
                }],
                Subject: 'Image du jour de la NASA',
                HTMLPart: '<h3>Image du jour de la NASA</h3><p>Consultez l\'image ci-jointe.</p>',
                Attachments: [{
                    ContentType: 'image/jpeg',
                    Filename: 'apod_image.jpg',
                    Base64Content: imageBuffer.toString('base64'),
                }],
            }],
        });

        const result = await request;
        console.log(`E-mail envoyé avec succès à ${email}`);
    } else {
        console.log('Ce n\'est pas une image.');
    }
}

function getImageInterval(email) {
    const apiKey = process.env.REACT_APP_NASA_API_KEY;

    async function getImageAndSendEmail() {
        try {
            getAPOD(apiKey)
                .then((apodData) => afficherImageEtEnvoyerEmail(apodData, email))
                .catch((error) => console.error('Erreur dans le flux AREA', error));
        } catch (error) {
            console.error('Erreur dans le flux AREA', error);
        }
    }

    getAPOD(apiKey)
        .then((apodData) => afficherImageEtEnvoyerEmail(apodData, email))
        .catch((error) => console.error('Erreur dans le flux AREA', error));

    const delaiInitial = 24 * 60 * 60 * 1000;
    setInterval(getImageAndSendEmail, delaiInitial);
}

module.exports = {
    getImageInterval
};
