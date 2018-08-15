//
//  IndividualArticleViewController.swift
//  Feedmin
//
//  Created by Togami Yuki on 2018/08/11.
//  Copyright © 2018 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds

class IndividualArticleViewController: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var progresss: UIProgressView!
    @IBOutlet weak var IndividualArticleWebView: WKWebView!
    var link:String!
    // Shareボタン
    var shareBtn: UIBarButtonItem!
    
    // AdMob(アドセンス)
    let AdMobID = "ca-app-pub-6754000737510695/2034002134"
    let TestID = "ca-app-pub-3940256099942544/2934735716" // for test
    // Your TestDevice ID
    let DEVICE_ID = "FOSFMRTB216QH9IIKCG5RMUOI"
    let AdMobTest:Bool = false
    let SimulatorTest:Bool = false
    var admobView: GADBannerView = GADBannerView()
    var tabbarheight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // shareBtnを設置
        self.shareBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action:"articleShare")
        
        self.navigationItem.rightBarButtonItem = self.shareBtn

        //監視の設定(progressView)
        self.IndividualArticleWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.IndividualArticleWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        print("テストテスト")
        if let url = URL(string: self.link){
            let request = URLRequest(url:url)
            self.IndividualArticleWebView.load(request)
        }
        
        //広告の表示
        
        print("広告コード開始")
        //スクリーンサイズの取得
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        let customAdSize = GADAdSizeFromCGSize(CGSize(width: myBoundSize.width, height: 60))
        self.admobView = GADBannerView(adSize:customAdSize)
        
        
        
        self.admobView.frame.size = CGSize(width: myBoundSize.width, height: self.admobView.frame.height)
        
        self.admobView.adUnitID = AdMobID
        
        if AdMobTest {
            self.admobView.adUnitID  = TestID
        }
        else{
            self.admobView.adUnitID  = AdMobID
        }
        
        
        self.admobView.delegate = self
        self.admobView.rootViewController = self
        let admobRequest:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                admobRequest.testDevices = [kGADSimulatorID]
            }
            else {
                admobRequest.testDevices = [DEVICE_ID]
            }
        }
        self.admobView.load(admobRequest)
        self.IndividualArticleWebView.addSubview(admobView)
        print("広告コード終了")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabbarheight = tabBarController?.tabBar.frame.size.height
        self.admobView.frame.origin = CGPoint(x: 0, y: self.IndividualArticleWebView.frame.size.height - self.admobView.frame.height/* - tabbarheight!*/)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            //estimatedProgressが変更されたときに、setProgressを使ってプログレスバーの値を変更する。
            self.progresss.setProgress(Float(self.IndividualArticleWebView.estimatedProgress), animated: true)
        }else if keyPath == "loading"{
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.IndividualArticleWebView.isLoading
            if self.IndividualArticleWebView.isLoading {
                self.progresss.setProgress(0.1, animated: true)
            }else{
                //読み込みが終わったら0に
                self.progresss.setProgress(0.0, animated: false)
            }
        }
    }
    
    @objc func articleShare() {
        let controller = UIActivityViewController(activityItems: [URL(string: self.link)], applicationActivities:nil)
        
        //iPadでエラーが出ないようにする
        controller.popoverPresentationController?.sourceView = self.view
        
        self.present(controller, animated: true,completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
