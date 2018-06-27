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
 ・インジケーター上手く行っていない
 
 */



import UIKit
import CoreData

class seturlTableViewController: UITableViewController,XMLParserDelegate {

    
    //TableView
    @IBOutlet var urlTableView: UITableView!
    
    //インジケータ
    var indicator: UIActivityIndicatorView!

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

        // インジケータの設定.表示されない.
        self.indicator = UIActivityIndicatorView()
        self.indicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        self.indicator.center = self.urlTableView.center// 表示位置
        //self.indicator.color = UIColor.green// 色の設定
        self.indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.indicator.hidesWhenStopped = true// アニメーション停止と同時に隠す設定
        urlTableView.addSubview(self.indicator)// 画面に追加
        urlTableView.bringSubview(toFront: self.indicator)// 最前面に移動
        //self.indicator.stopAnimating()//self.indicator.startAnimating()
        
        
        //Info全削除
        //deleteAllArticleInfo()
        //deleteAllSiteInfo()
        siteInfoList = readSiteInfo()

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
    
    //セルを横にスライドさせた時に呼ばれる
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        print("サイトを削除します")
        
        if siteInfoList.count > 1{
            //削除したURLの記事情報を削除
            deleteArticleInfo(siteID: indexPath.row)
            deleteSiteInfo(Index: indexPath.row)
            
            //tableから削除
            siteInfoList.remove(at: indexPath.row)
            
            //index.rowより大きいIDを1減らす。
            for i in indexPath.row + 1..<siteInfoList.count+1{
                updateSiteInfo(siteID: i)
                updateArticleInfo(siteID: i)
            }
            self.urlTableView.reloadData()
        }else{
            let alert = UIAlertController(title: "エラー", message: "登録しているサイトが1つの場合、削除できません。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in print("OK")}))
            alert.view.layer.cornerRadius = 25 //角丸にする。
            present(alert,animated: true,completion: {()->Void in print("URL削除時のエラー")})
        }
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
                    
                    //CoreDataに記事情報を保存
                    
                    writeArticleInfo(siteID:siteInfoList.count,articleTitle:self.items[i].title,updateDate:self.items[i].pubDate!,articleURL:self.items[i].link,thumbImageData:self.items[i].thumbImageData,fav:false,read:false)
                }
                siteInfoList = readSiteInfo()
                self.urlTableView.reloadData()
            }
            self.indicator.stopAnimating()
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
        }else{
            print("テストテスト2")
            //alertを作る
            let alert = UIAlertController(title: "対応していないURLです.", message:nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
            present(alert,animated: true,completion: {()->Void in print("表示されたよん")})//completionは動作完了時に発動。
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

    
    
    
/*RSS解析---------------------------------------------------*/


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
