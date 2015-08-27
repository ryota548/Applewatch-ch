//
//  InterfaceController.swift
//  AppleWatch-ch WatchKit Extension
//
//  Created by 小芝　涼太　 on 2015/08/26.
//  Copyright (c) 2015年 ryota_koshiba. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!
    
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
    
    var timer: NSTimer?
    

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        lastDate = NSDate()
        lastWater = NSDate()
        hiryou = false
        status = .Wakaba
        numFluit = 0
        score = 0
        
        //現在の状態を復帰する
        loadState()
        
        //最初の状態を作成する
        updateStatus()
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "updateState", userInfo: nil, repeats: true)
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        timer?.invalidate()
        super.didDeactivate()
    }

    @IBAction func onMenu1Select(){
        //水をやるメニュー
        println("水あげたよ")
        //時刻をアップデートする
        lastWater = NSDate()
        //新しい状態を作成する
        updateStatus()
    }
    
    @IBAction func onMenu2Select(){
        //肥料をやるメニュー
        println("肥料あげたよ")
        if status == .Seiboku{
            //肥料をやった
            hiryou = true
            //新しい状態を作成する
            updateStatus()
        }
    }
    
    @IBAction func onMenu3Select(){
        //収穫するメニュー
        println("収穫したよ")
        if status == .Seiboku{
            //スコアを増やす
            score = score! + numFluit!
            
            //肥料と収穫をクリア
            hiryou = false
            numFluit = 0
            
            //新しい状態を作成する
            updateStatus()
        }

    }
    
    func saveState(){
        //現在の状態を保存する
        var usrDef: NSUserDefaults = NSUserDefaults(suiteName: "group.applewatch-ch")!
        usrDef.setObject(lastDate, forKey: "DATE")
        usrDef.setObject(lastWater, forKey: "WATER")
        usrDef.setBool(hiryou!, forKey: "HIRYOU")
        usrDef.setInteger(status!.rawValue, forKey: "STATUS")
        usrDef.setInteger(numFluit!, forKey: "FLUIT")
        usrDef.setInteger(score!, forKey: "SCORE")
        
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
    
    func updateStatus(){
        //タイマーから実行される
        
        //経過時間を取得
        var current: NSDate = NSDate()
        //最後に成長してから
        var deltaDate: Double = current.timeIntervalSinceDate(lastDate!)
        //最後に水をやってから
        var deltaWater: Double = current.timeIntervalSinceDate(lastWater!)
        println(deltaDate)
        println(deltaWater)
        
        let sendData = ["sendmessage": "contents"]
        WKInterfaceController.openParentApplication(sendData as [NSObject:AnyObject] ,reply: { (replyinfo, error) -> Void in
            var teststr:String = replyinfo["App3"]  as! String
            // スコアを表示する
            self.label.setText("\(teststr) steps")
            println(teststr)
        })
        
        if deltaWater > 1*60{
            //枯れ木状態に
            status = .Kareki
        }
        
        //若葉か成長途中で、８分以上経っていたら
        if (status == .Wakaba || status == .Totyuu) && deltaDate > 1*60{
            if status == .Wakaba{
                status = .Totyuu
            }else{
                status = .Seiboku
            }
            //最後の成長の時刻を更新
            lastDate = NSDate()
        }
        
        if status == .Seiboku && hiryou! && deltaDate > 60{
            //果物の数を増やす
            numFluit = numFluit! + 1
            //最後の成長の時刻を更新
            lastDate = NSDate()
        }
        
        saveState()
        
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
    
    
}
