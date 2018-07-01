//
//  FeedminViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/07/01.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit

class FeedminViewController: UIViewController {

    var FeedminLink:String!
    @IBOutlet weak var FeedminWebView: WKWebView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //監視の設定
        self.FeedminWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.FeedminWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = URL(string: self.FeedminLink){
            let request = URLRequest(url:url)
            self.FeedminWebView.load(request)
        }
    }
    
    
    @IBAction func FeedminShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string: self.FeedminLink)], applicationActivities:nil)
        self.present(controller, animated: true,completion:nil)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            self.progressBar.setProgress(Float(self.FeedminWebView.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.FeedminWebView.isLoading
            if self.FeedminWebView.isLoading {
                self.progressBar.setProgress(0.1, animated: true)
            }else{
                //読み込みが終わったら0に
                self.progressBar.setProgress(0.0, animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}
