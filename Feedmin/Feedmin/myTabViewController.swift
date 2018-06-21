//
//  myTabViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class myTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //アイコン色
        UITabBar.appearance().tintColor = .white
        
        //背景色
        UITabBar.appearance().barTintColor = UIColor(red: 0, green: 0.02, blue: 0.06, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
