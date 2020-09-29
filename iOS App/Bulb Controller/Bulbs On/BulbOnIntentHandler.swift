import Foundation
import Intents

class BulbOnIntentHandler : NSObject, BulbsOnIntentHandling
{
    
    func handle(intent: BulbsOnIntent, completion: @escaping (BulbsOnIntentResponse) -> Void)
    {
        // Send turn on command
        sendCommand("CC2333") { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error in sending command: \(error)")
                return
            }
            
            // Convert HTTP Response Data to a String
//            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print("Response data string:\n \(dataString)")
//            }
            
            // Send Brightness Command
            self.sendCommand("56DDDDDDFF0FAA") {
                
                (data, response, error) in
                // Check for Error
                if let error = error {
                    print("Error in sending command: \(error)")
                    return
                }
                
                // Intent handling is complete
                completion(BulbsOnIntentResponse(code: .success, userActivity: nil))
                
            }
        }
    }
    
    // Sends a Bulb request with given command and handler
    func sendCommand(_ command: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://blueberrypi:3000/command")
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
}
