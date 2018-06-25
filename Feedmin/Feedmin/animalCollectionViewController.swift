//
//  animalCollectionViewController.swift
//  Feedmin
//
//  Created by 戸上　祐希 on 2018/06/25.
//  Copyright © 2018年 Togami Yuki. All rights reserved.
//

import UIKit
//Userdefaultに保存.起動時に[animalNum]に入れる.
var animalNum:Int! = 0
var animalList:[UIImage!] = [UIImage(named:"animal01.png"),UIImage(named:"animal02.png"),UIImage(named:"animal03.png"),UIImage(named:"animal04.png"),UIImage(named:"animal05.png"),UIImage(named:"animal06.png"),UIImage(named:"animal07.png"),UIImage(named:"animal04.png"),UIImage(named:"animal04.png"),UIImage(named:"animal04.png")]

private let reuseIdentifier = "animalCell"

class animalViewCell:UICollectionViewCell{
    @IBOutlet weak var animalImageView: UIImageView!
}

class animalCollectionViewController: UICollectionViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    //データの個数を返す.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return animalList.count
    }
    
    //データを返すメソッド
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! animalViewCell
        cell.animalImageView.image = animalList[indexPath.row]
        if animalNum == indexPath.row{
            cell.backgroundColor = UIColor(red: 0, green: 0.02, blue: 0.5, alpha: 0.4)
        }else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    // アイテムタッチ時の処理（UICollectionViewDelegate が必要）
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        animalNum = indexPath.row
        collectionView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
