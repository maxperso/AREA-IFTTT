const User = require('../../models/users')

module.exports = {

    async finduserwithemail (email) {
        const user = await User.findOne({ email }).populate("areas");

        return (user);
    }
}
