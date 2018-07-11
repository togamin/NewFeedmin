//
//  EditSiteTableViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/07/11.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class EditSiteTableViewController: UITableViewController,UITextFieldDelegate {

    @IBOutlet weak var EditTitle: UITextField!
    var siteTitle:String!
    var siteID:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.EditTitle.text = siteTitle
        self.EditTitle.delegate = self
    }
    //画面タップでキーボード直す
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.EditTitle.resignFirstResponder()
    }
    
    //TextFieldで確定が押されたらキーボードを直す.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.EditTitle.resignFirstResponder()
        
        let alert = UIAlertController(title: "タイトルを変更しますか?.", message:nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) -> Void in
            updateSiteTitle(siteID:self.siteID,title:self.EditTitle.text!)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in print("キャンセル")
            self.EditTitle.text = self.siteTitle
            
        }))
        alert.view.layer.cornerRadius = 25 //角丸にする。
        present(alert,animated: true,completion: {()->Void in print("表示されたよん")})
        
        return true
    }
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
