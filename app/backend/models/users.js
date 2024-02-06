const mongoose = require('mongoose');
const { Schema } = require('mongoose');

const userSchema = new mongoose.Schema(
    {
        username: {
            type: String,
            required: true,
            unique: true
        },
        email: {
            type: String,
            required: true,
            unique: true
        },
        password: {
            type: String,
            required: true
        },
        jwtToken: {
            type: String,
            required: false
        },
        areas : { type: Schema.Types.ObjectId, ref: 'Area' }
    },
);

const User = mongoose.model('User', userSchema);

module.exports = User;
