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
        case requestTimeout = "request_timeout"
        case bundleName = "Bundle name"
        case headers = "global_headers"
        case serverUrl = "server_url"
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
        guard let infoPlist = Bundle.main.infoDictionary else{fatalError("info.plist not found for this target")}
        guard let baseUrl = infoPlist[TwistConfigKeys.serverUrl.rawValue] as? String
            else {
                debugPrint("unable to find server_url for this target")
                return nil
                }
        guard let name = infoPlist[TwistConfigKeys.bundleName.rawValue] as? String
            else{
                debugPrint("unable to find bundle name for this target")
                return nil
                }

        self.init(name: name, baseUrl: baseUrl)
        timeout = infoPlist[TwistConfigKeys.requestTimeout.rawValue] as? Double ?? 20.0
        if let headers = infoPlist[TwistConfigKeys.headers.rawValue] as? HeaderDict{
            self.globalHeaders = headers
        }
    }
    
}
