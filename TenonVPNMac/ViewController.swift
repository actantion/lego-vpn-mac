//
//  ViewController.swift
//  TenonVPNMac
//
//  Created by friend on 2019/9/27.
//  Copyright © 2019 friend. All rights reserved.
//

import Cocoa
import NetworkExtension
import NEKit

class ViewController: NSViewController {
    var local_country: String = ""
    var local_private_key: String = ""
    var local_account_id: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let local_ip = TenonP2pLib.sharedInstance.getIFAddresses()[0]
        print("local ip:" + local_ip)
        let res = TenonP2pLib.sharedInstance.InitP2pNetwork(local_ip, 7981)
        
        local_country = res.local_country as String
        local_private_key = res.prikey as String
        local_account_id = res.account_id as String
              
        print("local country:" + res.local_country)
        print("private key:" + res.prikey)
        print("account id:" + res.account_id)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

