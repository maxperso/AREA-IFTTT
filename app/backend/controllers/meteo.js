const axios = require('axios');
const action = require('../services/actions/meteo')
const find = require('../services/find/finduserwithtoken')

module.exports = {

    meteo_area: async (req, res) => {
        const { email, city, degree, value, interval } = req.body;

        const user = await find.finduserwithtoken(req);

        user.areas.meteo = true;
        await user.areas.save();

        if (email && city && degree && value && interval) {
            console.log('Email   OK :', email);
            console.log('City    OK :', city);
            console.log('Degree  OK :', degree);
            console.log('Value   OK :', value);
            console.log('Inteval OK :', interval)

            await action.checkmeteoPeriodically(email, city, degree, value, interval, user);
            res.json({ message: 'Données reçues avec succès' });
        } else {
            res.status(400).json({ error: 'Paramètres manquants' });
        }
    }
}
