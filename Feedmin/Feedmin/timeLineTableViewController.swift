//
//  timeLineTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class timeLineTableViewController: UITableViewController {

    @IBOutlet var timeLineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //site情報読み込み
        siteInfoList = readSiteInfo()
        //記事情報読み込み
        articleInfoList = readArticleInfo()
        
        //mainCellViewを呼び出し、timeLineTableViewに登録
        let nib = UINib(nibName:"mainCellView",bundle:nil)
        self.timeLineTableView.register(nib, forCellReuseIdentifier: "mainCell")
        self.timeLineTableView.estimatedRowHeight = 250
        self.timeLineTableView.rowHeight = UITableViewAutomaticDimension//自動的にセルの高さを調節する
        
    }
    //行数を決める
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return articleInfoList.count
    }

    //セルのインスタンス化
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCellView
        cell.siteTitle.text = siteInfoList[(articleInfoList[indexPath.row]?.siteID)!]?.siteTitle
        cell.articleTitle.text = articleInfoList[indexPath.row]?.articleTitle
        cell.thumbView.image = UIImage(data:articleInfoList[indexPath.row]?.thumbImageData! as! Data)
        cell.cellLink = articleInfoList[indexPath.row]?.articleURL
        cell.currentLike = articleInfoList[indexPath.row]?.fav
        return cell
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
