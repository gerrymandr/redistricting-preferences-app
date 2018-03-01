//
//  LoginViewController.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 12/10/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let manager = AWSManager.sharedInstance
    let headers = ["Evaluate the fairness of districts.", "Swipe right if fair, left if not.", "View a full map.", "Get demographic information."]
    let images = ["photo1", "photo2", "photo3", "photo4"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController.dataSource = self
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-100)
        pageViewController.setViewControllers([getWalkthroughVCAt(index: 0)!], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        
        self.view.sendSubview(toBack: pageViewController.view)
        NotificationCenter.default.addObserver(forName: NSNotification.Name("LoggedIn"), object: nil, queue: nil){
            [unowned self] note in
            self.performSegue(withIdentifier: "loginCompleted", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getWalkthroughVCAt(index: Int) -> WalkthroughViewController?{
        if index >= headers.count || index < 0{
            return nil
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "walkthroughVC") as! WalkthroughViewController
        vc.prompt = headers[index]
        vc.imageName = images[index]
        vc.index = index
        
        return vc
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return headers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? WalkthroughViewController)?.index else{
            return nil
        }
        
        index = index - 1
        
        return getWalkthroughVCAt(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? WalkthroughViewController)?.index else{
            return nil
        }
        
        index = index + 1
        
        return getWalkthroughVCAt(index: index)
    }
    
}
