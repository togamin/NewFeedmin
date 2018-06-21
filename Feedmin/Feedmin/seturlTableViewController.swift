//
//  seturlTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

/*
 このプログラムの概要
 ・urlの登録
 ・RSSデータを取得できれば記事情報取得しCoreDataに登録.
 ・取得できなければ、対応していないURLであると通知.
 
 
 */



import UIKit
import CoreData

class seturlTableViewController: UITableViewController,XMLParserDelegate {

    
    //TableView
    @IBOutlet var urlTableView: UITableView!
    
    
    //一時的に保存するための変数
    var tempTitle:String!
    var tempURL:String!
    
    //RSS解析用
    var parser:XMLParser!//parser:構文解析
    var items:[Item] = []//複数の記事を格納するための配列
    var item:Item?
    var currentString = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ArticleInfo全削除
        deleteAllArticleInfo()
        deleteAllSiteInfo()

    }
    
    //行数を決める
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return siteInfoList.count
    }
    
    //セルの内容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "urlCell",for:indexPath)
        
        cell.textLabel?.text =  siteInfoList[indexPath.row]?.siteTitle
        cell.detailTextLabel?.text = siteInfoList[indexPath.row]?.siteURL
        return cell
    }
    
    //urlを追加するためのボタン
    @IBAction func addURL(_ sender: UIBarButtonItem) {
        
        //alertを作る
        let alert = UIAlertController(title: "サイトURLの登録", message: "タイトルとURLを入力してください。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "登録", style: .default, handler: {action in getInfo()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in print("キャンセル")}))
        
        // テキストフィールドを追加
        alert.addTextField(configurationHandler: {(addTitleField: UITextField!) -> Void in
            addTitleField.placeholder = "タイトルを入力してください。"//プレースホルダー
        })
        alert.addTextField(configurationHandler: {(addURLField: UITextField!) -> Void in
            addURLField.placeholder = "URLを入力してください。"//プレースホルダー
        })
        //その他アラートオプション
        alert.view.layer.cornerRadius = 25 //角丸にする。
        
        present(alert,animated: true,completion: {()->Void in print("表示されたよん")})//completionは動作完了時に発動。
        
        //登録したURLからRSSデータを取得.
        func getInfo(){
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
            }else{
                //サイト情報をCoreDataに保存
                writeSiteInfo(siteID:siteInfoList.count,siteTitle:self.tempTitle,siteURL:self.tempURL)
                for i in 0..<self.items.count{
                    self.items[i].thumbImageData = self.getImageData(code: self.items[i].description)
                    
                    //CoreDataに記事情報を保存
                    
                    writeArticleInfo(siteID:siteInfoList.count,articleTitle:self.items[i].title,updateDate:self.items[i].pubDate!,articleURL:self.items[i].link,thumbImageData:self.items[i].thumbImageData,fav:false)
                }
                siteInfoList = readSiteInfo()
                self.urlTableView.reloadData()
            }
        }
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
        }
    }
    
    //開始タグが見つかるたびに毎回呼び出される関数
    func parser(_ parser: XMLParser,didStartElement elementName:String,namespaceURI:String?,qualifiedName qName:String?,attributes attributeDict:[String:String]) {
        
        self.currentString = ""
        //print(elementName)//タグすべてプリント
        if elementName == "item"{
            self.item = Item()//タグ名がitemのときのみ、記事を入れる箱を作成
        }
    }
    
    //タグで囲まれた内容が見つかるたびに呼び出されるメソッド。
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString = string
    }
    
    //終了タグが見つかるたびに呼び出されるメソッド。
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "title":
            self.item?.title = currentString
        case "link":
            self.item?.link = currentString
        case "pubDate":
            self.item?.pubDate = self.pubDate(pubDate: currentString)
        case "description":
            self.item?.description = currentString
        case "item": self.items.append(self.item!)
        default :break
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
    
    //解析後myTableViewをリロードする.
    func parserDidEndDocument(_ parser: XMLParser){
        print("テスト:RSS解析後のリロード完了")
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
            thumbImageData = UIImageJPEGRepresentation(UIImage(named:"default.png")!, 1.0)! as NSData//圧縮率
        }
        
        //print("画像のURL(getImageURL):\(thumbImageURL!)")
        return thumbImageData
    }
    
    
    
/*RSS解析---------------------------------------------------*/


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
