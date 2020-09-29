const bulbTalker = require('./blueberry')

const express = require('express')
const app = express()
const bodyParser = require('body-parser');

app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodies

const port = 3000

let currentState = {
    power: true,
    brightness: 255,
    color: "white" // usually hex, white for default
}

async function parseAndSendCommand(command)
{
    toSend = "";
    // Check if power
    if(command.power != null)
    {
        toSend = "CC" + (command.power ? "23" : "24") + "33"
        currentState.power = command.power
    }
    // Check if brightness
    else if(command.brightness != null)
    {
        toSend = "56000000" + command.brightness.hexString() + "0FAA";
        currentState.brightness = command.brightness;
    }
    // Check if color
    else if(command.color != null)
    {
        currentState.color = command.color
        if (color == "white")
        {
            toSend = "56000000FF0FAA"
            currentState.brightness = 256
        }
        else
        {
            toSend = "56" + command.color + "00F0AA"
        }
    }

    await bulbTalker.sendBulbMessage(toSend)
}

app.get('/', async (req, res) => {
    return res.status(200).send(JSON.stringify(currentState))
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
    console.log(`Listening at http://localhost:${port}`)
})
