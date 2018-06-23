//
//  articleViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit

class articleViewController: UIViewController {

    @IBOutlet weak var articleWebView: WKWebView!
    var link:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: self.link){
            let request = URLRequest(url:url)
            self.articleWebView.load(request)
        }
        
    }

    @IBAction func articleShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string:self.link)], applicationActivities:nil)
        self.present(controller, animated: true,completion:nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
