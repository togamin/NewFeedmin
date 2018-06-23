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
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //監視の設定(progressView)
        self.articleWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.articleWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = URL(string: self.link){
            let request = URLRequest(url:url)
            self.articleWebView.load(request)
        }
        
    }

    @IBAction func articleShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string:self.link)], applicationActivities:nil)
        self.present(controller, animated: true,completion:nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            self.progressView.setProgress(Float(self.articleWebView.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.articleWebView.isLoading
            if self.articleWebView.isLoading {
                self.progressView.setProgress(0.1, animated: true)
            }else{
                //読み込みが終わったら0に
                self.progressView.setProgress(0.0, animated: false)
            }
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
