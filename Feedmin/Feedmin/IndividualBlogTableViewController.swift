//
//  IndividualBlogTableViewController.swift
//  Feedmin
//
//  Created by Togami Yuki on 2018/08/11.
//  Copyright © 2018 Togami Yuki. All rights reserved.
//

import UIKit

class IndividualBlogTableViewController: UITableViewController {

    @IBOutlet var IndividualBlogTableView: UITableView!
    var siteID:Int!
    var articleList:[articleInfo]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //mainCellViewを呼び出し、timeLineTableViewに登録
        let nib = UINib(nibName:"mainCellView",bundle:nil)
        self.IndividualBlogTableView.register(nib, forCellReuseIdentifier: "mainCell")
        self.IndividualBlogTableView.estimatedRowHeight = 250
        self.IndividualBlogTableView.rowHeight = UITableViewAutomaticDimension//自動的にセルの高さを調節する
        
        self.articleList = selectReadArticle(siteIDList: [self.siteID])
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.articleList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCellView
        
        cell.articleTitle.text = self.articleList[indexPath.row].articleTitle
        cell.cellLink = self.articleList[indexPath.row].articleURL
        cell.thumbView.image = UIImage(data:self.articleList[indexPath.row].thumbImageData! as Data)
        cell.currentLike = self.articleList[indexPath.row].fav
        if (self.articleList[indexPath.row].fav)!{
            cell.favButton.setImage(UIImage(named:"fav01"), for: .normal)
        }else{
            cell.favButton.setImage(UIImage(named:"fav02"), for: .normal)
        }
        cell.animalImage.image = animalList[animalNum]
        if self.articleList[indexPath.row].read{
            cell.backgroundColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0.0, alpha: 0.3)
        }

        return cell
    }
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateRead(articleURL:self.articleList[indexPath.row].articleURL,bool:true)//既読状態にする
        
        performSegue(withIdentifier: "goToWebIn",sender:nil)
    }
    //画面遷移時に呼び出される
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        print("画面遷移中")
        if let indexPath = self.IndividualBlogTableView.indexPathForSelectedRow{
            let title = self.articleList[indexPath.row].articleTitle
            let link = self.articleList[indexPath.row].articleURL
            //遷移先のViewControllerを格納
            let controller = segue.destination as! IndividualArticleViewController
            
            //遷移先の変数に代入
            controller.title = title
            controller.link = link
        }
    }

}
