const express = require('express');
const router = express.Router();
const auth = require('../controllers/signin');
const oauthh = require('../controllers/oauth');
const oauthgithub = require('../controllers/githubAuth');
require("dotenv").config();

router.route("/signup").post(auth.signUp);
router.route("/signin").post(auth.signIn);
router.route('/google').post(oauthh.oauth);
router.route('/github').get(oauthgithub.handleAuth);
router.route('/githubb').post(oauthgithub.getUrl)

module.exports = router;
