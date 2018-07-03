//
//  TwistRoutes.swift
//  Example
//
//  Created by Nikhil Sharma on 03/07/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//

import Foundation
import Twister

let baseUrl = "https://www.googleapis.com/youtube/v3/"
struct TwistRoutes{
    
    static let channelList = Route<ChannelModel>(baseUrl:baseUrl,endPoint:"channels",methodType:.get)
    
}
