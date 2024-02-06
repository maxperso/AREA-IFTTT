const monitor = require('../services/actions/chucknorris');
const find = require('../services/find/finduserwithtoken')

module.exports = {

    norris_area: async (req, res) => {
        const { email, interval } = req.body;

        const user = await find.finduserwithtoken(req);

        user.areas.norris = true;
        await user.areas.save();

        if (email && interval) {
            console.log('Email    OK :', email)
            console.log('Interval OK :', interval);

            await monitor.callNorris(email, interval, user);
            res.json({ message: 'Données reçues avec succès' });
        } else {
            res.status(400).json({ error: 'Paramètres manquants' });
        }
    }
};
