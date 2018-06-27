//
//  SelectSiteTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/22.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class SelectSiteTableViewController: UITableViewController {

    var siteInfoList:[siteInfo]!
    var readArticleInfo:[articleInfo]!
    var readCount:Int! = 0
    
    @IBOutlet var selectSitecellTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //site情報読み込み
        self.siteInfoList = readSiteInfo()
        
        //cellContentViewを呼び出し、myTableViewに登録
        let nib = UINib(nibName:"selectSiteCell",bundle:nil)
        self.selectSitecellTableView.register(nib, forCellReuseIdentifier: "selectSiteCell")

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //行数を決める
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.siteInfoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectSiteCell", for: indexPath) as! selectSiteCell
        self.readArticleInfo = readRead(siteID:indexPath.row)
        readCount = self.readArticleInfo.count
        print("テストreadCount:\(readCount)")
        
        cell.readNum.text = String(readCount)
        cell.siteTitleLabel.text = self.siteInfoList[indexPath.row].siteTitle
        cell.siteBool.isOn = self.siteInfoList[indexPath.row].siteBool
        cell.siteURL = self.siteInfoList[indexPath.row].siteURL
        
        return cell
    }
}
