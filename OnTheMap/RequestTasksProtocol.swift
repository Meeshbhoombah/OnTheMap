//
//  RequestTasks.swift
//  OnTheMap
//
//  Created by Rohan  on 9/5/16.
//  Copyright © 2016 Myang. All rights reserved.
//

import Foundation

protocol RequestTasks {
    associatedtype requestClient
    static func sharedInstance() -> requestClient
    func getURL(withPathExtension: String?) -> URL
    func convertData(_ data: Data, completionHandlerForConvertData: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
}

extension RequestTasks {
    
    // MARK: GET
    func taskForGETMethod(baseURL: URL, httpHeaders: [String: String]?, parameters: [String: AnyObject]?, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        baseTaskMethod(httpMethod: "GET", baseURL: baseURL, httpHeaders: httpHeaders, parameters: parameters, jsonBody: nil, completionHandlerForTask: completionHandlerForGET)
    }
    
    // MARK: POST
    func taskForPOSTMethod(baseURL: URL, httpHeaders: [String: String]?, parameters: [String: AnyObject]?, jsonBody: String?, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        baseTaskMethod(httpMethod: "POST", baseURL: baseURL, httpHeaders: httpHeaders, parameters: parameters, jsonBody: jsonBody, completionHandlerForTask: completionHandlerForPOST)
    }
    
    // MARK: DELETE
    func taskForDELETEMethod(baseURL: URL, httpHeaders: [String: String]?, parameters: [String: AnyObject]?, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        baseTaskMethod(httpMethod: "DELETE", baseURL: baseURL, httpHeaders: httpHeaders, parameters: parameters, jsonBody: nil, completionHandlerForTask: completionHandlerForDELETE)
    }
    
    
    // MARK: Private Helpers
    fileprivate func baseTaskMethod(httpMethod: String, baseURL: URL, httpHeaders: [String: String]?, parameters: [String: AnyObject]?, jsonBody: String?, completionHandlerForTask: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        // Build the final URL, Configure the request
        var request = URLRequest(url: addURLParameters(baseURL: baseURL, parameters: parameters))
        request.httpMethod = httpMethod
        
        if let httpHeaders = httpHeaders , !httpHeaders.isEmpty {
            for(key, value) in httpHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if let jsonBody = jsonBody , jsonBody.characters.count > 0 {
            request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        }
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if self.checkForRequestErrors(domain: "taskFor\(httpMethod)Method", data: data, response: response, error: error, completionHandlerForErrorCheck: completionHandlerForTask) {
                self.convertData(data!, completionHandlerForConvertData: completionHandlerForTask)
            }
        }) 
        
        // Start the request
        task.resume()
    }
    
    fileprivate func addURLParameters(baseURL: URL, parameters: [String: AnyObject]?) -> URL {
        
        guard let parameters = parameters , !parameters.isEmpty else {
            return baseURL
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    fileprivate func checkForRequestErrors(domain: String, data: Data? , response: URLResponse?, error: Error?, completionHandlerForErrorCheck: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> Bool {
        
        func sendError(_ error: String) {
            let userInfo = [NSLocalizedDescriptionKey: error]
            completionHandlerForErrorCheck(nil, NSError(domain: domain, code: 0, userInfo: userInfo))
        }
        
        // GUARD: Was there an error?
        guard (error == nil) else {
            sendError(error!.localizedDescription)
            return false
        }
        
        // Was the response a successful 2xx?
        if let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode < 200 || statusCode > 299 {
            
            // Is there more info in the response?
            if let data = data {
                self.convertData(data, completionHandlerForConvertData: completionHandlerForErrorCheck)
            } else {
                sendError("Service responsed with \(statusCode)")
            }
            
            return false
        }
        
        // GUARD: Was there any data returned?
        guard (data != nil) else {
            sendError("Service did not return any data")
            return false
        }
        
        return true
    }
    
    // MARK: Public Helpers
    func baseConvertData(_ data: Data, completionHandlerForConvertData: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data: \(data)"]
            completionHandlerForConvertData(nil, NSError(domain: "convertData", code: 0, userInfo: userInfo))
            return
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
}
