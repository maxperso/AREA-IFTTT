const mongoose = require('mongoose');

const area = new mongoose.Schema(
    {
        user : { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
        crypto: {
            type: Boolean,
            required: false,
            default: false
        },
        meteo: {
            type: Boolean,
            required: false,
            default: false
        },
        nasa: {
            type: Boolean,
            required: false,
            default: false
        },
        norris: {
            type: Boolean,
            required: false,
            default: false
        },
        bourse: {
            type: Boolean,
            required: false,
            default: false
        },
        github: {
            type: Boolean,
            required: false,
            default: false
        }
    },
);

const Area = mongoose.model('Area', area);

module.exports = Area;
