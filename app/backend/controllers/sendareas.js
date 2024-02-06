const find = require('../services/find/finduserwithtoken')

module.exports = {

    send_areas: async (req, res) => {

        const user = await find.finduserwithtoken(req);
        const areas = user.areas;
        
        if(user) {
            res.status(200).json(areas);
            console.log(`Données des areas de ${user.username} ont bien été transmis.`)
        } else {
            res.status(400).json({error: `Areas de ${user.username} irrécupérable.`});
        }
    }
}
