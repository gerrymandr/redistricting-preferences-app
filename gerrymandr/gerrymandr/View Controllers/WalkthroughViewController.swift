//
//  WalkthroughView.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 12/10/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var promptLabel: UILabel!
    
    var imageName: String?
    var prompt: String?
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = imageName else{
            return
        }
        guard let _ = prompt else{
            return
        }
        
        imageView.image = UIImage(named: imageName!)
        promptLabel.text = prompt!
    }
    
}
