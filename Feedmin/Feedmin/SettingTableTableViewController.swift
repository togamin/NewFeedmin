//
//  SettingTableTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class SettingTableTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //セクションの数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //各セクションのセル数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // 「設定」のセクション
            return 1
        case 1: // 「通知」のセクション
            return 1
        case 2: // 「その他」のセクション
            return 3
        default:
            return 0
        }
    }
}
