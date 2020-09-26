import Foundation
import Intents

class BulbOffIntentHandler : NSObject, BulbsOffIntentHandling
{
    
    func handle(intent: BulbsOffIntent, completion: @escaping (BulbsOffIntentResponse) -> Void)
    {
        // Send turn off command
        sendCommand("CC2433") { (data, response, error) in
            // Check for Error
            if let error = error {
                print("Error in sending command: \(error)")
                return
            }

            // Intent handling is complete
            completion(BulbsOffIntentResponse(code: .success, userActivity: nil))
        }
    }
    
    // Sends a Bulb request with given command and handler
    func sendCommand(_ command: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "http://virus.lan:3000/command")
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
