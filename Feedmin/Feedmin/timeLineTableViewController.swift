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
        cell.cellLink = articleInfoList[indexPath.row]?.articleURL
        cell.thumbView.image = UIImage(data:articleInfoList[indexPath.row]?.thumbImageData! as! Data)
        cell.currentLike = articleInfoList[indexPath.row]?.fav
        if (articleInfoList[indexPath.row]?.fav)!{
            cell.favButton.setImage(UIImage(named:"fav01"), for: .normal)
        }else{
            cell.favButton.setImage(UIImage(named:"fav02"), for: .normal)
        }
        return cell
    }
    
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToWeb",sender:nil)
    }
    //画面遷移時に呼び出される
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        print("画面遷移中")
        if let indexPath = self.timeLineTableView.indexPathForSelectedRow{
            let title = articleInfoList[indexPath.row]?.articleTitle
            let link = articleInfoList[indexPath.row]?.articleURL
            //遷移先のViewControllerを格納
            let controller = segue.destination as! articleViewController
            
            //遷移先の変数に代入
            controller.title = title
            controller.link = link
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
