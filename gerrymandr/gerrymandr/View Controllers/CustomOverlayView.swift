//
//  CustomOverlay.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 12/9/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import UIKit
import Koloda

class CustomOverlayView: OverlayView {

    @IBOutlet weak var label: UILabel!
    
    let fairColor = UIColor(red: 88.0/255, green: 186.0/255, blue: 157.0/255, alpha: 1.0)
    let unfairColor = UIColor(red: 244.0/255, green: 67.0/255, blue: 54.0/255, alpha: 1.0)
    
    override var overlayState: SwipeResultDirection?{
        didSet{
            switch overlayState{
                case .left?:
                    label.text = "Unfair!"
                    self.backgroundColor = unfairColor
                case .right?:
                    label.text = "Fair!"
                    self.backgroundColor = fairColor
                default:
                    label.text = "?"
            }
        }
    }
}

