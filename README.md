# Twister

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Twister.svg)](https://cocoapods.org/pods/Twister)  
![Platform](https://img.shields.io/cocoapods/p/Twister.svg?style=flat)

Twister makes it easy to write a type safe network layer for any API. What it only needs is a model expected as API response, to confirm 'Codable(Encodable&Decodable)' protocol.

## Requirements

- iOS 9.0+
- Xcode 8.1

## Installation

#### CocoaPods
You can use [CocoaPods](https://cocoapods.org/) to install `Twister` by adding it to your `Podfile`:

```ruby
platform :ios, '9.0'
use_frameworks!
pod 'Twister'
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/Twister.framework` to an iOS project.

```
github "nikksindia/Twister"
```

#### Manually
1. Add ```Alamofire``` as dependency in your project.
2. Download and drop ```Twister.swift``` in your project.  
3. Congratulations!  

## Usage

Follows these steps:

1. Create a codable model for your response. See example below:
```swift
struct Channel:Codable{
    var id:String?
    var kind:String?
    var etag:String?
    var userId:String?
}
```
2. Create a struct to manage all your endpoints. See example below:
```swift
let baseUrl = "https://www.yourdomain.com/v3/"
struct TwistRoutes{
    static let channelList = Route<Channel>(baseUrl:baseUrl,endPoint:"channels",methodType:.get)
    static let productList = Route<Product>(baseUrl:baseUrl,endPoint:"products",methodType:.post)
}
```
3. Now you are ready to call API using Twister. Go to your view controller and use 'apiRequest' method as follows:
```swift
let params = ["mine":true,"part":"contentDetails"] as [String : AnyObject]
let header = ["authKey":"CRREW11472"]
Twister.sharedInstance.apiRequest(fromRoute: TwistRoutes.channelList,params,header) { (result) in
    switch result {
    case .success(let model):
        print (model)
    case .failure(let error):
        print (error)
    }
}
```

## Contribute

We would love you for the contribution to **Twister**, check the ``LICENSE`` file for more info.

## Meta

Nikhil Sharma – [@devilnikks](https://twitter.com/devilnikks) – nikksindia@gmail.com

Distributed under the MIT license. See ``LICENSE`` for more information.

[https://github.com/nikksindia](https://github.com/nikksindia/)

[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-green.svg
[license-url]: https://github.com/nikksindia/Twister/License.md
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
