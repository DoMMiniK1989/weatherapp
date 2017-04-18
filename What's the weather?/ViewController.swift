//
//  ViewController.swift
//  What's the weather?
//
//  Created by Dusan Bojkovic on 1/30/17.
//  Copyright © 2017 g7. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var conditionLbl: UILabel!
    @IBOutlet weak var degreeLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var mySegment: UISegmentedControl!
    @IBOutlet weak var segmentResultLbl: UILabel!
    
    var degree: Int!
    var condition: String!
    var imgUrl: String!
    var city: String!
    var validContry: String!
    var windS: Int!
    var windP: Int!
    var windDirection: String!
    
    var validCityName: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        if (searchBar.text?.isEmpty)! {
            mySegment.isHidden = true
            segmentResultLbl.isHidden = true
            conditionLbl.isHidden = true
            degreeLbl.isHidden = true
        } else {
            mySegment.isHidden = false
            segmentResultLbl.isHidden = false
            conditionLbl.isHidden = false
            degreeLbl.isHidden = false
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let urlRequest = URLRequest(url: URL(string: "https://api.apixu.com/v1/current.json?key=dad98de2e0d74a7d94185919173001&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    
                    if let current = json["current"] as? [String : AnyObject] {
                        if let temp = current["temp_c"] as? Int {
                            self.degree = temp
                            let windSpeed = current["wind_kph"] as? Int
                            self.windS = windSpeed
                            let windPressure = current["pressure_mb"] as? Int
                            self.windP = windPressure
                            let humidity = current["wind_dir"] as? String
                            self.windDirection = humidity
                        }
                        if let condition = current["condition"] as? [String : AnyObject] {
                            self.condition = condition["text"] as! String
                            let icon = condition["icon"] as! String
                            self.imgUrl = "https:\(icon)"
                        }
                    }
                    if let location = json["location"] as? [String : AnyObject] {
                        self.city = location["name"] as! String
                        if let currentContry = location["country"] as? String {
                            self.validContry = currentContry
                        }
                    }
                    if let _ = json["error"] {
                        self.validCityName = false
                    }
                    
                    DispatchQueue.main.async {
                        
                        if self.validCityName {
                            self.segmentResultLbl.isHidden = false
                            self.mySegment.isHidden = false
                            self.degreeLbl.isHidden = false
                            self.conditionLbl.isHidden = false
                            self.imgView.isHidden = false
                            
                            if self.mySegment.selectedSegmentIndex == 0 {
                                self.segmentResultLbl.text = self.validContry
                            } else if self.mySegment.selectedSegmentIndex == 1 {
                                self.segmentResultLbl.text = "\(self.windS!) kph"
                            } else if self.mySegment.selectedSegmentIndex == 2 {
                                self.segmentResultLbl.text = "\(self.windP!) mbars"
                            } else {
                                self.segmentResultLbl.text = "\(self.windDirection!)"
                            }
                            
                            self.degreeLbl.text = "\(self.degree.description)°"
                            self.cityLbl.text = self.city
                            self.conditionLbl.text = self.condition
                            self.imgView.downloadImage(from: self.imgUrl!)
                        } else {
                            self.segmentResultLbl.isHidden = true
                            self.mySegment.isHidden = true
                            self.degreeLbl.isHidden = true
                            self.conditionLbl.isHidden = true
                            self.imgView.isHidden = true
                            self.cityLbl.text = "No matching city found"
                            self.validCityName = true
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError.localizedDescription)
                }
            }
        }
        task.resume()
        
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        if mySegment.selectedSegmentIndex == 0 {
            segmentResultLbl.text = validContry
        } else if mySegment.selectedSegmentIndex == 1 {
            segmentResultLbl.text = "\(windS!) kph"
        } else if mySegment.selectedSegmentIndex == 2 {
            segmentResultLbl.text = "\(windP!) mbars"
        } else {
            segmentResultLbl.text = "\(windDirection!)"
        }
    }
}

extension UIImageView {
    
    func downloadImage(from url: String) {
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
}
