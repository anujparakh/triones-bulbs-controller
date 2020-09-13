const bulbTalker = require('./bulbTalker')

const express = require('express')
const app = express()
const bodyParser = require('body-parser');

app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

const port = 3000

app.get('/', async (req, res) => {
})

app.post('/command', async(req, res) => {
    console.log(req.body)
    let command = req.body.command
    if(await bulbTalker.isReady())
    {
        console.log('Command is: ' + command)
        await bulbTalker.sendBulbMessage(command)
        return res.send('Command Sent')
    }
    return res.send('Bulbs Not Ready')

})

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})
