const find = require('../services/find/finduserwithtoken')

module.exports = {

    remove_area: async (req, res) => {
        const user = await find.finduserwithtoken(req);
        const { area } = req.body;

        if (area == "crypto") {
            user.areas.crypto = false;
            await user.areas.save();
            res.json({ message: 'Crypto area disable' });
        }
        if (area == "meteo") {
            user.areas.meteo = false;
            await user.areas.save();
            res.json({ message: 'Meteo area disable' });
        }
        if (area == "nasa") {
            user.areas.nasa = false;
            await user.areas.save();
            res.json({ message: 'Nasa area disable' });
        }
        if (area == "norris") {
            user.areas.norris = false;
            await user.areas.save();
            res.json({ message: 'ChuckNorris area disable' });
        }
        if (area == "bourse") {
            user.areas.bourse = false;
            await user.areas.save();
            res.json({ message: 'Bourse area disable' });
        }
        if (area == "github") {
            user.areas.github = false;
            await user.areas.save();
            res.json({ message: 'Github area disable' });
        }
    }
}
