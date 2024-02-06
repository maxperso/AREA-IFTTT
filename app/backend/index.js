const express = require('express');
const mongoose = require('mongoose');
const area = require('./routes/area');
const auth = require('./routes/auth');
const rateLimit = require("express-rate-limit");
const cors = require("cors");
const bodyParser = require("body-parser");
const middleware = require ("./middleware/middleware")
const about_section = require("./controllers/about")
require('dotenv').config();

const uri = process.env.URI;

async function connect(){
    try {
        await mongoose.connect(uri);
        console.log("connected to MongoDB");
    }
    catch {
        console.log("error connecting to MongoDB");
    }
}

connect();

const app = express();
const corsOptions = {
    credentials: true,
    origin: '*',
    optionSuccessStatus: 200,
    methods: ["GET", "POST", "DELETE", "UPDATE", "PUT", "PATCH"]
}

app.use(cors(corsOptions));
app.use(express.json());
app.use(bodyParser.json());
app.use(express.urlencoded({ extended: true }));

const limit = rateLimit({
    max: 100,
    windowMs: 15 * 60 * 1000,
    delay: 5,
    message: "Too many requests",
});
app.use(limit);

app.use('/auth', auth, limit);
app.use('/area', middleware.headersVerificationMiddleware, area, limit);
app.get('/about.json', about_section.aboutJsonHandler);

const PORT = 8080;

app.listen(PORT, () => {
    console.log(`Server listening on: http://localhost:${PORT}`);
})

module.exports = app;