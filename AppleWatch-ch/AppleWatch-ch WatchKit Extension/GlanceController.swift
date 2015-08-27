//
//  GlanceController.swift
//  AppleWatch-ch WatchKit Extension
//
//  Created by 小芝　涼太　 on 2015/08/26.
//  Copyright (c) 2015年 ryota_koshiba. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!
    

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        // 現在の状態を復帰する
        // 植物の状態
        var status: InterfaceController.PlantStatus?
        = InterfaceController.PlantStatus.Wakaba
        var usrDef: NSUserDefaults = NSUserDefaults(suiteName: "group.applewatch-ch")!
        var st: Int? = usrDef.integerForKey("STATUS")
        if st != nil {
            status = InterfaceController.PlantStatus(rawValue: st!)
            if status == nil {
                status = InterfaceController.PlantStatus.Wakaba
            }
        }
        // スコア
        var score: Int? = 0
        var sc: Int? = usrDef.integerForKey("SCORE")
        if sc != nil {
            score = sc!
        }
        var numFluit: Int? = 0
        var fl: Int? = usrDef.integerForKey("FLUIT")
        if fl != nil {
            numFluit = fl!
        }
        
        // 状態を表示する
        switch status!
        {
        case .Wakaba:
            image.setImageNamed("WAKABA")
        case .Totyuu:
            image.setImageNamed("TOTYUU")
        case .Kareki:
            image.setImageNamed("KAREKI")
        case .Seiboku:
            // 画像を読み込む
            var img1: UIImage? = UIImage(named:"SEIBOKU")
            var img2: UIImage? = UIImage(named:"FLUIT")
            // サイズを取得
            var size: CGSize? = img1?.size
            
            if size != nil {
                // 描写を開始
                UIGraphicsBeginImageContext(size!)
                
                // 背景に成木を描写
                var rect: CGRect = CGRectMake(0, 0, size!.width, size!.height)
                img1?.drawInRect(rect)
                // 果物を描写する場所
                var x: CGFloat = 0
                var y: CGFloat = 0
                // 果物の数だけ描写する
                for var n: Int = 1; n <= numFluit; n++ {
                    // 現在の場所に描写
                    var point: CGPoint = CGPointMake(x, y)
                    img2?.drawAtPoint(point)
                    // 描写する場所をずらす
                    x += size!.width / 4
                    if n > 0 && n % 4 == 0 {
                        // 一段につき4個描写し次の段へ
                        x = 0
                        y += size!.height / 3
                    }
                }
                // 描写結果を取得
                var img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
                // 描写結果を表示
                image.setImage(img)
                // 描写を終了
                UIGraphicsEndImageContext()
            }
        }
        // スコアを表示する
        label.setText("Score:\(score!)")
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }

}
