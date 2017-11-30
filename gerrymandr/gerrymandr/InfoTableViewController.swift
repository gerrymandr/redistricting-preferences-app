//
//  InfoTableViewController.swift
//  gerrymandr
//
//  Created by Gabriel Ramirez on 11/29/17.
//  Copyright © 2017 mggg. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {

    var currentDistrict: District?
    var selectedSection: Int? = nil
    
    let sections = ["Full Map", "Demographics", "Income", "Race", "Education"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if let district = currentDistrict{
            if district.districtNumber == 0{
                self.title = district.state + " at large"
            }
            else{
                self.title = district.state+" \(district.districtNumber)"
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
        let view = tableView.dequeueReusableCell(withIdentifier: "header")
        view?.textLabel?.text = sections[section]
        return view
    }
    @IBAction func donePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
