//
//  BTConstants.swift
//  MITS
//
//  Created by Anuj Parakh on 4/18/20.
//  Copyright © 2020 Anuj Parakh. All rights reserved.
//

import CoreBluetooth

class BTConstants: NSObject
{
//    public static var bulbId = CBUUID.init(string: "0A3A84EA-F923-6856-F759-02C22BA658E4")
    public static var bulbIds = [CBUUID.init(string: "FFD5"), CBUUID.init(string: "FFD0"), CBUUID.init(string: "0A3A84EA-F923-6856-F759-02C22BA658E4")]

     public static var bulbWriteService = CBUUID.init(string: "FFD5")

}
