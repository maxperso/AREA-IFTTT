const express = require('express');
const router = express.Router();
const crypto = require('../controllers/crypto');
const meteo = require('../controllers/meteo');
const rm = require('../controllers/removearea')
const nasa_area = require('../controllers/nasa')
const get_areas = require('../controllers/sendareas')
const norris = require('../controllers/chucknorris')
const bours = require('../controllers/bourse')

// handling
router.route("/getareas").post(get_areas.send_areas)
router.route("/remove").post(rm.remove_area)

// areas
router.route("/crypto").post(crypto.crypto_area)
router.route("/meteo").post(meteo.meteo_area)
router.route("/nasa").post(nasa_area.nasa)
router.route("/chucknorris").post(norris.norris_area)
router.route("/bourse").post(bours.bourse_area)

module.exports = router;
