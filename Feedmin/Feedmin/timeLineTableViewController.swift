//
//  timeLineTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class timeLineTableViewController: UITableViewController,XMLParserDelegate,UIViewControllerTransitioningDelegate {

    @IBOutlet var timeLineTableView: UITableView!
    var siteInfoList:[siteInfo]!
    var articleInfoList:[articleInfo]!
    
    //trueの記事のサイトを格納
    var siteTrueIDList:[Int] = []
    
    //RSS解析用
    var parser:XMLParser!//parser:構文解析
    var items:[Item] = []//複数の記事を格納するための配列
    var item:Item?
    var currentString = ""
    
    //trueになった後のタグは解析しない
    var endFunc:Bool = false
    
    //マルチスレッド用
    let queue:DispatchQueue = DispatchQueue(label: "com.togamin.queue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Info全削除
        //deleteAllArticleInfo()
        //deleteAllSiteInfo()
        
        //UserDefaultについて
        var myDefault = UserDefaults.standard
        if myDefault.object(forKey: "animalNum") != nil {
            animalNum = myDefault.object(forKey: "animalNum") as! Int
        }
        if myDefault.object(forKey: "articleNum") != nil {
            articleNum = myDefault.object(forKey: "articleNum") as! Int
        }
        
        
        //site情報読み込み.siteBoolがtrueのものだけ
        self.siteInfoList = getTrueSiteInfo()
        for i in self.siteInfoList{
            siteTrueIDList.append(i.siteID)
        }
        //記事情報読み込み
        self.articleInfoList = selectReadArticle(siteIDList:siteTrueIDList)
        
        //mainCellViewを呼び出し、timeLineTableViewに登録
        let nib = UINib(nibName:"mainCellView",bundle:nil)
        self.timeLineTableView.register(nib, forCellReuseIdentifier: "mainCell")
        self.timeLineTableView.estimatedRowHeight = 250
        self.timeLineTableView.rowHeight = UITableViewAutomaticDimension//自動的にセルの高さを調節する
        
        
        
        //リフレッシュコントローラー作成
        print("リフレッシュコントローラー作成")
        //リフレッシュコントロールを作成する。
        let refresh = UIRefreshControl()
        //インジケーターの下に表示する文字列を設定する。
        refresh.attributedTitle = NSAttributedString(string: "読込中")
        //インジケーターの色を設定する。
        refresh.tintColor = UIColor.gray
        //テーブルビューを引っ張ったときの呼び出しメソッドを登録する。関数をうまく呼び出せていない
        refresh.addTarget(self, action: #selector(timeLineTableViewController.relode(_: )), for: .valueChanged)
        //テーブルビューコントローラーのプロパティにリフレッシュコントロールを設定する。
        self.refreshControl = refresh
        print("リフレッシュコントローラーの設定完了")
        
    }
    
    //画面が表示されるたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        //site情報読み込み.siteBoolがtrueのものだけ
        self.siteInfoList = getTrueSiteInfo()
        self.siteTrueIDList = []
        for i in self.siteInfoList{
            self.siteTrueIDList.append(i.siteID)
        }
        //記事再読み込み
        self.articleInfoList = selectReadArticle(siteIDList:self.siteTrueIDList)
        //テーブルを再読み込みする。
        self.timeLineTableView.reloadData()
    }
    
    @IBAction func menuBtn(_ sender: UIBarButtonItem) {
        print("テスト:menuBtn押されました")
    }
    
    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func relode(_ sender: UIRefreshControl){
        queue.async {() -> Void in
            print("再読み込み")
            //新着記事を取得し、CoreDataに代入.
            self.rssUpdate()
            //site情報読み込み.siteBoolがtrueのものだけ
            self.siteInfoList = getTrueSiteInfo()
            self.siteTrueIDList = []
            for i in self.siteInfoList{
                self.siteTrueIDList.append(i.siteID)
            }
            //記事再読み込み
            self.articleInfoList = selectReadArticle(siteIDList:self.siteTrueIDList)
            //テーブルを再読み込みする。
            self.timeLineTableView.reloadData()
            //読込中の表示を消す。
            self.refreshControl?.endRefreshing()
        }
    }
    func tableReload(){
        queue.async {() -> Void in
        //記事再読み込み
        self.articleInfoList = selectReadArticle(siteIDList:self.siteTrueIDList)
        //テーブルを再読み込みする。
        self.timeLineTableView.reloadData()
        }
    }

    //行数を決める
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.articleInfoList.count
    }

    //セルのインスタンス化
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCellView

        cell.siteTitle.text = readSelectSiteInfo(siteID: self.articleInfoList[indexPath.row].siteID!)
        
        
        cell.articleTitle.text = self.articleInfoList[indexPath.row].articleTitle
        cell.cellLink = self.articleInfoList[indexPath.row].articleURL
        cell.thumbView.image = UIImage(data:self.articleInfoList[indexPath.row].thumbImageData! as! Data)
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
    
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateRead(articleURL:self.articleInfoList[indexPath.row].articleURL,bool:true)
            self.tableReload()
        performSegue(withIdentifier: "goToWeb",sender:nil)
    }
    //画面遷移時に呼び出される
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        print("画面遷移中")
        if let indexPath = self.timeLineTableView.indexPathForSelectedRow{
            let title = self.articleInfoList[indexPath.row].articleTitle
            let link = self.articleInfoList[indexPath.row].articleURL
            //遷移先のViewControllerを格納
            let controller = segue.destination as! articleViewController
            
            //遷移先の変数に代入
            controller.title = title
            controller.link = link
        }
    }
    
    
    //更新するための関数RSS解析-----------------------------------------------------------------------
    func rssUpdate(){
        for siteInfo in siteInfoList{
            let siteURL = siteInfo.siteURL
            //itemsに新着記事が入る
            self.startDownload(siteURL: siteURL!)
            for newArticleInfo in self.items{
                
                //通知確認できていない
                notification(title:siteInfo.siteTitle,message:newArticleInfo.title)
                
                newArticleInfo.thumbImageData = getImageData(code: newArticleInfo.description)
                
               print(newArticleInfo.pubDate)
                writeArticleInfo(siteID:siteInfo.siteID,articleTitle:newArticleInfo.title,updateDate:newArticleInfo.pubDate!,articleURL:newArticleInfo.link,thumbImageData:newArticleInfo.thumbImageData,fav:false,read:false)
            }
            self.endFunc = false
        }
        print("テスト:rssUpdate完了")
    }
    func startDownload(siteURL:String){
        print("テスト:\(siteURL)の更新開始")
        //古いデータと記事が重複しないように、空にする
        self.items = []
        
        //URLがあれば解析.
        if let url = URL(
            string: siteURL){
            if let parser = XMLParser(contentsOf:url){//XMLparserのインスタンス作成。
                self.parser = parser
                self.parser.delegate = self
                self.parser.parse()
            }
        }
    }
    
    //開始タグが見つかるたびに毎回呼び出される関数
    func parser(_ parser: XMLParser,didStartElement elementName:String,namespaceURI:String?,qualifiedName qName:String?,attributes attributeDict:[String:String]) {
        if self.endFunc == false{
            self.currentString = ""
            //print(elementName)//タグすべてプリント
            if elementName == "item"{
                self.item = Item()//タグ名がitemのときのみ、記事を入れる箱を作成
            }
        }
    }
    
    //タグで囲まれた内容が見つかるたびに呼び出されるメソッド。
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.endFunc == false{
            self.currentString = string
        }
    }
    
    //終了タグが見つかるたびに呼び出されるメソッド。
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if self.endFunc == false{
            switch elementName {
            case "title":
                self.item?.title = currentString
            case "link":
                self.item?.link = currentString
                if getSameArticle(articleURL: currentString).count != 0{
                    self.endFunc = true
                }
            case "pubDate":
                self.item?.pubDate = pubDate(pubDate: currentString)
            case "dc:date":
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let getDate = dateFormatter.date(from: currentString)
                self.item?.pubDate = getDate
            case "description":
                self.item?.description = currentString
            case "item": self.items.append(self.item!)
            default :break
            }
        }
    }
    

    
    
    //解析後myTableViewをリロードする.
    func parserDidEndDocument(_ parser: XMLParser){
        print("テスト:RSS解析後の更新完了")
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
