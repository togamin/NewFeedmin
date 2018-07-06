//
//  articleNumTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/25.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//


import UIKit

var articleNum:Int! = 20//UserDefaultに登録.20は初期値.


class articleNumTableViewController: UITableViewController {

    @IBOutlet var articleNumTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaultについて
        let myDefault = UserDefaults.standard
        if myDefault.object(forKey: "articleNum") != nil {
            articleNum = myDefault.object(forKey: "articleNum") as! Int
        }
    }
    //画面が表示されるたびに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleNumCell", for: indexPath)
        cell.textLabel?.text = "最新\((indexPath.row+1)*10)記事表示"
        
        if indexPath.row == articleNum/10 - 1{
            //チェックマークを入れる
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        
        
        return cell
    }
    //セルをタップしたら発動する処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)

        // UserDefaultに反映
        var myDefault = UserDefaults.standard
        myDefault.set((indexPath.row+1)*10, forKey: "articleNum")
        articleNum = myDefault.object(forKey: "articleNum") as! Int
        print(articleNum)
        
        self.articleNumTableView.reloadData()
        
        //チェックマークを入れる
        cell?.accessoryType = .checkmark
        
    }
    // セルの選択が外れた時に呼び出される
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at:indexPath)
        
        // チェックマークを外す
        cell?.accessoryType = .none
    }

}
