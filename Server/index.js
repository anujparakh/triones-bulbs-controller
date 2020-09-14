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
        await bulbTalker.sendBulbMessage(command)
        console.log('Command Sent')
        return res.status(200).send('Command Sent')
    }
    console.log('Bulbs Not Ready')
    return res.status(204).send('Bulbs Not Ready')

})

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})
