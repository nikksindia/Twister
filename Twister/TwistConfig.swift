//
//  TwistConfig.swift
//  Twister
//
//  Created by Nikhil Sharma on 23/10/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//

import Foundation

public class TwistConfig:CustomStringConvertible {
    
    enum TwistConfigKeys:String{
        case twistScheme = "twistScheme"
        case name = "name"
        case headers = "headers"
        case baseUrl = "baseUrl"
    }
    
    //config profile name
    public var name:String
    
    //base url for API
    public var baseUrl:URL
    
    //headres to be included in each service call
    public var globalHeaders:HeaderDict = [:]
    
    //default cache policy
    public var cachePolicy:URLRequest.CachePolicy = .useProtocolCachePolicy
    
    //default timeout
    public var timeout:TimeInterval = 20.0
    
    public var description: String{
        return "\(self.name): \(self.baseUrl.absoluteString)"
    }
    
    public init?(name:String, baseUrl:String){
        guard let url = URL(string: baseUrl) else {return nil}
        self.name = name
        self.baseUrl = url
    }
    
    public convenience init?(){
        let appConfig = Bundle.main.object(forInfoDictionaryKey: TwistConfigKeys.twistScheme.rawValue) as? [String:AnyObject]
        
        guard let baseUrl = appConfig?[TwistConfigKeys.baseUrl.rawValue] as? String else{ return nil}
        guard let name = appConfig?[TwistConfigKeys.name.rawValue] as? String else {return nil}
        self.init(name: name, baseUrl: baseUrl)
        if let headers = appConfig?[TwistConfigKeys.headers.rawValue] as? HeaderDict{
            self.globalHeaders = headers
        }
    }
    
}
