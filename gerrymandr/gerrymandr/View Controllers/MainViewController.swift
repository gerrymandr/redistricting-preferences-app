//
//  ViewController.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 10/22/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import UIKit
import Koloda
import MapKit

class MainViewController: UIViewController, KolodaViewDelegate, KolodaViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var kolodaView: KolodaView!
   
    let dMan = DistrictManager.sharedInstance
    let awsMan = AWSManager.sharedInstance
    
    var cardView = Bundle.main.loadNibNamed("CardView", owner: nil, options: nil)![0] as! UIView
    var district: District?
    
    var polygons = [MKPolygon]()
    var region: MKMapRect?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent}
    
    let themeColor = UIColor(red: 88.0/256, green: 186.0/256, blue: 157.0/256, alpha: 1.0)
    let fillColor = UIColor(red: 88.0/256, green: 186.0/256, blue: 157.0/256, alpha: 0.5)
    let lineThickness: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        
        (cardView.viewWithTag(1)?.viewWithTag(3) as! UIButton).addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        (cardView.viewWithTag(7) as! MKMapView).delegate = self
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
                
        NotificationCenter.default.addObserver(forName: NSNotification.Name("LoggedOut"), object: nil, queue: nil){
            note in
            UIApplication.shared.keyWindow!.rootViewController!.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func buttonTapped(){
        self.performSegue(withIdentifier: "showInfo", sender: nil)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right{
            district!.fair = true
        }
        district!.stoppedViewing = Date()
        
        awsMan.submitDistrictEval(district: district!)
        
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        district = dMan.getRandomDistrict()
        koloda.resetCurrentCardIndex()
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 1
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if let dist = district{
            configureView(district: dist)
        }
        else{
            district = dMan.getRandomDistrict()
            configureView(district: district!)
        }
        return self.cardView
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CustomOverlayView", owner: nil, options: nil)?[0] as? OverlayView
    }
    
    func configureView(district: District){
        let map = cardView.viewWithTag(7) as! MKMapView
        let barView = cardView.viewWithTag(1)!
        let label = barView.viewWithTag(2) as! UILabel
        
        
        var minX = Double.infinity
        var minY = Double.infinity
        var spanX = 0.0
        var spanY = -0.0
        
        if self.polygons.count > 0{
            map.removeOverlays(self.polygons)
            self.polygons.removeAll()
        }
        
        let tile = MKTileOverlay(urlTemplate: nil)
        tile.canReplaceMapContent = true
        map.add(tile)
        
        for shape in district.coordinates{
            var mapPoints = [MKMapPoint]()
            for location in shape{
                
                let mp = MKMapPointForCoordinate(location.coordinate)
                mapPoints.append(mp)
                
                if mp.x < minX{
                    if spanX != 0.0{
                        spanX = spanX + minX - mp.x
                    }
                    minX = mp.x
                }
                if mp.y < minY{
                    if spanY != 0.0{
                        spanY = spanY + minY - mp.y
                    }
                    
                    minY = mp.y
                }
                if mp.y - minY > spanY{
                    spanY = mp.y - minY
                }
                if mp.x - minX > spanX{
                    spanX = mp.x - minX
                }
                
            }
            let overlay = MKPolygon(points: mapPoints, count: mapPoints.count)
            map.add(overlay)
            self.polygons.append(overlay)
        }
        
        region = MKMapRectMake(minX, minY, spanX, spanY)
        map.setVisibleMapRect(region!, edgePadding: UIEdgeInsets(top: 10, left:10, bottom:10, right:10), animated: false)
        
        label.text = "Mystery District #" + String(district.id)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polygon = overlay as? MKPolygon{
            
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = themeColor
            renderer.lineWidth = lineThickness
            renderer.fillColor = fillColor
            
            return renderer
        }
        
        return BlankRenderer(overlay: overlay)
    }
    @IBAction func fairButtonClicked(_ sender: Any) {
        kolodaView.swipe(.right)
    }
    @IBAction func unfairButtonClicked(_ sender: Any) {
        kolodaView.swipe(.left)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfo"{
            let dest = ((segue.destination as! UINavigationController).viewControllers[0] as! InfoTableViewController)
            dest.currentDistrict = district
            dest.overlays = polygons
            dest.region = region
        }
    }
    
}

class BlankRenderer: MKOverlayRenderer{
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let rect = self.rect(for: mapRect)
        context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        context.fill(rect)
    }
}
