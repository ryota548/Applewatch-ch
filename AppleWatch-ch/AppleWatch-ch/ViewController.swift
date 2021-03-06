//
//  ViewController.swift
//  AppleWatch-ch
//
//  Created by 小芝　涼太　 on 2015/08/26.
//  Copyright (c) 2015年 ryota_koshiba. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet var label:UILabel!
    @IBOutlet var image:UIImageView!
    
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
    var steps: NSNumber?//歩数
    
    var timer: NSTimer?
    
    var pedometer: CMPedometer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        
        lastDate = NSDate()
        lastWater = NSDate()
        hiryou = false
        status = .Wakaba
        numFluit = 0
        score = 0
        steps = 0
        pedometer = CMPedometer()
        
        //現在の状態を復帰する
        loadState()
        
        //最初の状態を作成する
        updateStatus()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "updateState", userInfo: nil, repeats: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //新しく通知の日時を作成する
        var interval :NSTimeInterval = 50
        var notifydate: NSDate = NSDate(timeInterval: interval, sinceDate: lastWater!)
        //現在の通知をクリアする
        var application: UIApplication = UIApplication.sharedApplication()
        application.cancelAllLocalNotifications()
        //ローカル通知を作成
        var notification: UILocalNotification = UILocalNotification()
        //通知の日時を設定
        notification.fireDate = notifydate
        notification.timeZone = NSTimeZone.localTimeZone()
        //通知のメッセージを作成
        notification.alertTitle = "水をあげよう！"
        notification.alertBody = "後10秒で死んじゃうよ"
        notification.category =  "applewatch"
        //通知に設定するデータ
        notification.userInfo = ["myKey":"Data"]
        //ローカル通知をシステムにスケジュールする
        application.scheduleLocalNotification(notification)
        
        println(deltaDate)
        println(deltaWater)
        
        if (CMPedometer.isStepCountingAvailable)(){//歩数測定ができるデバイスのときにtrueを返す。
            
            let fromDate = NSDate(timeIntervalSinceNow: -60 * 60 * 24)  //この日から
            let toDate = NSDate()  // この日まで。現在日時を取得する
            
            pedometer.queryPedometerDataFromDate(fromDate, toDate: toDate, withHandler: {(pedometerData:CMPedometerData!, error:NSError!) in
                if error==nil {
                    self.steps = pedometerData.numberOfSteps
                    // スコアを表示する
                    self.label.text = "Steps:\(self.steps!)"
                }
                
            })
        }
        
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
            image.image = UIImage(named:"WAKABA")
        case .Totyuu:
            image.image = UIImage(named:"TOTYUU")
        case .Kareki:
            image.image = UIImage(named:"KAREKI")
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
                image.image = img
                // 描写を終了
                UIGraphicsEndImageContext()
            }
        }
        
    }



}

