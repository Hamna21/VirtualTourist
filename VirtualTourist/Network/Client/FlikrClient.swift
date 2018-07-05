//
//  FlikrClient.swift
//  VirtualTourist
//
//  Created by Hamna Usmani on 7/1/18.
//  Copyright © 2018 Hamna Usmani. All rights reserved.
//

import Foundation

class FlikrClient: NSObject {
    
    let session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    func taskForGetMethod(parameters: [String: AnyObject], completionHandlerForGet: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask{
        
        let request = URLRequest(url: flikrUrlFromParameters(parameters: parameters))
        let task = session.dataTask(with: request) { (data, response, error) in
            func sendError(_ error: String){
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGet(nil, NSError(domain: "taskForPost", code: 1, userInfo: userInfo))
            }
            guard (error == nil) else{
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                sendError("Status Code other than 2xx")
                return
            }
            guard let data = data else{
                sendError("No Data was returned")
                return
            }
            
            self.convertDataWithCompletionHandler(data: data, completionHandlerForData: completionHandlerForGet)
        }
        
        task.resume()
        
        return task
    }
    
    //Formulating URL
    func flikrUrlFromParameters(parameters: [String: AnyObject]) -> URL {
        var component = URLComponents()
        component.scheme = Flickr.APIScheme
        component.host = Flickr.APIHost
        component.path = Flickr.APIPath
        component.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters{
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            component.queryItems?.append(queryItem)
        }
        
        return component.url!
    }
    
    //Converting returned Data to JSON
    func convertDataWithCompletionHandler(data: Data, completionHandlerForData: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void){
        var parsedResult: AnyObject!
        do{
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch{
            let userInfo = [NSLocalizedDescriptionKey: "Error in parsing data"]
            completionHandlerForData(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
        }
        completionHandlerForData(parsedResult, nil)
    }
    
    class func sharedInstance() -> FlikrClient {
        struct Singleton {
            static let sharedInstance = FlikrClient()
        }
        return Singleton.sharedInstance
    }
}
