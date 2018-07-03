//
//  ViewController.swift
//  Example
//
//  Created by Nikhil Sharma on 02/07/18.
//  Copyright © 2018 Nikhil Sharma. All rights reserved.
//

import UIKit
import Twister

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func fetchDataButtonAction(_ sender: Any) {
        requestToGetChannelList()
    }
    func requestToGetChannelList(){
        let params = ["mine":true,"part":"contentDetails"] as [String : AnyObject]
        Twister.sharedInstance.apiRequest(fromRoute: TwistRoutes.channelList,params) { (result) in
            switch result {
            case .success(let model):
                print (model)
            case .failure(let error):
                print (error)
            }
        }
    }
    
}

