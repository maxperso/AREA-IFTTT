const axios = require('axios');
require('dotenv').config();
const monitor = require('../services/actions/github')
const find = require('../services/find/finduserwithtoken')

module.exports = {

    getUrl: async (req, res) => {
        const {repoUrl , interval, accessToken, mail} = req.body

        if (repoUrl && accessToken) {
            console.log('repoUrl     OK :', repoUrl)
            console.log('interval    OK :', interval);
            console.log('accessToken OK :', accessToken);
            console.log('mail        OK :', mail);

        const user = await find.finduserwithtoken(req);

        user.areas.github = true;
        await user.areas.save();

            await monitor.checkcommitPeriodically(repoUrl , interval, accessToken, mail, user);
            res.json({ message: 'Données reçues avec succès' });
        } else {
            res.status(400).json({ error: 'Paramètres manquants' });
        }
    },

    handleAuth: async (req, res) => {
        console.log('Requête d\'authentification GitHub reçue');
        const code = req.query.code;
        if (!code) {
            console.log('Code d\'authentification non fourni');
            return res.status(400).send('Code d\'authentification non fourni');
        }

        // A UPDATE
        // const user = await find.finduserwithtoken(req);

        // user.areas.github = true;
        // await user.areas.save();

        console.log(`Reçu code d'authentification : ${code}`);

        try {
            const tokenResponse = await axios.post('https://github.com/login/oauth/access_token', {
            client_id: process.env.GITHUB_CLIENT_ID,
            client_secret: process.env.GITHUB_CLIENT_SECRET,
            code: code,
            }, {
            headers: { accept: 'application/json' }
            });

            console.log('Réponse de GitHub reçue', tokenResponse.data);
            
            if (tokenResponse.data.access_token) {
            console.log('Token d\'accès obtenu avec succès');
            const redirectUrl = `http://localhost:8081/widget?accessToken=${tokenResponse.data.access_token}`;
            monitor.getLastCommit(tokenResponse.data.access_token, "maxperso", "company_trombi");
                
            res.redirect(redirectUrl);
            } else {
            console.log('Erreur lors de l\'obtention du token d\'accès', tokenResponse.data);
            res.status(500).send('Erreur lors de l\'obtention du token d\'accès');
            }
        } catch (error) {
            console.error('Erreur lors du traitement de l\'authentification GitHub :', error);
            res.status(500).send('Erreur interne du serveur');
        }
    }

}