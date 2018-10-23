//
//  TwistRequest.swift
//  Twister
//
//  Created by Nikhil Sharma on 23/10/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////////////////
//CACHE POLICY: Caches data from a backend resource, reducing the number of requests to the resource. As apps make requests to the same URI, you can use this policy to return cached responses instead of forwarding those requests to the backend server. The ResponseCache policy can improve your API's performance through reduced latency and network traffic.////You'll likely find ResponseCache most useful when backend data used by your API is updated only periodically. For example, imagine you have an API that exposes weather report data refreshed only every ten minutes. By using ResponseCache to return cached responses between refreshes, you can decrease the number of requests reaching the backend. This also reduces the number of network hops.

//TIMEOUT: Default value for REST API is 100 seconds
//////////////////////////////////////////////////////////////////////////////////////

import Foundation
import Hydra
import Alamofire

public typealias ParamDict = [String:AnyObject]
public typealias HeaderDict = [String:String]

/// This is a request configuration class
public class TwistRequest<Model:Codable>{
    
    public var route:Route
    
    public var urlParams:ParamDict?
    
    public var fields:ParamDict?
    
    public var headers:HeaderDict = [:]
    
    public var body:Any?
    
    public var cachePolicy:URLRequest.CachePolicy?
    
    public var timeout:TimeInterval?
    
    public var encoding:TwistEncoder.EncodingStyle
    
    public var invalidationToken:InvalidationToken?
    
    public var context:Context?
    
    public var mimeType:String
    
    public var files:[(Data,String)]?
    
    private var boundary:String
    
    public init(route:Route, encoding:TwistEncoder.EncodingStyle? = .json) {
        self.encoding = encoding!
        self.route = route
        self.mimeType = "image/jpg"
        self.boundary = TwistEncoder.generateBoundary()
    }
    
    public func urlRequest(in config:TwistConfig) throws ->URLRequest{
        let requestUrl = try url(in: config)
        var urlRequest = URLRequest.init(url: requestUrl)
        urlRequest.httpMethod = route.r_methodType.rawValue
        urlRequest.cachePolicy = self.cachePolicy ?? config.cachePolicy
        urlRequest.timeoutInterval = self.timeout ?? config.timeout
        urlRequest.httpBody = try TwistEncoder.encodeData(encoding,body,files,mimeType,boundary)
        urlRequest.allHTTPHeaderFields = headers(in: config)
        return urlRequest
    }
    
    public func url(in config:TwistConfig) throws ->URL{
        let pathString = config.baseUrl.absoluteString+route.r_endpoint
        let fullURLString = try pathString.fill(withValues: self.urlParams).stringByAdding(urlEncodedFields: self.fields)
        guard let url = URL(string:fullURLString) else{ throw TwistError.invalidURL(pathString)}
        return url
    }
    
    public func headers(in config:TwistConfig)->HeaderDict{
        headerForCurrentEncoding()
        var headerParam:HeaderDict = config.globalHeaders
        headers.forEach{headerParam[$0]=$1}
        return headerParam
    }
    private func headerForCurrentEncoding(){
        switch self.encoding {
        case .json:
            headers["Content-Type"] = "application/json"
        case .urlEncoded(_):
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        case .multipartFile:
            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        default:
            break
        }
    }
}

public extension Dictionary where Key == String, Value == AnyObject {
    
    public func urlEncodedString(base: String = "") throws -> String {
        guard self.count > 0 else { return "" } // nothing to encode
        let items: [URLQueryItem] = self.flatMap { (key,value) in
            return URLQueryItem(name: key, value: String(describing: value))
        }
        var urlComponents = URLComponents(string: base)!
        urlComponents.queryItems = items
        guard let encodedString = urlComponents.url else {
            throw TwistError.encodingFailed(self as AnyObject)
        }
        return encodedString.absoluteString
    }
}

public extension String {
    
    public func fill(withValues dict: [String: Any?]?) -> String {
        guard let data = dict else {
            return self
        }
        var finalString = self
        data.forEach { arg in
            if let unwrappedValue = arg.value {
                finalString = finalString.replacingOccurrences(of: "{\(arg.key)}", with: String(describing: unwrappedValue))
            }
        }
        return finalString
    }
    
    public func stringByAdding(urlEncodedFields fields: ParamDict?) throws -> String {
        guard let f = fields else { return self }
        return try f.urlEncodedString(base: self)
    }
    
}
