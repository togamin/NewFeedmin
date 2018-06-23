//
//  favArticleViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit

class favArticleViewController: UIViewController {

    @IBOutlet weak var favWebView: WKWebView!
    @IBOutlet weak var favProgressView: UIProgressView!
    var link:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //監視の設定
        self.favWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.favWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = URL(string: self.link){
            let request = URLRequest(url:url)
            self.favWebView.load(request)
        }
        
    }
    
    @IBAction func favArticleShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string: self.link)], applicationActivities:nil)
        self.present(controller, animated: true,completion:nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            self.favProgressView.setProgress(Float(self.favWebView.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.favWebView.isLoading
            if self.favWebView.isLoading {
                self.favProgressView.setProgress(0.1, animated: true)
            }else{
                //読み込みが終わったら0に
                self.favProgressView.setProgress(0.0, animated: false)
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
