//
//  togaminViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/07/01.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit

class togaminViewController: UIViewController {

    @IBOutlet weak var togaminNav: UINavigationBar!
    @IBOutlet weak var togaminWebView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //監視の設定(progressView)
        self.togaminWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.togaminWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        if let url = URL(string:"https://togamin.com/"){
            let request = URLRequest(url:url)
            self.togaminWebView.load(request)
        }
       
    }
    

    @IBAction func togaminBlogShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string: "https://togamin.com/")], applicationActivities:nil)
        self.present(controller, animated: true,completion:nil)
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            self.progressView.setProgress(Float(self.togaminWebView.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.togaminWebView.isLoading
            if self.togaminWebView.isLoading {
                self.progressView.setProgress(0.1, animated: true)
            }else{
                //読み込みが終わったら0に
                self.progressView.setProgress(0.0, animated: false)
            }
        }
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}
