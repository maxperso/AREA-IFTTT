const { GoogleAuth } = require('google-auth-library')
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const find = require('../services/find/finduserwithemail')
const User = require('../models/users')
const Area = require('../models/area')

module.exports = {

    oauth: async (req, res) => {
        const { username, email, token } = req.body;

        if (!username && !email && !token) {
            res.status(400).json({ error: 'Paramètre manquant' })
        }
        const secretKey = process.env.JWT_SECRET;
        const user_exist = await find.finduserwithemail(email)

        if (!user_exist) {
            console.log('utilisateur introuvable. \nCréation de l\'utilisateur')
            const hashedPassword = await bcrypt.hash(token, 10);
            const user = await User.create({
                username,
                email,
                password: hashedPassword,
            });

            const tokenn = jwt.sign({ userId: user._id }, secretKey, { expiresIn: '24h' });
        
            var newArea = new Area({});
            console.log(user);
            console.log(newArea);
            newArea.user = user;
            await newArea.save();
            user.areas = newArea
            user.jwtToken = tokenn
            await user.save()

            const usernamee = user.username;
            const emaill = user.email;

            console.log('user: ', user)

            console.log('Utilisateur crée')
            res.status(200).json({ message: 'Utilisateur crée', tokenn, usernamee, emaill })
        }
        if (user_exist) {
            const new_user = await User.findOne({ email }).populate("areas");
            console.log('utilisateur trouvé. \nLogin en cours')

            const new_token = jwt.sign({ userId: new_user._id }, secretKey, { expiresIn: '24h' });
            new_user.jwtToken = new_token
            await new_user.save();

            const areas = new_user.areas;
            const usernamee = new_user.username;
            const emaill = new_user.email;

            res.status(200).json({ message: 'Utilisateur logé', new_token, areas, usernamee, emaill })
        }

    }
}
