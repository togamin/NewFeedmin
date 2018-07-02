//
//  SettingTableTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class SettingTableTableViewController: UITableViewController {

    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        var myDefault = UserDefaults.standard
        if myDefault.object(forKey: "notificationSwitch") != nil {
            notificationSwitch.isOn = myDefault.object(forKey: "notificationSwitch") as! Bool
        }else if notificationSwitch.isOn == nil{
            myDefault.set(true, forKey: "notificationSwitch")
            notificationSwitch.isOn = myDefault.object(forKey: "notificationSwitch") as! Bool
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        var myDefault = UserDefaults.standard
        // UserDefaultにデータを書き込む
        myDefault.set(notificationSwitch.isOn, forKey: "notificationSwitch")
    }
    


    //セクションの数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //各セクションのセル数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 「設定」のセルの数
            return 3
        case 1: // 「通知」のセルの数
            return 1
        case 2: // 「その他」のセルの数
            return 3
        default:
            return 0
        }
    }
}
