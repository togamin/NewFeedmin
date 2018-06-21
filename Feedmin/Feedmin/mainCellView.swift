//
//  mainCellView.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/21.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit

class mainCellView:UITableViewCell{
    
    @IBOutlet weak var siteTitle: UILabel!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var thumbView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    
    var cellLink:String!
    
    @IBOutlet weak var animalImage: UIImageView!
    var currentLike:Bool!
    
    @IBAction func favButtonA(_ sender: UIButton) {
        if currentLike {
            sender.setImage(UIImage(named:"fav02"), for: .normal)
            updateFav(articleURL:cellLink,bool:false)
            self.currentLike = false
        }else{
            sender.setImage(UIImage(named:"fav01"), for: .normal)
            updateFav(articleURL:cellLink,bool:true)
            self.currentLike = true
        }
    }
}
