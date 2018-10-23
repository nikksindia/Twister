//
//  TwistEncoder.swift
//  Twister
//
//  Created by Nikhil Sharma on 23/10/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//

import Foundation

public class TwistEncoder{
    
    public enum EncodingStyle{
        case rawData
        case rawString(_ :String.Encoding?)
        case json
        case urlEncoded(_ :String.Encoding?)
        case multipartFile
    }
    
    public class func encodeData(_ encoding:EncodingStyle,_ body:Any?,_ files:[(Data,String)]?,_ mimeType:String,_ boundary:String) throws ->Data{
        switch encoding {
        case .rawData:
            guard let data = body as? Data else{throw TwistError.invalidRequestBody(body)}
            return data
        case .rawString(let encoding):
            guard let str = body as? String else{throw TwistError.invalidRequestBody(body)}
            guard let data = str.data(using: encoding ?? .utf8) else{throw TwistError.encodingFailed(str)}
            return data
        case .json:
            if let jsonObj = body as? ParamDict{
                return try JSONSerialization.data(withJSONObject: jsonObj, options: [])
            }
            return Data()
        case .urlEncoded(let encoding):
            if let obj = body as? ParamDict{
                let encodedString = try obj.urlEncodedString()
                guard let data = encodedString.data(using: encoding ?? .utf8) else {
                    throw TwistError.encodingFailed(encodedString)
                }
                return data
            }
            return Data()
        case .multipartFile:
            return try multipartData(body,files,mimeType,boundary)
        }
    }
    public class func multipartData(_ body:Any?,_ files:[(Data,String)]?,_ mimeType:String, _ boundary:String) throws -> Data{
        
        let boundaryPrefix = "--\(boundary)\r\n"
        var fullData = Data()
        
        if let params = body as? ParamDict{
            params.forEach{
                fullData.appendString(boundaryPrefix)
                fullData.appendString("Content-Disposition: form-data; name=\"\($0)\"\r\n\r\n")
                fullData.appendString("\($1)\r\n")
            }
        }
        
        if let filesArray = files{
            filesArray.forEach{
                fullData.appendString(boundaryPrefix)
                fullData.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\($0.1)\"\r\n")
                fullData.appendString("Content-Type: \(mimeType)\r\n\r\n")
                fullData.append($0.0)
                fullData.appendString("\r\n")
                fullData.appendString("--".appending(boundary.appending("--")))
            }
        }
        return fullData
    }
    
    public class func generateBoundary() -> String {
        return String(format: "twister.boundary.%08x%08x", arc4random(), arc4random())
    }
}

extension Data {
    public mutating func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

