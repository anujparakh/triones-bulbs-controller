//
//  TodayViewController.swift
//  Bulbs Widget
//
//  Created by Anuj Parakh on 9/13/20.
//  Copyright © 2020 Anuj Parakh. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding
{
    
    @IBOutlet weak var brightnessControl: UISegmentedControl!
    @IBOutlet weak var powerSwitch: UISwitch!
    
    var lastBrightness = 255;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 0, height: 300)
         self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            print("compact")
            self.preferredContentSize = maxSize;
        }
        else {
            self.preferredContentSize = CGSize(width: 0, height: 175);
        }
    }
    
    
    @IBAction func switchToggled(_ sender: UISwitch)
    {
        if sender.isOn
        {
            // Send On Message
            updatePower(true) { (data, response, err) in
                // TODO: Check error message
                
                print("Turned On!")
                
            }
        }
        else
        {
            // Send Off Message
            updatePower(false) { (data, response, err) in
                // TODO: Check error message
                
                print("Turned Off!")
                
            }
            
        }
    }
    
    @IBAction func minusClicked(_ sender: Any)
    {
        lastBrightness -= 10
        if lastBrightness <= 1
        {
            lastBrightness = 1
            brightnessControl.selectedSegmentIndex = 0
            return
        }

        // Default color intensity
        updateBrightness(lastBrightness) { (data, response, err) in
            // TODO: Check error message
            
            
        }
    }
    
    @IBAction func plusClicked(_ sender: Any)
    {
        lastBrightness += 10
        if lastBrightness > 255
        {
            lastBrightness = 255
            brightnessControl.selectedSegmentIndex = 2
            return
        }
        updateBrightness(lastBrightness) { (data, response, err) in
            // TODO: Check error message
            
            
        }
        
    }

    @IBAction func brightnessControlChanged(_ sender: UISegmentedControl)
    {
        // TODO: Check current color
        
        var brightnessHex = "00"
        switch (sender.selectedSegmentIndex)
        {
        case 0:
            brightnessHex = "01"
            lastBrightness = 01
            break
        case 1:
            brightnessHex = "60"
            lastBrightness = 96
            break
        case 2:
            brightnessHex = "FF"
            lastBrightness = 255
            break
        default:
            break
        }
        
        // Default color intensity
        updateBrightness(lastBrightness) { (data, response, err) in
            // TODO: Check error message
            
            print("Set brightness to \(brightnessHex)")
            
        }
    }
    
    @IBAction func colorButtonClicked(_ sender: UIButton)
    {
        let colorHex = sender.backgroundColor!.toHex()!
        brightnessControl.selectedSegmentIndex = 2
        lastBrightness = 255
        print("Switching to color: \(colorHex)")
        
        if(colorHex == "FFFFFF")
        {
            sendCommand("56000000FF0FAA") { (data, response, err) in
                // TODO: Check error message
                print("Set color to default")
            }
        }
        else
        {
            sendCommand("56" + colorHex + "00F0AA") { (data, response, err) in
                // TODO: Check error message
                print("Set color to \(colorHex)")
            }
        }
    }
    
    
    // Sends a Bulb request with given command and handler
    func sendCommand(_ command: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "\(URL_BASE)command")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "command=" + command;
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func updateBrightness(_ brightness: Int, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "\(URL_BASE)brightness")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "value=\(brightness)"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func updatePower(_ power: Bool, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "\(URL_BASE)power")
        guard let requestUrl = url else { fatalError() }
        
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "value=\(power ? "on" : "off")"
        // Set HTTP Request Body
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
}


extension UIColor {
    
    // MARK: - Initialization
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    // MARK: - Computed Properties
    
    var toHex: String? {
        return toHex()
    }
    
    // MARK: - From UIColor to String
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
}
