//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "a8547d71b617239e14f4dc7cc8d77fc0"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var weatherDataModel: WeatherDataModel?
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    //UISwitch IBOutlet
    @IBOutlet weak var temperatureSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation() // Asynchronous method (run in background)
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String:String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            (response) in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON: JSON = JSON(response.result.value!) // Fairly safe to use force unwrapping here because the response is a success
                
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                
                
                
            } else {
                
                if let error = response.result.error {
                    print("Error: \(error)")
                    self.cityLabel.text = "Connection Issues"
                }
                

            }
            
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON) {
        
        if let tempInKelvin = json["main"]["temp"].double {
            let tempInCelcius = Int(tempInKelvin - 273.15)
            let city = json["name"].stringValue
            let conditionCode = json["weather"][0]["id"].intValue
            let weatherIconName = WeatherDataModel.updateWeatherIcon(condition: conditionCode)
            
            weatherDataModel = WeatherDataModel(temperature: tempInCelcius, condition: conditionCode, city: city, weatherIconName: weatherIconName)
            
            updateUIWithWeatherData(weatherDataModel: weatherDataModel!)
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(weatherDataModel: WeatherDataModel) {
        temperatureLabel.text = "\(weatherDataModel.temperature)℃"
        cityLabel.text = weatherDataModel.city
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1] // Get the last most accurate location (assumption is first location is rough estimate so the last one should be the most accurate)
        
        // Check whether location data is valid or not
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation() // Stop updating location
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            print("lat: \(latitude), lon: \(longitude)")
            
            // Parameters for the openweathermap.org API call
            let params: [String:String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    // When location manager failed to get location data
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        let params: [String:String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
        temperatureSwitch.setOn(true, animated: true)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destVC = segue.destination as! ChangeCityViewController
            destVC.delegate = self
        }
    }
    
    //MARK: - Change Temperature Type with UISwitch
    /***************************************************************/
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        
        let temperatureInCelcius = weatherDataModel!.temperature
        
        if temperatureSwitch.isOn {
            temperatureLabel.text = "\(temperatureInCelcius)℃"
        } else {
            let temperatureInFahrenheit = (temperatureInCelcius * 9 / 5) + 32
            temperatureLabel.text = "\(temperatureInFahrenheit)℉"
        }
    }
    
    
}


