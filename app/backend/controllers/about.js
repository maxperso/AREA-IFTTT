const express = require('express');

module.exports = {
    aboutJsonHandler: async = (req, res) => {
        const clientHost = req.ip;
        const currentTime = Math.floor(Date.now() / 1000);

        const server = {
            current_time: currentTime,
            services: [
                {
                    name: 'meteo',
                    actions: [
                        { name: 'meteo_limit_exceeds', description: 'Meteo exceeds the limit fix by the user.' },
                        { name: 'meteo_limit_reached', description: 'Meteo reeached the limit fix by the user.' },
                        { name: 'meteo_forecast', description: 'Meteo forecast for 1day+.' },
                        { name: 'meteo_today', description: 'Meteo prevision for today' },
                    ],
                    reactions: [
                        { name: 'send_mail', description: 'Send mail with meteo informations.' },
                    ]
                },
                {
                    name: 'crypto',
                    actions: [
                        { name: 'crypto_limit_exceeds', description: 'Crypto exceeds the limit fix by the user.' },
                        { name: 'crypto_limit_reached', description: 'Crypto reeached the limit fix by the user.' },
                        { name: 'crypto_get', description: 'Get informations on choosen crypto by the user.' },
                    ],
                    reactions: [
                        { name: 'send_mail', description: 'Send mail with crypto informations.' },
                    ]
                },
                {
                    name: 'nasa',
                    actions: [
                        { name: 'nasa_apod', description: 'Nasa pics of the day.' },
                    ],
                    reactions: [
                        { name: 'send_mail', description: 'Send mail with pic of nasa every 24hours.' },
                    ]
                },
                {
                    name: 'chucknorris',
                    actions: [
                        { name: 'norris_joke', description: 'Random joke of chuck norris.' },
                    ],
                    reactions: [
                        { name: 'send_mail', description: 'Send mail every (minutes for example, limit fix by the user) with the joke.' },
                    ]
                },
                {
                    name: 'bourse',
                    actions: [
                        { name: 'bourse_choice', description: 'Stock prices of choosen symbol.' },
                    ],
                    reactions: [
                        { name: 'send_mail', description: 'Send mail every (minutes for example, limit fix by the user) with informations of the choosen symbol by the user.' },
                    ]
                },
                {
                    name: 'github',
                    actions: [
                        { name: 'github_commit', description: 'Get last commit of a repo on github.' },
                    ],
                    reactions: [
                        { name: 'send_mail', description: 'Send mail every (minutes for example, limit fix by the user) with last commit on the repo.' },
                    ]
                },
            ],
        };

        console.log(server);

        res.json({
            client: { host: clientHost },
            server,
        });
    }
}
