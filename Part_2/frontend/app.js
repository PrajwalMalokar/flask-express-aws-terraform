var express = require('express');
var app = express();

app.set('view engine', 'ejs');

const URL = process.env.BACKEND_URL || 'http://127.0.0.1:5000/api';

app.get('/', async function (req, res) {
    const options = {
        method: 'GET'
    };
    
    try {
        console.log('Attempting to fetch from:', URL);
       
        let response = await fetch(URL, options);
        console.log('Response status:', response.status);
        const data = await response.json();
        console.log('Data from backend:', data);
        console.log('Data.data:', data.data);
        console.log('Type of data.data:', typeof data.data);
        
        res.render('index', { data: data.data });
    } catch (err) {
        console.log('Error details:', err.message);
        console.log('Full error:', err);
        res.status(500).json({ msg: 'Internal Server Error.' });
    }
});

app.listen(3000, '0.0.0.0', function () {
    console.log('Frontend app listening on port 3000');
});