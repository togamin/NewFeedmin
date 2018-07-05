//
//  favTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class favTableViewController: UITableViewController {

    @IBOutlet var favTableView: UITableView!
    var siteInfoList:[siteInfo]!
    var articleInfoList:[articleInfo]!
    
    //マルチスレッド用
    let queue:DispatchQueue = DispatchQueue(label: "com.togamin.queue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //site情報読み込み
        self.siteInfoList = readSiteInfo()
        //お気に入り記事情報読み込み
        self.articleInfoList = readFav()
        
        //mainCellViewを呼び出し、timeLineTableViewに登録
        let nib = UINib(nibName:"mainCellView",bundle:nil)
        self.favTableView.register(nib, forCellReuseIdentifier: "mainCell")
        self.favTableView.estimatedRowHeight = 250
        self.favTableView.rowHeight = UITableViewAutomaticDimension//自動的にセルの高さを調節する
        
        
        
        //リフレッシュコントローラー作成
        print("リフレッシュコントローラー作成")
        //リフレッシュコントロールを作成する。
        let refresh = UIRefreshControl()
        //インジケーターの下に表示する文字列を設定する。
        refresh.attributedTitle = NSAttributedString(string: "読込中")
        //インジケーターの色を設定する。
        refresh.tintColor = UIColor.gray
        //テーブルビューを引っ張ったときの呼び出しメソッドを登録する。関数をうまく呼び出せていない
        refresh.addTarget(self, action: #selector(favTableViewController.relode(_: )), for: .valueChanged)
        //テーブルビューコントローラーのプロパティにリフレッシュコントロールを設定する。
        self.refreshControl = refresh
        print("リフレッシュコントローラーの設定完了")
        
    }
    
    //画面が表示されるたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        self.articleInfoList = readFav()
        self.favTableView.reloadData()
    }
    
    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func relode(_ sender: UIRefreshControl){
        print("再読み込み")
        self.articleInfoList = readFav()
        //テーブルを再読み込みする。
        self.favTableView.reloadData()
        //読込中の表示を消す。
        refreshControl?.endRefreshing()
    }
    
    
    //行数を決める
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return articleInfoList.count
    }
    
    //セルのインスタンス化
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCellView

        cell.siteTitle.text = self.siteInfoList[(articleInfoList[indexPath.row].siteID)!].siteTitle
        cell.articleTitle.text = self.articleInfoList[indexPath.row].articleTitle
        cell.cellLink = self.articleInfoList[indexPath.row].articleURL
        cell.thumbView.image = UIImage(data:self.articleInfoList[indexPath.row].thumbImageData! as Data)
        cell.currentLike = self.articleInfoList[indexPath.row].fav
        if (self.articleInfoList[indexPath.row].fav)!{
            cell.favButton.setImage(UIImage(named:"fav01"), for: .normal)
        }else{
            cell.favButton.setImage(UIImage(named:"fav02"), for: .normal)
        }
        cell.animalImage.image = animalList[animalNum]
        if self.articleInfoList[indexPath.row].read{
            cell.backgroundColor = UIColor.white
        }else{
            cell.backgroundColor = UIColor(red: 1, green: 0.6, blue: 0.0, alpha: 0.3)
        }

        return cell
    }
    
    //セルを横にスライドさせた時に呼ばれる
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("消すね??")
            let articleURL = self.articleInfoList[indexPath.row].articleURL
            updateFav(articleURL:articleURL!,bool:false)
            self.articleInfoList = readFav()
            //テーブルを再読み込みする。
            self.favTableView.reloadData()
        }
    }
    
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateRead(articleURL:self.articleInfoList[indexPath.row].articleURL,bool:true)
        performSegue(withIdentifier: "goToFavWeb",sender:nil)
    }
    //画面遷移時に呼び出される
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        print("画面遷移中")
        if let indexPath = self.favTableView.indexPathForSelectedRow{
            let title = self.articleInfoList[indexPath.row].articleTitle
            let link = self.articleInfoList[indexPath.row].articleURL
            //遷移先のViewControllerを格納
            let controller = segue.destination as! favArticleViewController
            
            //遷移先の変数に代入
            controller.title = title
            controller.link = link
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
