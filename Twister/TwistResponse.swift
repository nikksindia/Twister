//
//  TwistResponse.swift
//  Twister
//
//  Created by Nikhil Sharma on 23/10/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//

import Foundation
import Alamofire

public enum ResponseType{
    case success(_ : Int)
    case failure(_ : Int)
    case noResponse
    
    private static let successCodes: Range<Int> = 200..<299
    
    public static func from(response: HTTPURLResponse?) -> ResponseType {
        guard let r = response else {
            return .noResponse
        }
        return (ResponseType.successCodes.contains(r.statusCode) ? .success(r.statusCode) : .failure(r.statusCode))
    }
    
    public var code: Int? {
        switch self {
        case .success(let code):     return code
        case .failure(let code):     return code
        case .noResponse:            return nil
        }
    }
}

class TwistResponse<Model:Codable>{
    
    public var data:Data?
    
    public var responseObj:Model?
    
    public var responseString:String?
    
    public var httpResponse:HTTPURLResponse?
    
    public var metrics:Timeline?
    
    public var type:ResponseType
    
    public var httpStatusCode:Int?{
        return self.type.code
    }
    
    public init(_ response:DataResponse<Data>) {
        self.httpResponse = response.response
        self.metrics = response.timeline
        self.data = response.data
        responseString = String.init(data:data ?? Data(),encoding:.utf8)
        self.type = ResponseType.from(response: httpResponse)
    }
    
    public func decodeJSON() throws{
        do{
            responseObj = try JSONDecoder().decode(Model.self, from: data ?? Data())
        }catch let error{
            throw error
        }
    }
}
