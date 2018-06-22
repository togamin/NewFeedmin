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
        
        
        //site情報読み込み
        self.siteInfoList = readSiteInfo()
        //記事情報読み込み
        self.articleInfoList = readArticleInfo()
        
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
    
    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func relode(_ sender: UIRefreshControl){
        queue.async {() -> Void in
            print("再読み込み")
            //新着記事を取得し、CoreDataに代入.
            self.rssUpdate()
            //記事再読み込み
            self.articleInfoList = readArticleInfo()
            //テーブルを再読み込みする。
            self.timeLineTableView.reloadData()
            //読込中の表示を消す。
            self.refreshControl?.endRefreshing()
        }
    }


    //行数を決める
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return articleInfoList.count
    }

    //セルのインスタンス化
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as! mainCellView
        cell.siteTitle.text = self.siteInfoList[(self.articleInfoList[indexPath.row].siteID!)].siteTitle
        cell.articleTitle.text = self.articleInfoList[indexPath.row].articleTitle
        cell.cellLink = self.articleInfoList[indexPath.row].articleURL
        cell.thumbView.image = UIImage(data:self.articleInfoList[indexPath.row].thumbImageData! as! Data)
        cell.currentLike = self.articleInfoList[indexPath.row].fav
        if (self.articleInfoList[indexPath.row].fav)!{
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
                
                newArticleInfo.thumbImageData = self.getImageData(code: newArticleInfo.description)
                
                writeArticleInfo(siteID:siteInfo.siteID,articleTitle:newArticleInfo.title,updateDate:newArticleInfo.pubDate!,articleURL:newArticleInfo.link,thumbImageData:newArticleInfo.thumbImageData,fav:false)
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
                self.item?.pubDate = self.pubDate(pubDate: currentString)
            case "description":
                self.item?.description = currentString
            case "item": self.items.append(self.item!)
            default :break
            }
        }
    }
    
    //pubDataの情報を扱いやすいデータに変換.
    //[Sun, 17 Jun 2018 12:00:22 +0000]を
    //[2018-06-17 12:00:22 +0000]に変換.
    func pubDate(pubDate:String)->Date?{
        //print("pubDate0:\(pubDate)")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
        let getDate = dateFormatter.date(from: pubDate)
        //print("pubDate1:\(getDate!)")
        return getDate
    }
    
    //textから<img>タグのURLを抜きだし、画像をNSDataとして出力.
    func getImageData(code:String)->NSData!{
        
        var result:UIImage!
        var thumbImageURL:String!
        var thumbImageData:NSData!
        
        let pattern1 = "<img(.*)/>"
        let pattern2 = "src=\"(.*?)\""
        //(.*)の部分を抜き出す.
        
        let str1:String = code
        //print(str1)
        
        let regex1 = try! NSRegularExpression(pattern: pattern1, options: .caseInsensitive)
        let regex2 = try! NSRegularExpression(pattern: pattern2, options: .caseInsensitive)
        
        //NSRegularExpression:挟まれた文字を抜き出す。
        //caseInsensitive:多文字と小文字を区別しない。
        //try!:エラーが発生した場合にクラッシュする。
        
        let matches1 = regex1.matches(in: str1, options: [], range: NSMakeRange(0, str1.characters.count))
        
        var str2:String!
        
        matches1.forEach { (match) -> () in
            str2 = (str1 as NSString).substring(with: match.range(at: 1))
        }
        //str2には[<img]~[/>]までの文字が入る.なければ[nil]
        //print("str2:\(str2)")
        
        if str2 != nil{
            //imgタグの中のURLの部分のみを取得
            let matches2 = regex2.matches(in: str2!, options: [], range: NSMakeRange(0, str2.characters.count))
            
            matches2.forEach { (match) -> () in
                thumbImageURL = (str2 as NSString).substring(with: match.range(at: 1))
            }
            let url = NSURL(string:thumbImageURL!)
            thumbImageData = NSData(contentsOf: url! as URL)
        }else if str2 == nil{
            thumbImageData = UIImageJPEGRepresentation(UIImage(named:"default01.png")!, 1.0)! as NSData//圧縮率
        }
        
        //print("画像のURL(getImageURL):\(thumbImageURL!)")
        return thumbImageData
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
