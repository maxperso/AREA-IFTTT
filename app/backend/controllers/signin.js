const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const User = require('../models/users');
const Area = require('../models/area')

module.exports = {

    signUp: async (req, res) => {
        try {
            const { username, email, password } = req.body;
            console.log(req.body)
            const hashedPassword = await bcrypt.hash(password, 10);

            const user = await User.create({
                username,
                email,
                password: hashedPassword,
            });

            var newArea = new Area({});
            console.log(user);
            console.log(newArea);
            newArea.user = user;
            await newArea.save();
            user.areas = newArea
            await user.save()

            res.status(201).json({ user: user._id });
        } catch (error) {
            console.log(error);
            res.status(500).json({ error: error });
        }
    },

    signIn: async (req, res) => {
        const secretKey = process.env.JWT_SECRET;

        console.log('Requête de connexion reçue:', req.body);
        const { username, password } = req.body;

        try {
            const user = await User.findOne({ username }).populate("areas");

            if (!user) {
                return res.status(401).send("Utilisateur non trouvé");
            }

            const match = await bcrypt.compare(password, user.password);
            if (match) {
                const token = jwt.sign({ userId: user._id }, secretKey, { expiresIn: '24h' });
                console.log("Token généré :", token);

                user.jwtToken = token
                await user.save();

                const areas = user.areas;
                const username = user.username;
                const email = user.email;

                res.status(200).json({ message: "Connexion réussie", token, areas, username, email});
            } else {
                res.status(401).send("Mot de passe incorrect");
            }
        } catch (error) {
            console.error("Erreur lors de la connexion:", error);
            res.status(500).send("Erreur lors de la connexion");
        }
    },
}
