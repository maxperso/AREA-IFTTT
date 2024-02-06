const axios = require('axios');
const emailService = require('../reactions/email');
const User = require('../../models/users');
require("dotenv").config();

let intervalId

async function check_meteo(city) {
    const WEATHER_API_KEY = process.env.WEATHER_API_KEY;
    try {
        const weatherResponse = await axios.get(`http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${WEATHER_API_KEY}&units=metric`);
        const temp = weatherResponse.data.main.temp;
        return temp;
    } catch (error) {
        console.error('Erreur lors de la récupération de la météo', error.message);
        throw error;
    }
}

async function get_meteo(city) {
    const WEATHER_API_KEY = process.env.WEATHER_API_KEY;
    try {
        const weatherResponse = await axios.get(`http://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${WEATHER_API_KEY}&units=metric`);
        const temp = weatherResponse.data;
        return temp;
    } catch (error) {
        console.error('Erreur lors de la récupération de la météo', error.message);
        throw error;
    }
}

async function forecast_meteo(city) {
    const apiKey = process.env.WEATHER_API_KEY;
    const weatherApiUrl = 'https://api.openweathermap.org/data/2.5/forecast';
    try {
        const response = await axios.get(`${weatherApiUrl}?q=${city}&appid=${apiKey}`);
    
        const today = new Date();
        today.setHours(0, 0, 0, 0);
    
        const tomorrowForecast = response.data.list.find(item => {
          const forecastDate = new Date(item.dt * 1000);
          forecastDate.setHours(0, 0, 0, 0);
          return forecastDate.getTime() === today.getTime() + 86400000;
        });
    
        if (!tomorrowForecast) {
          throw new Error('Aucune prévision disponible pour le jour suivant.');
        }

        const temperatureCelsius = tomorrowForecast.main.temp - 273.15;
    
        const forecastData = {
          timestamp: tomorrowForecast.dt,
          temperature: temperatureCelsius.toFixed(2),
          description: tomorrowForecast.weather[0].description,
          date: tomorrowForecast.dt_txt,
        };

        return forecastData;
    } catch (error) {
        console.error('Erreur lors de la récupération des prévisions météo pour le jour suivant:', error.message);
        throw error;
    }
}

async function meteo_action(email, city, degree_limit, value) {

    // 0  = positive trigger
    // 1  = negative trigger
    // 2  = forecast
    try {
        const temperature = await check_meteo(city);
        // console.log('température non dépassée', )

        if (value == 0 && temperature > degree_limit) {
            console.log(`La température limite qui a été fixée à ${degree_limit}°C a été dépassée.\nLa température est actuellement de ${temperature}°C`);

            clearInterval(intervalId);
            const subject = 'Réaction de température dépassée';
            const data = `La température limite qui a été fixée à ${degree_limit}°C a été dépassée.\nLa température est actuellement de ${temperature}°C`;

            await emailService.sendEmail(email, subject, data);

            console.log(`Email envoyé avec succès à ${email} avec la météo de ${city}.`);
        }
        if (value == 1 && temperature < degree_limit) {
            console.log(`La température limite qui a été fixée à ${degree_limit}°C a été atteinte.\nLa température est actuellement de ${temperature}°C`);

            clearInterval(intervalId);
            const subject = 'Réaction de température dépassée';
            const data = `La température limite qui a été fixée à ${degree_limit}°C a été atteinte.\nLa température est actuellement de ${temperature}°C`;

            await emailService.sendEmail(email, subject, data);

            console.log(`Email envoyé avec succès à ${email} avec la météo de ${city}.`);
        }
        if (value == 2) {
            const meteo = await forecast_meteo(city)

            const subject = 'Meteo previsions'
            const data = `Prevision of the day: ${meteo.date}\nTemperature estimated is ${meteo.temperature}°C\nThe time is going to be ${meteo.description}.`

            await emailService.sendEmail(email, subject, data);
            console.log(data)
        }
        if (value == 3) {
            const meteo = await get_meteo(city)

            const subject = 'Meteo previsions'
            const data = `Temperature and condition of today:\nTemperature is ${meteo.main.temp}°C\nThe time is ${meteo.weather[0].main} (${meteo.weather[0].description}).`

            await emailService.sendEmail(email, subject, data);
        }

    } catch (error) {
        console.error('Erreur lors de la récupération de la météo', error.message);
    }
}

async function checkmeteoPeriodically(email, city, degree_limit, value, interval, user) {
    const time = interval;

    intervalId = setInterval(async () => {
        console.log('Inside setInterval:', user.areas.meteo);
        if (user.areas.meteo == false) {
            clearInterval(intervalId);
            console.log('Meteo area switch to false. Area disable.');
        } else {
            await meteo_action(email, city, degree_limit, value);
    
            try {
                const updatedUser = await User.findById(user._id).populate("areas");

                if (updatedUser) {
                    user = updatedUser;
                } else {
                    console.error('User not found after update.');
                }
            } catch (error) {
                console.error('Error fetching updated user:', error);
            }
        }
    }, time * 1000);
}

module.exports = {
    checkmeteoPeriodically: checkmeteoPeriodically,
}
