//
//  ViewController.swift
//  UberCalculator
//
//  Created by Stanley on 2016/10/24.
//  Copyright © 2016年 Stanley. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destinationField: UITextField!
    
    @IBOutlet weak var startPriceLabel: UILabel!
    @IBOutlet weak var rangePriceLabel: UILabel!
    @IBOutlet weak var timePriceLabel: UILabel!
    @IBOutlet weak var longRangePriceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    let startPrice = 30.0
    let pricePerMinute = 2.0
    let pricePerKM = 11.5
    let longRange = 15.0
    let longRangePricePerKM = 11.5
    let minimunPrice = 50.0
    
    var mapItems = [MKMapItem]()
    var completedCount = 0
    
    var source = 0.0
    var time = 0.0
    
    @IBAction func calculate(_ sender: AnyObject) {
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = startField.text
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            print("搜尋結束： 起點")
            
            if let mapItem = response?.mapItems.first {
                self.mapItems.append(mapItem)
                self.completedCount += 1
                
                if self.completedCount == 2 {
                    self.calculateRoute()
                }
            }
        }
        
        let searchRequest2 = MKLocalSearchRequest()
        searchRequest2.naturalLanguageQuery = destinationField.text
        
        let search2 = MKLocalSearch(request: searchRequest2)
        search2.start { (response, error) in
            print("搜尋結束： 目的地")
            
            if let mapItem = response?.mapItems.last {
                self.mapItems.append(mapItem)
                self.completedCount += 1
                
                if self.completedCount == 2 {
                    self.calculateRoute()
                }
            }
        }
        
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        
        startField.text = ""
        destinationField.text = ""
        
        startPriceLabel.text = "0"
        rangePriceLabel.text = "0"
        timePriceLabel.text = "0"
        longRangePriceLabel.text = "0"
        
        totalPriceLabel.text = "0"
        
    }
    
    func calculatePrice() {
        
        if let distance : Double = self.source, let time : Double = self.time {
            
            let distancePrice = distance * pricePerKM
            let timePrice = time * pricePerMinute
            var longDistancePrice = (distance - longRange) * longRangePricePerKM
            
            if longDistancePrice < 0 {
                longDistancePrice = 0
            }
            
            var totalPrice = startPrice + distancePrice + timePrice + longDistancePrice
            
            if totalPrice < minimunPrice {
                totalPrice = minimunPrice
            }
            
            startPriceLabel.text = "\(startPrice)"
            rangePriceLabel.text = String(format: "%.2f", distancePrice)
            timePriceLabel.text = String(format: "%.2f", timePrice)
            longRangePriceLabel.text = String(format: "%.2f", longDistancePrice)
            totalPriceLabel.text = String(format: "%.2f", totalPrice)
        }
        
    }
    
    func calculateRoute() {
        
        print("準備開始路徑規劃")
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = mapItems.first
        directionsRequest.destination = mapItems.last
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            print("路徑規劃完成")
            print("\(response?.routes.first?.distance)")
            print("\(response?.routes.first?.expectedTravelTime)")
            
            self.source = Double((response?.routes.first?.distance)!/1000)
            self.time = Double((response?.routes.first?.expectedTravelTime)!/60)
            
            self.calculatePrice()
            
        }
        
    }
    
}

