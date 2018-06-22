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
