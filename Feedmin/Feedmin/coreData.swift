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
    //ascendind:true 昇順、false 降順
    let sortDescripter = NSSortDescriptor(key: "updateDate", ascending: false)
    query.sortDescriptors = [sortDescripter]
    //フェッチ件数を15件に制限する。
    query.fetchLimit = 15
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

//指定したIDの記事情報を削除
func deleteArticleInfo(siteID:Int){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<ArticleInfo> = ArticleInfo.fetchRequest()
    //絞り込み検索
    let namePredicte = NSPredicate(format: "%K = %d","siteID",siteID)
    query.predicate = namePredicte
    do{
        //データを一括取得
        let featchResults = try! viewContext.fetch(query)
        //データの取得
        for result:AnyObject in featchResults{
            let recode = result as! NSManagedObject
            viewContext.delete(recode)
            
            print("[deleteArticleInfo]siteID:\(result.value(forKey:"siteID")! as! Int),siteTitle:\(result.value(forKey:"articleTitle")! as! String)")
            
            //削除した状態を保存
            try viewContext.save()
        }
    }catch{
        print("error[deleteArticleInfo]")
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

//指定した行のデータの削除
func deleteSiteInfo(Index:Int){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<SiteInfo> = SiteInfo.fetchRequest()
    do{
        //データを一括取得
        let fetchResults = try! viewContext.fetch(query)
        let deleteInfo = fetchResults[Index]
        viewContext.delete(deleteInfo)
        //削除した状態を保存
        try viewContext.save()
    }catch{
        print("error")
    }
}

//データの更新.SiteInfoのsiteIDを1低い値に更新する
func updateSiteInfo(siteID:Int){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<SiteInfo> = SiteInfo.fetchRequest()
    
    //絞り込み検索
    let namePredicte = NSPredicate(format: "%K = %d","siteID",siteID)
    query.predicate = namePredicte
    do{
        //データを一括取得
        let featchResults = try! viewContext.fetch(query)
        
        //データの取得
        for result:AnyObject in featchResults{
            let recode = result as! NSManagedObject
            //更新したいデータのセット
            recode.setValue(siteID - 1,forKey:"siteID")
            do{
                //レコード(行)の即時保存
                try viewContext.save()
            }catch{
                
            }
        }
    }
}

//データの更新.ArticleInfoのsiteIDを1低い値に更新する
func updateArticleInfo(siteID:Int){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<ArticleInfo> = ArticleInfo.fetchRequest()
    
    //絞り込み検索
    let namePredicte = NSPredicate(format: "%K = %d","siteID",siteID)
    query.predicate = namePredicte
    do{
        //データを一括取得
        let featchResults = try! viewContext.fetch(query)
        
        //データの取得
        for result:AnyObject in featchResults{
            
            let recode = result as! NSManagedObject
            //更新したいデータのセット
            recode.setValue(siteID - 1,forKey:"siteID")
            
            print("[updateArticleInfo]siteID:\(result.value(forKey:"siteID")! as! Int),siteTitle:\(result.value(forKey:"articleTitle")! as! String)")
            
            do{
                //レコード(行)の即時保存
                try viewContext.save()
            }catch{
                
            }
        }
    }
}

//お気に入りかどうかの更新
func updateFav(articleURL:String,bool:Bool){
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<ArticleInfo> = ArticleInfo.fetchRequest()
    let namePredicte = NSPredicate(format: "articleURL = %@",articleURL)
    query.predicate = namePredicte
    do{
        //絞り込んだデータを一括取得
        let fetchResults = try! viewContext.fetch(query)
        for result in fetchResults{
            result.setValue(bool,forKey:"fav")
            //変更した記事のタイトルと変更後の状態の表示
            print("[updateFav]\(result.value(forKey:"articleTitle")! as! String)","\(result.value(forKey:"updateDate")!)")
            do{
                //レコード(行)の即時保存
                try viewContext.save()
            }catch{
            }
        }
    }catch{
        print("error:updateFav",error)
    }
}

//お気に入りの記事のみ取り出し.
func readFav()->[articleInfo]{
    var InfoList:[articleInfo] = []
    //AppDelegateを使う用意をしておく
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //Entityを操作するためのオブジェクトを作成
    let viewContext = appDelegate.persistentContainer.viewContext
    //どのエンティティからdataを取得してくるかの設定
    let query:NSFetchRequest<ArticleInfo> = ArticleInfo.fetchRequest()
    let namePredicte = NSPredicate(format: "fav = true")
    query.predicate = namePredicte
    //ascendind:true 昇順、false 降順
    let sortDescripter = NSSortDescriptor(key: "updateDate", ascending: false)
    query.sortDescriptors = [sortDescripter]
    //フェッチ件数を15件に制限する。
    query.fetchLimit = 15
    do{
        //絞り込んだデータを一括取得
        let fetchResults = try! viewContext.fetch(query)
        for result in fetchResults{
            InfoList.append(articleInfo(siteID:result.value(forKey:"siteID")! as! Int,articleTitle:result.value(forKey:"articleTitle")! as! String,updateDate:result.value(forKey:"updateDate")! as! Date,articleURL:result.value(forKey:"articleURL")! as! String,thumbImageData:result.value(forKey:"thumbImageData")! as! NSData,fav:result.value(forKey:"fav")! as! Bool))
        }
        for info in InfoList{
            print("[readFav]ID:\(info.siteID!),タイトル:\(info.articleTitle!),お気に入り:\(info.fav!)")
            //,URL:\(info.articleURL!),画像データ:\(info.thumbImageData!)
        }
    }catch{
        print("error:readFav",error)
    }
    return InfoList as [articleInfo]
}









