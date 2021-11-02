//
//  WeatherManager.swift
//  Clima
//
//  Created by user205198 on 10/16/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(error: Error)
}

struct WeatherManager{
    
    var delegate: WeatherManagerDelegate?

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=4d9ae801f829d2bc12e3cdbc635b7290&units=metric"
    
    func fetchWeather(cityName: String){
        performRequest(with: weatherURL + "&q=\(cityName)")
    }
    
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees){
        performRequest(with: weatherURL + "&lat=\(lat)&lon=\(lon)")
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            var weather = WeatherModel(cityName: name, temp: temp, conditionID: id)
            
            return weather
            
        } catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
