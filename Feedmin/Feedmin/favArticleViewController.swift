//
//  favArticleViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
import WebKit
import GoogleMobileAds

class favArticleViewController: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var favWebView: WKWebView!
    @IBOutlet weak var favProgressView: UIProgressView!
    var link:String!
    
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
        
        //監視の設定
        self.favWebView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.favWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        if let url = URL(string: self.link){
            let request = URLRequest(url:url)
            self.favWebView.load(request)
        }
        
        
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
        self.favWebView.addSubview(admobView)
        print("広告コード終了")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tabbarheight = tabBarController?.tabBar.frame.size.height
        self.admobView.frame.origin = CGPoint(x: 0, y: self.favWebView.frame.size.height - self.admobView.frame.height - tabbarheight!)
    }
    
    
    @IBAction func favArticleShare(_ sender: UIBarButtonItem) {
        let controller = UIActivityViewController(activityItems: [URL(string: self.link)], applicationActivities:nil)
        
        //iPadでエラーが出ないようにする
        controller.popoverPresentationController?.sourceView = self.view
        
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
