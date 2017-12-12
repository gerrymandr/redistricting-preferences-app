//
//  InfoTableViewController.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 11/29/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import UIKit
import MapKit
import Charts

class InfoTableViewController: UITableViewController, MKMapViewDelegate {

    var currentDistrict: District?
    var selectedSection: Int? = nil
    var overlay: MKPolygon?
    var region: MKCoordinateRegion?
    
    var educationDataPoints = [PieChartDataEntry]()
    var raceDataPoints = [PieChartDataEntry]()
    
    let sections = ["Full Map", "Demographics", "Income", "Race", "Education"]
    let themeColor = UIColor(red: 88.0/256, green: 186.0/256, blue: 157.0/256, alpha: 1.0)
    let fillColor = UIColor(red: 88.0/256, green: 186.0/256, blue: 157.0/256, alpha: 0.5)
    let lineThickness: CGFloat = 1.0
    let raceLegend = ["White", "African American", "American Indian", "Asian", "Native Hawaiian"]
    let educationLegend = ["< HS", "HS", "Some College", "Associates", "Bachelors", "Grad"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        if let district = currentDistrict{
            if district.districtNumber == 0{
                self.title = district.state + " at large"
            }
            else{
                self.title = district.state+" \(district.districtNumber)"
            }
            var i = 0
            for edPoint in district.education{
                educationDataPoints.append(PieChartDataEntry(value: Double(edPoint), label: educationLegend[i]))
                i = i + 1
            }
            i = 0
            for racePoint in district.race{
                raceDataPoints.append(PieChartDataEntry(value: Double(racePoint), label: raceLegend[i]))
                i = i + 1
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == selectedSection{
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        view?.textLabel?.text = sections[section]
        view?.tag = section
        view?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sectionSelected)))
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 300
        }
        return 150
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func sectionSelected(recognizer: UITapGestureRecognizer){
        if selectedSection != recognizer.view?.tag{
            self.tableView.beginUpdates()
            
            if let sect = selectedSection{
                tableView.deleteRows(at: [IndexPath(row: 0, section: sect)], with: .automatic)
            }
            
            selectedSection = recognizer.view?.tag
            
            currentDistrict!.viewedStats[selectedSection!] = true
            
            self.tableView.reloadSections([selectedSection!], with: .fade)
            self.tableView.endUpdates()
        }
        else{

            self.tableView.beginUpdates()
            
            if let sect = selectedSection{
                tableView.deleteRows(at: [IndexPath(row: 0, section: sect)], with: .automatic)
            }
            selectedSection = nil
            self.tableView.endUpdates()
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let cell = tableView.dequeueReusableCell(withIdentifier: sections[section])!
        
        switch section {
        case 0:
            let map = cell.contentView.subviews[0] as! MKMapView
            map.delegate = self
            if let _ = overlay{
                map.add(overlay!)
            }
            if let _ = region{
                map.setRegion(region!, animated: false)
            }
            
        case 1:
            let stack = cell.contentView.subviews[0] as! UIStackView
            let popLabel = stack.arrangedSubviews[0].viewWithTag(2) as! UILabel
            let ageLabel = stack.arrangedSubviews[1].viewWithTag(2) as! UILabel
            
            let numFormat = NumberFormatter()
            numFormat.numberStyle = .decimal
            numFormat.usesGroupingSeparator = true
            
            popLabel.text = numFormat.string(from: NSNumber(value: currentDistrict!.numPeople))
            ageLabel.text = String(currentDistrict!.medAge)
            
        case 2:
            let label = cell.contentView.viewWithTag(2) as! UILabel
            
            let numFormat = NumberFormatter()
            numFormat.numberStyle = .currency
            numFormat.usesGroupingSeparator = true
            
            label.text = numFormat.string(from: NSNumber(value: currentDistrict!.medIncome))
            
        case 3:
            let stack = cell.contentView.subviews[0] as! UIStackView
            let chart = stack.arrangedSubviews[0] as! PieChartView
            let label = stack.arrangedSubviews[1].viewWithTag(2) as! UILabel
            
            let numFormat = NumberFormatter()
            numFormat.numberStyle = .decimal
            numFormat.usesGroupingSeparator = true
            
            label.text = numFormat.string(from: NSNumber(value: currentDistrict!.numHispanic))
            
            if chart.data == nil{
                let dset = PieChartDataSet(values: raceDataPoints, label: nil)
                dset.colors = ChartColorTemplates.joyful()
                dset.drawValuesEnabled = false
                let data = PieChartData(dataSet: dset)
                chart.data = data
                chart.chartDescription = nil
                chart.drawEntryLabelsEnabled = false
                chart.usePercentValuesEnabled = true
                chart.notifyDataSetChanged()
            }
        case 4:
            let chart = cell.contentView.subviews[0] as! PieChartView
            if chart.data == nil{
                let dset = PieChartDataSet(values: educationDataPoints, label: nil)
                dset.colors = ChartColorTemplates.joyful()
                dset.drawValuesEnabled = false
                let data = PieChartData(dataSet: dset)
                chart.data = data
                chart.chartDescription = nil
                chart.drawEntryLabelsEnabled = false
                chart.notifyDataSetChanged()
            }
        default:
            break
        }
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polygon = overlay as? MKPolygon{
            
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = themeColor
            renderer.lineWidth = lineThickness
            renderer.fillColor = fillColor
            
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

class HeaderView: UITableViewHeaderFooterView{
    let themeColor = UIColor(red: 88.0/256, green: 186.0/256, blue: 157.0/256, alpha: 1.0)

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.backgroundColor = themeColor
        self.textLabel?.font = UIFont(name: "Dosis-Bold", size: 20)
        self.textLabel?.textColor = UIColor.white
    }
}
