//
//  articleViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds

class articleViewController: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var articleWebView: WKWebView!
    var link:String!
    @IBOutlet weak var progressView: UIProgressView!
    
    // AdMob(アドセンス)
    let AdMobID = "ca-app-pub-6754000737510695/2034002134"
    let TestID = "ca-app-pub-3940256099942544/2934735716" // for test
    // Your TestDevice ID
    let DEVICE_ID = "FOSFMRTB216QH9IIKCG5RMUOI"
    let AdMobTest:Bool = false
    let SimulatorTest:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //監視の設定(progressView)
        self.articleWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.articleWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = URL(string: self.link){
            let request = URLRequest(url:url)
            self.articleWebView.load(request)
        }
        
        
        //広告の表示
        
        print("広告コード開始")
        var admobView: GADBannerView = GADBannerView()
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        admobView.frame.origin = CGPoint(x: 0, y: self.articleWebView.frame.size.height - admobView.frame.height - 49)
        admobView.frame.size = CGSize(width: self.articleWebView.frame.width, height: admobView.frame.height)
        
        admobView.adUnitID = AdMobID
        
        if AdMobTest {
            admobView.adUnitID  = TestID
        }
        else{
            admobView.adUnitID  = AdMobID
        }
        
        
        admobView.delegate = self
        admobView.rootViewController = self
        let admobRequest:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                admobRequest.testDevices = [kGADSimulatorID]
            }
            else {
                admobRequest.testDevices = [DEVICE_ID]
            }
        }
    
        admobView.load(admobRequest)
        self.articleWebView.addSubview(admobView)
        print("広告コード終了")

        
        
    }

    @IBAction func articleShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string:self.link)], applicationActivities:nil)
        
        //iPadでエラーが出ないようにする
        controller.popoverPresentationController?.sourceView = self.view
        
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
