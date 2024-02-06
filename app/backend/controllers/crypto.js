const bitcoinMonitor = require('../services/actions/crypto');
const find = require('../services/find/finduserwithtoken')

module.exports = {

    crypto_area: async (req, res) => {
        const { email, limit, interval, value, coin } = req.body;

        const user = await find.finduserwithtoken(req);

        user.areas.crypto = true;
        await user.areas.save();

        if (email && value && interval && limit && coin) {
            console.log('Email    OK :', email);
            console.log('Limit    OK :', limit);
            console.log('Interval OK :', interval);
            console.log('Value    OK :', value);
            console.log('Coin     OK :', coin)

            await bitcoinMonitor.checkBitcoinPricePeriodically(email, limit, interval, value, coin, user);
            res.json({ message: 'Données reçues avec succès' });
        } else {
            res.status(400).json({ error: 'Paramètres manquants' });
        }
    }
};
