//
//  BulbHandler.swift
//  Bulbs
//
//  Created by Anuj Parakh on 8/28/20.
//  Copyright © 2020 Anuj Parakh. All rights reserved.
//

import Foundation
import CoreBluetooth
import os

struct BulbHolder
{
    public var peripheral: CBPeripheral!
    public var characteristic: CBCharacteristic!
    
    public mutating func setCharacteristic(_ toSet: CBCharacteristic)
    {
        self.characteristic = toSet
    }
    // Maybe add current state here later
}

class BulbHandler: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate
{
    private var centralManager: CBCentralManager!
    private var bulbs: [BulbHolder] = []
    public var statusUpdateCallback: ((String) -> Void)?
    
    private func updateConnectionStatus(_ status: String)
    {
        print("Status: \(status)")
        if(statusUpdateCallback != nil)
        {
            statusUpdateCallback!(status)
        }
    }
    
    // Callback when central manager's state is updated
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch central.state
        {
            
        case .unknown:
            print("Central Manager's State is Unknown")
        case .resetting:
            print("Central Manager's State is Resetting")
        case .unsupported:
            print("BLE Unsupported")
        case .unauthorized:
            print("BLE Unauthorized")
        case .poweredOff:
            print("BLE powered off")
        case .poweredOn:
            updateConnectionStatus("Scanning")
            // Scan for any peripherals
            
            centralManager.scanForPeripherals(withServices: nil)

            updateConnectionStatus("BLE On and Scanning")
        @unknown default:
            print ("Central Manager Don't know :(")
        }
    }
    
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        if(peripheral.name != nil)
        {
            if(peripheral.name!.contains("Triones"))
            {
                updateConnectionStatus("found bulb \(peripheral.name!)")
                var newBulb = true
                for bulb in bulbs
                {
                    if bulb.peripheral == peripheral
                    {
                        newBulb = false
                    }
                }
                if newBulb
                {
                    bulbs.append(BulbHolder(peripheral: peripheral, characteristic: nil))
                    peripheral.delegate = self
                    centralManager.connect(peripheral)
                }
            }
        }
        // Save the peripheral instance and connect to it
//        peripheral.delegate = self
//        // Set delegate to self for callbacks
//        centralManager.stopScan()
//        centralManager.connect(peripheral)
    }
    
    
    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        updateConnectionStatus("Bulb Connected")

        peripheral.discoverServices([BTConstants.bulbWriteService])
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        print("Disconnected")
    }
    
    // Handles Services Discovery
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        guard let services = peripheral.services else { return }
        for service in services
        {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics
        {
            for i in 0..<bulbs.count
            {
                if bulbs[i].peripheral == peripheral
                {
                    bulbs[i].setCharacteristic(characteristic)
                }
            }

        }
    }
    
    func tryToSendHex(_ hexString: String)
    {
        if(bulbs.isEmpty)
        {
            print("No bulb connected")
            return
        }
        
        let toWrite = hexString.data(using: .hexadecimal)
        if (toWrite != nil)
        {
            for bulb in bulbs
            {
                if bulb.peripheral != nil && bulb.characteristic != nil
                {
                    bulb.peripheral.writeValue(toWrite!, for: bulb.characteristic, type: .withoutResponse)
                }
            }
        }
        
    }
    
    override init()
    {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
}

extension String {
       enum ExtendedEncoding {
           case hexadecimal
       }

       func data(using encoding:ExtendedEncoding) -> Data? {
           let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

           guard hexStr.count % 2 == 0 else { return nil }

           var newData = Data(capacity: hexStr.count/2)

           var indexIsEven = true
           for i in hexStr.indices {
               if indexIsEven {
                   let byteRange = i...hexStr.index(after: i)
                   guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                   newData.append(byte)
               }
               indexIsEven.toggle()
           }
           return newData
       }
   }
