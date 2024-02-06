const nasaa = require('../services/actions/nasa');
const find = require('../services/find/finduserwithtoken')
require("dotenv").config();

module.exports = {

    nasa: async (req, res) => {
        apiKey = process.env.REACT_APP_NASA_API_KEY
        const { email } = req.body;

        const user = await find.finduserwithtoken(req);

        user.areas.nasa = true;
        await user.areas.save();

        if (email) {
            console.log('Email    OK :', email);

            nasaa.getImageInterval(email);

            res.json({ message: 'Données reçues avec succès' });
        } else {
            res.status(400).json({ error: 'Paramètres manquants' });
        }
    }
};
