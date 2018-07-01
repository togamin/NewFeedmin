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

class getRssFeedViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
    

    var searchResultList:[searchResult] = []
    @IBOutlet weak var rssResultTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tableView
        self.rssResultTableView.delegate = self
        self.rssResultTableView.dataSource = self
        
        //SearchBar
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Keyword,URL,Feedを入力してください"
    }
    //Searchボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        print("テスト検索文字:\(self.searchBar.text!)")
        self.searchFeed(query:self.searchBar.text!,resultNum:20)
        self.rssResultTableView.reloadData()
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
        alert.addAction(UIAlertAction(title: "登録", style: .default, handler: {action in getInfo()}))
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
                self.searchResultList.append(searchResult(title:json["results"][i]["title"].stringValue,feedID:json["results"][i]["feedId"].stringValue))
            }
            //print("テスト[rssInfoList]:\(self.searchResultList)")
            self.rssResultTableView.reloadData()
        }
        task.resume()
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
