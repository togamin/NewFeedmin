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
var animalList:[UIImage!] = [UIImage(named:"animal01.png"),UIImage(named:"animal02.png"),UIImage(named:"animal03.png"),UIImage(named:"animal04.png"),UIImage(named:"animal05.png"),UIImage(named:"animal06.png"),UIImage(named:"animal07.png"),UIImage(named:"animal08.png"),UIImage(named:"animal09.png"),UIImage(named:"animal10.png"),UIImage(named:"animal11.png"),UIImage(named:"animal12.png"),UIImage(named:"animal13.png"),UIImage(named:"animal14.png"),UIImage(named:"animal15.png"),UIImage(named:"animal16.png"),UIImage(named:"animal17.png"),UIImage(named:"animal18.png"),UIImage(named:"animal19.png"),UIImage(named:"animal20.png"),UIImage(named:"animal21.png"),UIImage(named:"animal22.png"),UIImage(named:"animal23.png"),UIImage(named:"animal24.png"),UIImage(named:"animal25.png"),UIImage(named:"animal26.png"),UIImage(named:"animal27.png"),UIImage(named:"animal28.png"),UIImage(named:"animal29.png"),UIImage(named:"animal30.png"),UIImage(named:"animal31.png"),UIImage(named:"animal32.png"),UIImage(named:"animal33.png"),UIImage(named:"animal34.png")]

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
        
        var myDefault = UserDefaults.standard
        // UserDefaultにデータを書き込む
        myDefault.set(indexPath.row, forKey: "animalNum")
        
        animalNum = indexPath.row
        collectionView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
