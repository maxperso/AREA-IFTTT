// const find = require('../services/find/finduserwithtoken')

// module.exports = {

//     get_user_data: async (req, res) => {

//         const user = await find.finduserwithtoken(req);
//         const data = user;
        
//         if(user) {
//             res.status(200).json(data);
//             console.log(`Données del'user ${user.username} ont bien été transmises.`)
//         } else {
//             res.status(400).json({error: `Données de ${user.username} irrécupérable.`});
//         }
//     }
// }
