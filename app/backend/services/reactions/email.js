require("dotenv").config();

const mailjet = require('node-mailjet').apiConnect(
    process.env.MJ_APIKEY_PUBLIC,
    process.env.MJ_APIKEY_SECRET
);

async function sendEmail(mail, subject, textpart) {
    const request = mailjet.post('send', { version: 'v3.1' }).request({
        Messages: [
            {
                From: {
                    Email: 'area.epitech.jus@gmail.com',
                    Name: 'AREA',
                },
                To: [
                    {
                        Email: mail,
                        Name: mail,
                    },
                ],
                Subject: subject,
                TextPart: textpart,
            },
        ],
    });

    try {
        await request;
        console.log('E-mail envoyé avec succès');
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'e-mail:', error.message);
    }
}

module.exports = {
    sendEmail: sendEmail,
};
