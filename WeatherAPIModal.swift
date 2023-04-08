//
//  WeatherAPIModal.swift
//  CoolMap
//
//  Created by Raghul Ragavan on 07/04/23.
//

import Foundation

struct WeatherResponse: Decodable {
    let location : Location
    let current : Weather
    let forecast : Forecast
}


struct Location: Decodable {
    let name: String
    let region: String
    let localtime: String
    let country: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let feelslike_c: Float
    let condition : WeatherCondition
}

struct Forecast: Decodable {
    let forecastday : [ForecastDay]
}
struct ForecastDay: Decodable {
    let date : String
    let day : Day
}
struct Day: Decodable {
    let maxtemp_c : Float
    let mintemp_c : Float
    let condition : WeatherCondition
}


struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

class WeatherAPIModal {
    let utilityFunctions = Utilities()
    
    private func buildWeatherURL(for query: String) -> URL? {
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "forecast.json"
        let apikey = "fda72daabbb9454696e203424231903"
        
        var components = URLComponents(string: baseUrl + currentEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apikey),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "days", value: "7")
        ]
        
        guard let url = components?.url else {
            return nil
        }
        
        return url
    }
    
    
     func fetchWeatherDetails(for search: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void ) {
        
        guard let url = buildWeatherURL(for: search) else {
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {  data, response, error in
            
            guard let data = data else {
                print("No Data Found")
                return
            }
            
            guard let weatherResponse = self.utilityFunctions.parseJson(data: data) else {
                print("Could not parse JSON")
                return
            }
            
            completion(.success(weatherResponse))
        }
        
        dataTask.resume()
    }
}
