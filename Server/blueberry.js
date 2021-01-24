// scp -r Server/blueberry.js pi@blueberrypi:~/Projects/triones-bulbs-controller/Server/blueberry.js

const noble = require('noble');
const config = require('./config.json')
let bulbPeripherals = {}
let bulbNames = []
let bulbsDone = 0

discoverCallback = async (peripheral) => {
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
            // Connect to bulb
        peripheral.connect((err) => {
            if(err)
            {
                console.log('Error in connection: ' + err);
                return
            }
            console.log('Connected to ' + peripheralName)

            peripheral.discoverAllServicesAndCharacteristics((error, services, characteristics) => {
                for(characteristic of characteristics)
                {
                    if(characteristic.uuid == config.identifiers.writeCharacteristicUUID)
                        bulbPeripherals[peripheralName].writeCharacteristic = characteristic
                    else if(characteristic.uuid == config.identifiers.readCharacteristicUUID)
                        bulbPeripherals[peripheralName].readCharacteristic = characteristic
                }

                console.log('Done for bulb: ' + peripheralName)
                console.log('--------------------------------')
                bulbsDone += 1
                if(bulbsDone < config.numBulbs)
                    noble.startScanning([], false)
                else
                    noble.stopScanning()

            })
        })

    }
}

noble.on('discover', discoverCallback);
noble.on('stateChange', async (state) => {
    if (state === 'poweredOn') {
        noble.startScanning([], false);
    }
});

module.exports.isReady = async () => {
    return true
}
module.exports.sendBulbMessage = async (hexMessage) => {

    let toWrite = Buffer.from(hexMessage, 'hex')
    for (bulbName of bulbNames) {
        bulbPeripherals[bulbName].writeCharacteristic.write(toWrite, false)
    }
}
