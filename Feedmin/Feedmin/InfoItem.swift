//
//  InfoItem.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

//siteの情報を格納するリスト
var siteInfoList:[siteInfo?] = []

//記事の情報を格納するリスト
var articleInfoList:[articleInfo?] = []

//取得したデータを一時的に保存する
class Item {
    var title = ""
    var link = ""
    var pubDate:Date?
    var description = ""
    var thumbImageData:NSData!
    var thumbImage:UIImage!
    var fav:Bool = false
}

//CoreDataからサイト情報を格納するための構造体
struct siteInfo{
    var siteID:Int!
    var siteTitle:String!
    var siteURL:String!
    var siteBool:Bool!
    
    init(siteID: Int, siteTitle: String,siteURL:String,siteBool:Bool) {
        self.siteID = siteID
        self.siteTitle = siteTitle
        self.siteURL = siteURL
        self.siteBool = siteBool
    }
}
//CoreDataからの記事情報を格納するための構造体
struct articleInfo{
    var siteID:Int!
    var updateDate:Date?
    var articleTitle:String!
    var articleURL:String!
    var thumbImageData:NSData!
    var fav:Bool!
    
    init(siteID: Int, articleTitle: String,updateDate:Date,articleURL: String,thumbImageData: NSData,fav: Bool) {
        self.siteID = siteID
        self.articleTitle = articleTitle
        self.updateDate = updateDate
        self.articleURL = articleURL
        self.thumbImageData = thumbImageData
        self.fav = fav
    }
}

//通知に関する関数
func notification(title:String,message:String){
    // ローカル通知の設定
    let notification : UILocalNotification = UILocalNotification()
    // タイトル
    notification.alertTitle = title
    // 通知メッセージ
    notification.alertBody = message
    // Timezoneの設定
    notification.timeZone = TimeZone.current
    // 5秒後に通知を設定
    notification.fireDate = Date(timeIntervalSinceNow: 5)
    // Notificationを表示する
    UIApplication.shared.scheduleLocalNotification(notification)
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
