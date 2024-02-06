const monitor = require('../services/actions/bourse');
const find = require('../services/find/finduserwithtoken')

module.exports = {

    bourse_area: async (req, res) => {
        const { email, symbol, interval } = req.body;

        const user = await find.finduserwithtoken(req);

        user.areas.bourse = true;
        await user.areas.save();

        if (email && symbol && interval) {
            console.log('email    OK :', email);
            console.log('symbol   OK :', symbol);
            console.log('Interval OK :', interval);

            await monitor.callBourse(email, symbol, interval, user);
            res.json({ message: 'Données reçues avec succès' });
        } else {
            res.status(400).json({ error: 'Paramètres manquants' });
        }
    }
};
