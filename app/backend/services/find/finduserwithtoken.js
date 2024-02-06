const User = require('../../models/users')

module.exports = {

    async finduserwithtoken (req) {
        const bearerHeader = req.headers['authorization'];
        const jwtToken = bearerHeader.split(' ')[1];
        const user = await User.findOne({ jwtToken }).populate("areas");

        return (user);
    }
}
