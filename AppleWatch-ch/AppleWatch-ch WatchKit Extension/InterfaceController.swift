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
    

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
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

    @IBAction func onMenu1Select(){
        //水をやるメニュー
        
    }
    
    @IBAction func onMenu2Select(){
        //肥料をやるメニュー
        
    }
    
    @IBAction func onMenu3Select(){
        //収穫するメニュー
        
    }
}
