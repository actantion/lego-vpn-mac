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
import libp2p

class ViewController: NSViewController {
    var local_country: String = ""
    var local_private_key: String = ""
    var local_account_id: String = ""
    var countryCode:[String] = ["America", "Singapore", "Brazil","Germany","France","Korea", "Japan", "Canada","Australia","Hong Kong", "India", "England","China"]
    var countryNodes:[String] = []
    var iCon:[String] = ["us", "sg", "br","de","fr","kr", "jp", "ca","au","hk", "in", "gb","cn"]
    var choosed_country:String!
    @IBOutlet weak var smartRoute: NSButton!
    
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
        
        let url = URL(string:"https://www.baidu.com");
        URLSession(configuration: .default).dataTask(with: url!, completionHandler: {
            (data, rsp, error) in
            //do some thing
            print("visit network ok");
        }).resume()
        // Do any additional setup after loading the view.
        self.choosed_country = self.getCountryShort(countryCode: self.countryCode[0])
        NotificationCenter.default.addObserver(self, selector: #selector(onVPNStatusChanged), name: NSNotification.Name(rawValue: kProxyServiceVPNStatusNotification), object: nil)
        if VpnManager.shared.vpnStatus == .on {
            
        }
    }
    @objc func onVPNStatusChanged(){
        if VpnManager.shared.vpnStatus == .on{
            print("已连接")
//            self.view.layer?.backgroundColor = NSColor.black.cgColor
        }else{
            print("关闭连接")
//            self.view.layer?.backgroundColor = NSColor.yellow.cgColor
        }
    }
    func getCountryShort(countryCode:String) -> String {
        switch countryCode {
        case "America":
            return "US"
        case "Singapore":
            return "SG"
        case "Brazil":
            return "BR"
        case "Germany":
            return "DE"
        case "France":
            return "FR"
        case "Korea":
            return "KR"
        case "Japan":
            return "JP"
        case "Canada":
            return "CA"
        case "Australia":
            return "AU"
        case "Hong Kong":
            return "HK"
        case "India":
            return "IN"
        case "England":
            return "GB"
        case "China":
            return "CN"
        default:
            return ""
        }
    }
    func randomCustom(min: Int, max: Int) -> Int {
        let y = arc4random() % UInt32(max) + UInt32(min)
        return Int(y)
    }
    
    @IBAction func clickdisconnect(_ sender: Any) {
        VpnManager.shared.disconnect()
    }
    @IBAction func clickConnect(_ sender: Any) {
        if VpnManager.shared.vpnStatus == .on{
            VpnManager.shared.disconnect()
        }
        else{
            var route_node = self.getOneRouteNode(country: self.choosed_country)
            if (route_node.ip.isEmpty) {
                route_node = self.getOneRouteNode(country: self.local_country)
                if (route_node.ip.isEmpty) {
                    for country in self.iCon {
                        route_node = self.getOneRouteNode(country: country)
                        if (!route_node.ip.isEmpty) {
                            break
                        }
                    }
                }
                VpnManager.shared.disconnect()
            }

            var vpn_node = self.getOneVpnNode(country: self.choosed_country)
            if (vpn_node.ip.isEmpty) {
                for country in self.iCon {
                    vpn_node = self.getOneVpnNode(country: country)
                    if (!vpn_node.ip.isEmpty) {
                        break
                    }
                }
            }
            
            VpnManager.shared.ip_address = vpn_node.ip
            VpnManager.shared.port = Int(vpn_node.port)!

            print("rotue: \(route_node.ip):\(route_node.port)")
            print("vpn: \(vpn_node.ip):\(vpn_node.port),\(vpn_node.passwd)")
            
            let vpn_ip_int = LibP2P.changeStrIp(vpn_node.ip)
            VpnManager.shared.public_key = LibP2P.getPublicKey() as String
            
            VpnManager.shared.enc_method = ("aes-128-cfb," + String(vpn_ip_int) + "," + vpn_node.port + "," + String(self.smartRoute.isEnabled))
            VpnManager.shared.password = vpn_node.passwd
            VpnManager.shared.algorithm = "aes-128-cfb"
            VpnManager.shared.connect()
        }
    }
    func getOneRouteNode(country: String) -> (ip: String, port: String) {
        let res_str = LibP2P.getVpnNodes(country, true) as String
        if (res_str.isEmpty) {
            return ("", "")
        }
        
        let node_arr: Array = res_str.components(separatedBy: ",")
        if (node_arr.count <= 0) {
            return ("", "")
        }
        
        let rand_pos = randomCustom(min: 0, max: node_arr.count)
        let node_info_arr = node_arr[rand_pos].components(separatedBy: ":")
        if (node_info_arr.count < 5) {
            return ("", "")
        }
        
        return (node_info_arr[0], node_info_arr[2])
    }
    
    func getOneVpnNode(country: String) -> (ip: String, port: String, passwd: String) {
        let res_str = LibP2P.getVpnNodes(country, false) as String
        if (res_str.isEmpty) {
            return ("", "", "")
        }
        
        let node_arr: Array = res_str.components(separatedBy: ",")
        if (node_arr.count <= 0) {
            return ("", "", "")
        }
        
        let rand_pos = randomCustom(min: 0, max: node_arr.count)
        let node_info_arr = node_arr[rand_pos].components(separatedBy: ":")
        if (node_info_arr.count < 5) {
            return ("", "", "")
        }
        
        return (node_info_arr[0], node_info_arr[1], node_info_arr[3])
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

