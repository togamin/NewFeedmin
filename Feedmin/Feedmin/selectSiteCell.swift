//
//  selectSiteCell.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/22.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

//前の画面に戻る時に、前画面のtableViewを元に戻す

import UIKit

class selectSiteCell:UITableViewCell{
    
    @IBOutlet weak var siteBool: UISwitch!
    @IBOutlet weak var siteTitleLabel: UILabel!
    
    var siteURL:String!
    
    @IBAction func siteBoolA(_ sender: UISwitch) {
        if sender.isOn{
            updateSiteBool(siteURL:siteURL,siteBool:true)
            print("テスト:trueに変更しました")
        }else{
            updateSiteBool(siteURL:siteURL,siteBool:false)
            print("テスト:falseに変更しました")
        }
    }
}
