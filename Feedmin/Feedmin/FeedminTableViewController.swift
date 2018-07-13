//
//  FeedminTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/07/01.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class FeedminCell:UITableViewCell{
    @IBOutlet weak var FeedminImageView: UIImageView!
}

class FeedminTableViewController: UITableViewController {

    @IBOutlet var FeedminTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName:"FeedminCell",bundle:nil)
        self.FeedminTableView.register(nib, forCellReuseIdentifier: "FeedminCell")
        self.FeedminTableView.estimatedRowHeight = 250
        self.FeedminTableView.rowHeight = UITableViewAutomaticDimension//自動的にセルの高さを調節する
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        default:
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedminCell", for: indexPath) as! FeedminCell
        if indexPath.section == 0{
            cell.FeedminImageView.image = UIImage(named:"feedmin01.png")
        }else if indexPath.section == 1{
            cell.FeedminImageView.image = UIImage(named:"feedmin02.png")
        }else if indexPath.section == 2{
            cell.FeedminImageView.image = UIImage(named:"feedmin03.png")
        }
        return cell
    }
    
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            performSegue(withIdentifier: "goFeedminWeb0",sender:nil)
        }else if indexPath.section == 1{
            performSegue(withIdentifier: "goFeedminWeb1",sender:nil)
        }else if indexPath.section == 2{
            performSegue(withIdentifier: "goFeedminWeb2",sender:nil)
        }
        
    }
    
    //画面遷移時に呼び出される
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        print("画面遷移中")
        let indexPath = self.FeedminTableView.indexPathForSelectedRow
        //遷移先のViewControllerを格納
        let controller = segue.destination as! FeedminViewController
        
        if indexPath?.section == 0{
            controller.title = "ブロガーにおすすめ！RSSリーダーアプリ「Feedmin」とは！？"
            controller.FeedminLink = "https://togamin.com/2018/07/13/feedmin01/"
        }else if indexPath?.section == 1{
            controller.title = "ブロガーにおすすめ！！RSSリーダーアプリ「Feedmin」の使い方."
            controller.FeedminLink = "https://togamin.com/2018/07/13/feedmin02/"
        }else if indexPath?.section == 2{
            controller.title = "RSSフィードに画像情報を入れる方法について。「Feedmin」にアイキャッチ画像を表示させるには??"
            controller.FeedminLink = "https://togamin.com/2018/07/13/feedmin03/"
        }
    }
}
