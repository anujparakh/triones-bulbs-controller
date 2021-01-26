import Foundation
import Intents

class BulbOnIntentHandler : NSObject, BulbsOnIntentHandling
{
    
    func handle(intent: BulbsOnIntent, completion: @escaping (BulbsOnIntentResponse) -> Void)
    {
        // Send turn on command
        sendBulbOnMessage() { (data, response, error) in
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
            self.sendMaxBrightnessMessage() {
                
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
    
    func sendBulbOnMessage(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "\(URL_BASE)power")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "value=on";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    func sendMaxBrightnessMessage(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    {
        let url = URL(string: "\(URL_BASE)brightness")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // HTTP Request Parameters which will be sent in HTTP Request Body
        let postString = "value=255";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
}
