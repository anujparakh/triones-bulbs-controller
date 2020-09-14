//
//  IntentHandler.swift
//  Bulbs On
//
//  Created by Anuj Parakh on 9/13/20.
//  Copyright © 2020 Anuj Parakh. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        if intent is BulbsOnIntent
        {
            return BulbOnIntentHandler()
        }
        else if intent is BulbsOffIntent
        {
            return BulbOffIntentHandler()
        }
//        else if intent is BulbsBrightnessIntent
//        {
//
//        }
        return self
    }
    
}
