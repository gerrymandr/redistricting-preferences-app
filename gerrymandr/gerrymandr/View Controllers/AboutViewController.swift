//
//  AboutViewController.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 3/3/18.
//  Copyright © 2018 mggg. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController{
    
    @IBOutlet var aboutView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Formats text to have links
        let attributed = NSMutableAttributedString(string: "Developed by the Metric Geometry and Gerrymandering Group.\n\nBuilt using Icons8, Koloda, and Charts.")
        attributed.addAttributes([NSAttributedStringKey.link: "https://sites.tufts.edu/gerrymandr/"], range: NSRange(location: 17, length: 40))
        attributed.addAttributes([NSAttributedStringKey.link: "https://icons8.com/"], range: NSRange(location: 72, length: 7))
        attributed.addAttributes([NSAttributedStringKey.link: "https://github.com/Yalantis/Koloda"], range: NSRange(location: 80, length: 6))
        attributed.addAttributes([NSAttributedStringKey.link: "https://github.com/danielgindi/Charts"], range: NSRange(location: 92, length: 6))

        
        aboutView.attributedText = attributed
        aboutView.textColor = UIColor.white
        aboutView.textAlignment = NSTextAlignment.center
        aboutView.font = UIFont(name: "System Font Regular", size: 18)
    }
}
