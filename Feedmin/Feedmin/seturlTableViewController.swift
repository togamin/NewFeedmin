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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Info全削除
        //deleteAllArticleInfo()
        //deleteAllSiteInfo()
        siteInfoList = readSiteInfo()

    }
    //画面が表示されるたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        siteInfoList = readSiteInfo()
        self.urlTableView.reloadData()
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
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteSite: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除"){ (action, index) -> Void in
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
                self.present(alert,animated: true,completion: {()->Void in print("URL削除時のエラー")})
            }
        }
        deleteSite.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.6)
        return [deleteSite]
    }
    
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goEditSite",sender:nil)
    }
    //画面遷移時に呼び出される
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        print("画面遷移中")
        if let indexPath = self.urlTableView.indexPathForSelectedRow{
            
            //遷移先のViewControllerを格納
            let controller = segue.destination as! EditSiteTableViewController
            
            print(siteInfoList[indexPath.row]?.siteTitle)
            
            //遷移先の変数に代入
            controller.siteTitle = siteInfoList[indexPath.row]?.siteTitle
            controller.siteID = siteInfoList[indexPath.row]?.siteID
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
