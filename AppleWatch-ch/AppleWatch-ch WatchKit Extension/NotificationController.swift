//
//  NotificationController.swift
//  AppleWatch-ch WatchKit Extension
//
//  Created by 小芝　涼太　 on 2015/08/26.
//  Copyright (c) 2015年 ryota_koshiba. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {
    
    var lastDate: NSDate? //最後に成長した時刻
    var lastWater: NSDate? //最後に水をやった時刻
    var hiryou: Bool? //肥料をやったか
    
    //植物の状態を表す列挙列
    enum PlantStatus: Int {
        case Wakaba = 1
        case Totyuu = 2
        case Seiboku = 3
        case Kareki = 4
    }
    
    var status: PlantStatus? //状態
    var numFluit: Int? //果物の数
    var score: Int? //スコア
    
    @IBOutlet var image: WKInterfaceImage!

    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
        recieved()
    }
    
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
        recieved()
    }
    
    func recieved(){
        
        lastDate = NSDate()
        lastWater = NSDate()
        hiryou = false
        status = .Wakaba
        numFluit = 0
        score = 0
        
        //現在の状態を復帰する
        loadState()
        
        switch status!
        {
        case .Wakaba:
            image.setImageNamed("WAKABA")
        case .Totyuu:
            image.setImageNamed("TOTYUU")
        case .Kareki:
            image.setImageNamed("KAREKI")
        case .Seiboku:
            //画像を読み込む
            var img1: UIImage? = UIImage(named: "SEIBOKU")
            var img2: UIImage? = UIImage(named: "FLUIT")
            //サイズを取得
            var size: CGSize? = img1?.size
            
            if size != nil{
                //ここに処理を記述
                UIGraphicsBeginImageContext(size!)
                
                //背景に成木を描写
                var rect: CGRect = CGRectMake(0, 0, size!.width, size!.height)
                img1?.drawInRect(rect)
                
                //果物を描写する場所
                var x: CGFloat = 0
                var y: CGFloat = 0
                //果物の数だけ描写する
                for var n:Int = 1; n <= numFluit; n++ {
                    //現在の場所に描写
                    var point: CGPoint = CGPointMake(x, y)
                    img2?.drawAtPoint(point)
                    //描写する場所をずらす
                    x += size!.width/4
                    if n > 0 && n % 4 == 0{
                        //１段につき４個描写し次の段へ
                        x = 0
                        y += size!.height/3
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
    }
    
    func loadState(){
        //現在の状態を復帰する
        var usrDef: NSUserDefaults = NSUserDefaults(suiteName: "group.applewatch-ch")!
        
        var date: NSDate? = usrDef.objectForKey("DATE") as? NSDate
        if date != nil {
            lastDate = date
        }
        var water: NSDate? = usrDef.objectForKey("WATER") as? NSDate
        if water != nil {
            lastWater = water
        }
        var st: Int? = usrDef.integerForKey("STATUS")
        if st != nil {
            status = PlantStatus(rawValue: st!)
            if status == nil{
                status = .Wakaba
            }
        }
        var fl: Int? = usrDef.integerForKey("FLUIT")
        if fl != nil {
            numFluit = fl!
        }
        var hi: Bool? = usrDef.boolForKey("HIRYOU")
        if hi != nil {
            hiryou = hi!
        }
        var sc: Int? = usrDef.integerForKey("SCORE")
        if sc != nil {
            score = sc!
        }
    }


}
