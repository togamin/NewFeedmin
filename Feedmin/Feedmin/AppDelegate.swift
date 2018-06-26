//
//  AppDelegate.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,XMLParserDelegate {

    var window: UIWindow?
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // このアプリで通知（Local Notification）を使用する許可を
        // ユーザーに求めるためのコード
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.sound,UIUserNotificationType.alert,UIUserNotificationType.badge], categories: nil))
        
        //ナビゲーションの背景色変更
        UINavigationBar.appearance().barTintColor = UIColor(red: 0, green: 0.02, blue: 0.06, alpha: 0.9)
        //ナビゲーションタイトル色変更
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        //ナビゲーションアイテムの色を変更
        UINavigationBar.appearance().tintColor = .white
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //バックグラウンドで実行する処理
        notification(title:"テスト1",message:"テスト1")
        self.backGroundFetchRssUpdate()
        notification(title:"テスト2",message:"テスト2")
        //適切なものを渡します → 新規データ: .newData 失敗: .failed データなし: .noData
        completionHandler(.newData)
    }
//バックグラウンドで定期的に呼び出す関数.RSSデータを解析し、更新記事があれば通知.--------------
    func backGroundFetchRssUpdate(){
        self.siteInfoList = readSiteInfo()
        self.articleInfoList = readArticleInfo()
        for siteInfo in self.siteInfoList{
            startDownload(siteURL:siteInfo.siteURL)
            for newArticleInfo in self.items{
                notification(title:siteInfo.siteTitle,message:newArticleInfo.title)
                newArticleInfo.thumbImageData = self.getImageData(code: newArticleInfo.description)
                writeArticleInfo(siteID:siteInfo.siteID,articleTitle:newArticleInfo.title,updateDate:newArticleInfo.pubDate!,articleURL:newArticleInfo.link,thumbImageData:newArticleInfo.thumbImageData,fav:false)
            }
            self.endFunc = false
        }
    }
    func startDownload(siteURL:String){
        print("テスト:バックグラウンドフェッチ\(siteURL)の更新開始")
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
        print("テスト:RSS解析後のバックグランド更新完了")
    }
    
    
//-------------------------------------------------------------------------------

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Feedmin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

