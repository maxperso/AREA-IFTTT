const User = require('../models/users');

module.exports = {

    headersVerificationMiddleware: async (req, res, next) => {
        const bearerHeader = req.headers['authorization'];

        if (typeof bearerHeader !== 'undefined') {
            console.log(bearerHeader)
            const jwtToken = bearerHeader.split(' ')[1];

            const token = await User.findOne({ jwtToken });

            if (token) {
                console.log('Token OK');
                req.token = jwtToken;
                next();
            } else {
                console.log('Wrong Token');
                res.status(403).json({ error: 'Wrong Token in Authorization header' });
            }
        } else {
            res.status(403).json({ error: 'Token missing in Authorization header' });
        }
    },

}
