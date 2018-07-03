//
//  Twister.swift
//  Twister
//
//  Created by Nikhil Sharma on 02/07/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//

import Foundation
import Alamofire

/// Result type which includes 'success' and 'failure' cases
///
/// - success: returns model as success output
/// - failure: return error as failure output
public enum Result<Model> {
    case success(Model)
    case failure(Error)
}

///This type encapsulates baseUrl, endpoint, methodType needed by Alamofire request
public struct Route<Model>{
    var r_baseUrl:String
    var r_endpoint:String
    var r_methodType:HTTPMethod
    
    public init(baseUrl:String,endPoint:String,methodType:HTTPMethod){
        r_baseUrl = baseUrl
        r_endpoint = endPoint
        r_methodType = methodType
    }
    
}

public class Twister:NSObject{
    
    /// Singleton instance
    public static var sharedInstance = Twister()
    
    /// Initializer
    private override init() { }
    
    public typealias resultHandler<Model> = (Result<Model>) -> Void
    public typealias requestParams = [String:AnyObject]
    
    /// Serial queue for cache network operations
    let networkQueue = DispatchQueue.init(label: "com.nikksdev.networkQueue")
    
    
    /// This method is used to make an api call using twister
    ///
    /// - Parameters:
    ///   - route: Route type object with expected 'Model' response type
    ///   - params: request parameters
    ///   - headers: request headers
    ///   - completion: completion handler
    public func apiRequest<Model: Codable> (fromRoute route: Route<Model>,_ params:requestParams? = nil,_ headers:[String:String]? = nil,
                                     completion:@escaping resultHandler<Model>) {
        
        // make sure the endpoint path is a valid URL
        guard let url = URL(string: route.r_baseUrl+route.r_endpoint) else {
            completion(.failure(NSError(domain: "", code: 500,userInfo: ["error":"invalid endpoints supplied"])))
            return
        }
        
        //Alamofire uses its own queue for request operation and return response in main queue if we don't specify any queue for response handler.
        Alamofire.request(url, method: route.r_methodType, parameters: params, encoding: URLEncoding.default, headers: headers).responseData(queue: networkQueue){ (response) in
            
            guard response.error == nil else {
                completion(.failure(response.error!))
                return
            }
            
            //since we have passed our own queue, response will be in our queue
            //Switch to main queue before performing any ui operations
            if  let data = response.data{
                do{
                    let model = try JSONDecoder().decode(Model.self, from: data)
                    completion(.success(model))
                }catch let error{
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(  domain: "",
                                              code: 1000,
                                              userInfo: ["error":"expected a diferent model"])))
            }
        }
        
    }
}



