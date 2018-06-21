//
//  coreData.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import CoreData

//ArticleInfoへのデータの書き込み
func writeArticleInfo(siteID:Int,articleTitle:String,updateDate:Date,articleURL:String,thumbImageData:NSData,fav:Bool){
    //print("writeArticleInfoのCoreDataへの登録")
    //AppDelegateを使う用意をしておく
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //Articleエンティティオブジェクト作成
    let articleInfo = NSEntityDescription.entity(forEntityName: "ArticleInfo", in: viewContext)
    //Articleエンティティに挿入するためのオブジェクトを作成
    let newRecode = NSManagedObject(entity: articleInfo!, insertInto: viewContext)
    //値のセット
    newRecode.setValue(siteID, forKey: "siteID")
    newRecode.setValue(articleTitle, forKey: "articleTitle")
    newRecode.setValue(updateDate, forKey: "updateDate")
    newRecode.setValue(articleURL, forKey: "articleURL")
    newRecode.setValue(thumbImageData, forKey: "thumbImageData")
    newRecode.setValue(fav, forKey: "fav")
    do{
        //レコード(行)の即時保存
        try viewContext.save()
        //print("ArticleInfo登録完了")
    }catch{
        print("error")
    }
}

//Articleのデータ読み込み用
func readArticleInfo()->[articleInfo]{
    var InfoList:[articleInfo] = []
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<ArticleInfo> = ArticleInfo.fetchRequest()
    do{
        //データを一括取得
        let fetchResults = try! viewContext.fetch(query)
        //データの取得
        for result:AnyObject in fetchResults{
            //print("読み込めた?\(result)")
            //print("テスト:\(result.value(forKey:"thumbImageData")! as! NSData)")
            InfoList.append(articleInfo(siteID:result.value(forKey:"siteID")! as! Int,articleTitle:result.value(forKey:"articleTitle")! as! String,updateDate:result.value(forKey:"updateDate")! as! Date,articleURL:result.value(forKey:"articleURL")! as! String,thumbImageData:result.value(forKey:"thumbImageData")! as! NSData,fav:result.value(forKey:"fav")! as! Bool))
        }
        for info in InfoList{
            print("テスト:[readArticleInfo]ID:\(info.siteID!),タイトル:\(info.articleTitle!),更新日時:\(info.updateDate!)")
        }
    }catch{
        print("error:readArticleInfo",error)
    }
    return InfoList as! [articleInfo]
}

//データ全削除(ArticleInfo)
func deleteAllArticleInfo(){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<ArticleInfo> = ArticleInfo.fetchRequest()
    do{
        //データを一括取得
        let fetchResults = try! viewContext.fetch(query)
        for result in fetchResults{
            let recode = result as! NSManagedObject
            viewContext.delete(recode)
        }
        //削除した状態を保存
        try viewContext.save()
    }catch{
        print("error")
    }
}

//SiteInfoへのデータの書き込み
func writeSiteInfo(siteID:Int,siteTitle:String,siteURL:String){
    print("SiteInfoのCoreDataへの登録")
    //AppDelegateを使う用意をしておく
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //SiteInfoエンティティオブジェクト作成
    let SiteInfo = NSEntityDescription.entity(forEntityName: "SiteInfo", in: viewContext)
    //SiteInfoエンティティに行を挿入するためのオブジェクトを作成
    let newRecode = NSManagedObject(entity: SiteInfo!, insertInto: viewContext)
    //値のセット
    newRecode.setValue(siteID, forKey: "siteID")
    newRecode.setValue(siteTitle, forKey: "siteTitle")
    newRecode.setValue(siteURL, forKey: "siteURL")
    do{
        //レコード(行)の即時保存
        try viewContext.save()
        print("SiteInfo登録完了")
    }catch{
        print("error")
    }
}

//SiteInfoのデータ読み込み用.[サイトタイトルとサイトURL]
func readSiteInfo()->[siteInfo]{
    var InfoList:[siteInfo] = []
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<SiteInfo> = SiteInfo.fetchRequest()
    do{
        //データを一括取得
        let fetchResults = try! viewContext.fetch(query)
        //データの取得
        for result:AnyObject in fetchResults{
            InfoList.append(siteInfo(siteID:result.value(forKey:"siteID")! as! Int,siteTitle:result.value(forKey:"siteTitle")! as! String,siteURL:result.value(forKey:"siteURL")! as! String))
        }
        for info in InfoList{
            print("[readSiteInfo]ID:\(info.siteID!),タイトル\(info.siteTitle!),URL\(info.siteURL!)")
        }
    }catch{
        print("error:readSiteInfo",error)
    }
    return InfoList as! [siteInfo]
}

//データ全削除(SiteInfo)
func deleteAllSiteInfo(){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<SiteInfo> = SiteInfo.fetchRequest()
    do{
        //データを一括取得
        let fetchResults = try! viewContext.fetch(query)
        for result in fetchResults{
            let recode = result as! NSManagedObject
            viewContext.delete(recode)
        }
        //削除した状態を保存
        try viewContext.save()
    }catch{
        print("error")
    }
}










