const noble = require('@abandonware/noble');
const config = require('./config.json')
let bulbPeripherals = {}
let bulbNames = []

noble.on('stateChange', async (state) => {
    if (state === 'poweredOn') {
        await noble.startScanningAsync([], false);
    }
});

noble.on('discover', async (peripheral) => {
    if (peripheral.advertisement.localName == null)
        return
    let peripheralName = peripheral.advertisement.localName
    if (peripheralName.includes('Triones')) {
        // Found new bulb!
        if (!bulbNames.includes(peripheralName)) {
            console.log('Discovered: ' + peripheralName)
            bulbPeripherals[peripheralName] = {}
            bulbPeripherals[peripheralName]['peripheral'] = peripheral
            bulbNames.push(peripheralName)
        }
        // Found enough bulbs
        // TODO: Convert this into a timeout
        if (bulbNames.length >= config.numBulbs) {
            await noble.stopScanningAsync()
            await connectToBulbs()
        }
    }
});

async function connectToBulbs() {
    console.log('\n*** Connecting to Bulbs ***\n')
    for (bulbName of bulbNames) {
        await bulbPeripherals[bulbName].peripheral.connectAsync()
        console.log(bulbName + ' Connected!')
        try {
            const services = await bulbPeripherals[bulbName].peripheral.discoverServicesAsync([config.identifiers.writeServiceUUID]);
            const characteristics = await services[0].discoverCharacteristicsAsync()
            bulbPeripherals[bulbName].writeCharacteristic = characteristics[0]
            console.log('Saved Characteristic!')
        } catch (e) {
            // handle error
            console.log(e)
        }
    }
}

async function isReady() {
    numConnected = 0
    for (bulbName of bulbNames) {
        if (bulbPeripherals[bulbName].writeCharacteristic != null)
        {
            ++numConnected
        }
    }
    return (numConnected == config.numBulbs)
}

module.exports.isReady = isReady

module.exports.sendBulbMessage = async (hexMessage) => {

    let toWrite = Buffer.from(hexMessage, 'hex')
    for (bulbName of bulbNames) {
        bulbPeripherals[bulbName].writeCharacteristic.writeAsync(toWrite, false)
    }
}