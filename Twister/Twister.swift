//
//  Twister.swift
//  Twister
//
//  Created by Nikhil Sharma on 02/07/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//
/////////////////////////////////////////////////////////////
//URL Parameters (Optional): this is another Dictionary ([String:Any?])  used to compose a dynamic endpoint. If your endpoint require dynamic values (ie. "/articles/{category}/id/{art_id}" ) you can use this dictionary to fill up placeholders (ie. passing ["category":"scifi","art_id":5999] ).

//Body (Optional): this the body of the request; its a struct of type RequestBody  where you can specify the data to put in body. You can create a JSON Body using let body = RequestBody(json: data)  (you can pass any JSON serializable structure); URL Encoded Body is supported (let body = RequestBody(urlEncoded: paramsDict) . Finally you can create a body with raw String  or plain Data  or provide your own encoding.
/////////////////////////////////////////////////////////////

import Foundation
import Alamofire
import Hydra

///This type encapsulates baseUrl, endpoint, methodType needed by Alamofire request
public struct Route{
    var r_endpoint:String
    var r_methodType:HTTPMethod
    
    public init(endPoint:String,methodType:HTTPMethod){
        self.r_endpoint = endPoint
        self.r_methodType = methodType
    }
    
}

public enum TwistError:Error{
    case configurationError(_ : String)
    case invalidURL(_: String)
    case missingEndpoint
    case noResponse
    case encodingFailed(_ : Any)
    case invalidRequestBody(_ : Any?)
}

public class Twister{
    
    public var configuration:TwistConfig?
    public init(_ config:TwistConfig? = nil){
        if let conf = config{
            self.configuration = conf
        }else{
            self.configuration = TwistConfig()
        }
    }
    
    /// Serial queue for cache network operations
    let networkQueue = DispatchQueue.init(label: "com.twister.networkQueue")
    
    /// This method is used to make an api call using twister
    ///
    /// - Parameters:
    ///   - request: TwistRequest object which encapculates request params,headers etc.
    ///   - autoRetryCount: number of times api should retry automatically
    /// - Returns: promise with reponse data encapsulated in TwistReponse object
    func apiRequest<Model>(request:TwistRequest<Model>,autoRetryCount:Int? = nil)->Promise<TwistResponse<Model>>{
        guard let config = self.configuration else{ fatalError("Twist configuartion not found.") }
        let operation = Promise<TwistResponse<Model>>(in: request.context ?? .custom(queue: networkQueue), token: request.invalidationToken,{ (fulfill, reject, status) in
            
            let rq = try Alamofire.request(request.urlRequest(in: config))
            rq.responseData{ (responseData) in
                let response = TwistResponse<Model>(responseData)
                switch response.type{
                case .success:
                    do{
                        try response.decodeJSON()
                        fulfill(response)
                    }catch let error{
                        reject(error)
                    }
                case .failure(let code):
                    let error = NSError(domain: "", code: code, userInfo: nil)
                    reject(error)
                case .noResponse:
                    reject(TwistError.noResponse)
                }
            }
            
        })
        guard let retryAttempts = autoRetryCount else { return operation } // single shot
        return operation.retry(retryAttempts) // retry n times
    }
}
