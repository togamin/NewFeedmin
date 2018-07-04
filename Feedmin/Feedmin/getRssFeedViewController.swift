//
//  getRssFeedViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/07/01.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

struct searchResult {
    var title = ""
    var feedID = ""
    init(title:String,feedID:String){
        self.title = title
        self.feedID = feedID
    }
}

import UIKit
import CoreData

class getRssFeedViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,XMLParserDelegate{
    

    var searchResultList:[searchResult] = []
    @IBOutlet weak var rssResultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    //インジケーター
    var indicator: UIActivityIndicatorView!
    var indicatorView:UIView = UIView()
    
    //RSS解析用
    var parser:XMLParser!//parser:構文解析
    var items:[Item] = []//複数の記事を格納するための配列
    var item:Item?
    var currentString = ""
    var tagName:String! = ""
    
    //一時的に保存するための変数
    var tempTitle:String!
    var tempURL:String!
    
    //マルチスレッド用
    let queue:DispatchQueue = DispatchQueue(label: "com.togamin.queue")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        //tableView
        self.rssResultTableView.delegate = self
        self.rssResultTableView.dataSource = self
        
        //SearchBar
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Keyword,URL,Feedを入力してください"
        
        
        // インジケータの設定.
        //インジケーターを載せるView
        self.indicatorView.frame = CGRect(x: (self.view.bounds.width-50)/2, y: (self.view.bounds.height-50)/2, width: 50, height: 50)
        self.view.addSubview(indicatorView)
        self.indicatorView.backgroundColor = UIColor(red: 0, green: 0.02, blue: 0.06, alpha: 0.3)
        self.indicatorView.layer.cornerRadius = 15
        self.indicatorView.isHidden = true
        
        
        self.indicator = UIActivityIndicatorView(frame: CGRect(x: (indicatorView.bounds.width-100)/2, y: (indicatorView.bounds.height-100)/2, width: 100, height: 100))
        
        self.indicator.center = indicatorView.center// 表示位置
        self.indicator.color = UIColor(red: 0, green: 0.02, blue: 0.06, alpha: 0.9)// 色の設定
        self.indicator.hidesWhenStopped = true// アニメーション停止と同時に隠す設定
        self.view.addSubview(self.indicator)// 画面に追加
        self.view.bringSubview(toFront: self.indicator)// 最前面に移動
        
    
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    
    //Searchボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.indicatorView.isHidden = false
        self.indicator.startAnimating()
        print("テスト検索文字:\(self.searchBar.text!)")
        self.searchFeed(query:self.searchBar.text!,resultNum:20)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.rssResultTableView.reloadData()
            self.indicator.stopAnimating()
            self.indicatorView.isHidden = true
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchRSSCell", for: indexPath)
        if self.searchResultList.count != 0{
            cell.textLabel?.text = self.searchResultList[indexPath.row].title
            cell.detailTextLabel?.text = self.searchResultList[indexPath.row].feedID
        }
        return cell
    }
    
    //セルをタップしたら発動する処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        //alertを作る
        let alert = UIAlertController(title: "サイトURLの登録", message: "このサイトを登録しますか?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "登録", style: .default, handler: {action in
            getInfo()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in print("キャンセル")}))
        
        // テキストフィールドを追加
        alert.addTextField(configurationHandler: {(addTitleField: UITextField!) -> Void in
            addTitleField.text = self.searchResultList[indexPath.row].title
            addTitleField.placeholder = "タイトルを入力してください。"//プレースホルダー
        })
        alert.addTextField(configurationHandler: {(addURLField: UITextField!) -> Void in
            addURLField.text = self.searchResultList[indexPath.row].feedID
            addURLField.placeholder = "URLを入力してください。"//プレースホルダー
        })
        //その他アラートオプション
        alert.view.layer.cornerRadius = 25 //角丸にする。
        
        present(alert,animated: true,completion: {()->Void in print("表示されたよん")})//completionは動作完了時に発動。
        //登録したURLからRSSデータを取得.
        func getInfo(){
            print("URL取得します")
            self.indicatorView.isHidden = false
            self.indicator.startAnimating()
            
            
            self.tempTitle = alert.textFields![0].text!
            self.tempURL = alert.textFields![1].text!
            //self.tempURL = "https://togamin.com/feed/"
            self.startDownload(siteURL: self.tempURL)
            
            //itemsに何も入っていなければAlert
            //機能していないなぜ
                if items.count == 0{
                //alertを作る
                let alert = UIAlertController(title: "対応していないURLです.", message:nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                present(alert,animated: true,completion: {()->Void in print("表示されたよん")})//completionは動作完了時に発動。
            }else{
                //サイト情報をCoreDataに保存
                writeSiteInfo(siteID:siteInfoList.count,siteTitle:self.tempTitle,siteURL:self.tempURL,siteBool: true)
                for i in 0..<self.items.count{
                    
                
                    self.items[i].thumbImageData = getImageData(code: self.items[i].description)
                    
                    //万が一nilが入っていた場合
                    if self.items[i].thumbImageData == nil{
                        self.items[i].thumbImageData = UIImageJPEGRepresentation(UIImage(named:"default01.png")!, 1.0)! as NSData//圧縮率
                    }
                    
                    //CoreDataに記事情報を保存
                    
                    writeArticleInfo(siteID:siteInfoList.count,articleTitle:self.items[i].title,updateDate:self.items[i].pubDate!,articleURL:self.items[i].link,thumbImageData:self.items[i].thumbImageData,fav:false,read:false)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.indicator.stopAnimating()
                self.indicatorView.isHidden = true
            
            
                let alert = UIAlertController(title: "サイト登録完了しました.", message:nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(alert,animated: true,completion: {()->Void in print("表示されたよん")})
            }
            
        }
    }
    
    
    
    //入力したクエリに対する検索結果のサイトタイトルとfeedURLを返す。
    func searchFeed(query:String,resultNum:Int){
        self.searchResultList = []
        //日本語入りのURLの場合UTF8形式に変換する。
        var urlString:String = "http://cloud.feedly.com/v3/search/feeds?count=" + String(resultNum) + "&query=" + query
        let encodeurl:String = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        
        //print("テスト(サーチFeed):\(encodeurl)")
        let url = NSURL(string: encodeurl)!
        let request = URLRequest(url: url as URL)
        
        
        let task = URLSession.shared.dataTask(with: request) {
            (data:Data?,response:URLResponse?,error:Error?) in
            let json = try! JSON(data: data!)
            //print("テスト[json]:\(json)")
            
            for i in 0..<json["results"].count{
               
                //json["results"][i]["feedId"].stringValueの結果の最初の部分「feed/」を省く処理を入れる
                var feedIDnew:String = json["results"][i]["feedId"].stringValue
                feedIDnew = feedIDnew.replacingOccurrences(of:"feed/http", with:"http")
                feedIDnew = feedIDnew.replacingOccurrences(of:"/feed", with:"/rss")
                
                self.searchResultList.append(searchResult(title:json["results"][i]["title"].stringValue,feedID:feedIDnew))
            }
            //print("テスト[rssInfoList]:\(self.searchResultList)")
            self.rssResultTableView.reloadData()
        }
        task.resume()
    }
    
    /*RSS解析---------------------------------------------------*/
    //RSSを取得し解析する.
    //取得できなかった場合、「対応していないURLです」と返す(未).
    //この関数をグローバル関数にしたい.更新する場合にも呼び出したい(未).
    func startDownload(siteURL:String){
        print("テスト:\(siteURL)のダウンロード開始")
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
        }else{
            //alertを作る
            let alert = UIAlertController(title: "対応していないURLです.", message:nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            present(alert,animated: true,completion: {()->Void in print("表示されたよん")})//completionは動作完了時に発動。
        }
    }
    
    //開始タグが見つかるたびに毎回呼び出される関数
    func parser(_ parser: XMLParser,didStartElement elementName:String,namespaceURI:String?,qualifiedName qName:String?,attributes attributeDict:[String:String]) {
        
        self.currentString = ""
        self.tagName = elementName
        //print(elementName)//タグすべてプリント
        if elementName == "item" || elementName == "entry"{
            self.item = Item()//タグ名がitemのときのみ、記事を入れる箱を作成
        }
    }
    
    
    //タグで囲まれた内容が見つかるたびに呼び出されるメソッド。
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //print(self.tagName,string)
        if self.tagName == "title" || self.tagName == "description"{
            self.currentString += string
            //print("string\(string)")
        }else {
            self.currentString = string
        }
        //print("テストstring:\(string)")
    }
    
    //終了タグが見つかるたびに呼び出されるメソッド。
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            self.item?.title = currentString
            //print("テストtitle:\(self.item?.title)")
        case "link":
            self.item?.link = currentString
        case "pubDate":
            self.item?.pubDate = pubDate(pubDate: currentString)
        case "dc:date","updated":
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let getDate = dateFormatter.date(from: currentString)
            self.item?.pubDate = getDate
            //print(self.item?.pubDate)
            
        case "description","summary":
            self.item?.description = currentString
            //print("テストdescription:\(currentString)")
        case "item","entry": self.items.append(self.item!)
        default :break
        }
    }
    /*RSS解析---------------------------------------------------*/
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
