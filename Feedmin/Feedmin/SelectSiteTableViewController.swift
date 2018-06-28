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
    
    //インスタンスの作成
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectSiteCell", for: indexPath) as! selectSiteCell
        self.readArticleInfo = readRead(siteID:indexPath.row)
        readCount = self.readArticleInfo.count
        
        //未読記事数表示とそのデザイン
        cell.readNum.text = String(readCount)
        cell.readNum.layer.cornerRadius = 5
        cell.readNum.clipsToBounds = true
        
        cell.siteTitleLabel.text = self.siteInfoList[indexPath.row].siteTitle
        cell.siteBool.isOn = self.siteInfoList[indexPath.row].siteBool
        cell.siteURL = self.siteInfoList[indexPath.row].siteURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let makeAllRead: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "全て既読") { (action, index) -> Void in
            allRead(siteID: indexPath.row,bool: true)
            self.selectSitecellTableView.reloadData()
        }
        makeAllRead.backgroundColor = UIColor(red: 0, green: 0.08, blue: 0.24, alpha: 0.4)
        return [makeAllRead]
    }
}
