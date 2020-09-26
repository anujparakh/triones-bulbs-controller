const noble = require('noble');

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
