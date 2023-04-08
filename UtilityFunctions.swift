//
//  UtilityFunctions.swift
//  CoolMap
//
//  Created by Raghul Ragavan on 07/04/23.
//
import Foundation
import UIKit

class Utilities {
    
    static let shared = Utilities() 
    
    
    func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        do {
            let weather = try decoder.decode(WeatherResponse.self, from: data)
            return weather
        } catch {
            print("Error decoding: \(error)")
            return nil
        }
    }
    
    func formatDate(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
        return nil
    }
    
    func getWeatherImage(code: Int) -> UIImage? {

        let sunConfig = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemGray ])
        let rainSnowConfig = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .systemTeal ])
        let cloudConfig = UIImage.SymbolConfiguration(paletteColors: [.systemGray, .systemYellow ])
            
            switch code {
                case 1000: return UIImage(systemName: "sun.max", withConfiguration: sunConfig)
                case 1003: return UIImage(systemName: "cloud.sun", withConfiguration: cloudConfig)
                case 1006: return UIImage(systemName: "smoke.fill", withConfiguration: cloudConfig)
                case 1009: return UIImage(systemName: "cloud.fill", withConfiguration: cloudConfig)
                case 1030: return UIImage(systemName: "cloud.fog", withConfiguration: rainSnowConfig)
                case 1069: return UIImage(systemName: "cloud.drizzle", withConfiguration: rainSnowConfig)
                case 1114: return UIImage(systemName: "cloud.snow", withConfiguration: rainSnowConfig)
                case 1117: return UIImage(systemName: "tropicalstorm", withConfiguration: rainSnowConfig)
                case 1135: return UIImage(systemName: "cloud.fog", withConfiguration: rainSnowConfig)
                case 1147: return UIImage(systemName: "cloud.fog.fill", withConfiguration: rainSnowConfig)
                case 1063: return UIImage(systemName: "cloud.drizzle", withConfiguration: rainSnowConfig)
                case 1066: return UIImage(systemName: "cloud.snow", withConfiguration: rainSnowConfig)
                case 1072: return UIImage(systemName: "cloud.sleet", withConfiguration: rainSnowConfig)
                case 1183: return UIImage(systemName: "cloud.drizzle", withConfiguration: rainSnowConfig)
                case 1087: return UIImage(systemName: "cloud.bolt.rain", withConfiguration: rainSnowConfig)
                case 1219: return UIImage(systemName: "snowflake", withConfiguration: rainSnowConfig)
                case 1150, 1153, 1168, 1171, 1180, 1186, 1189, 1192, 1195: return UIImage(systemName: "cloud.rain", withConfiguration: rainSnowConfig)
                case 1198, 1201, 1204, 1207, 1210, 1213, 1216, 1222, 1225: return UIImage(systemName: "wind.snow", withConfiguration: rainSnowConfig)
                case 1237: return UIImage(systemName: "cloud.hail", withConfiguration: rainSnowConfig)
                case 1240: return UIImage(systemName: "cloud.rain", withConfiguration: rainSnowConfig)
                case 1255: return UIImage(systemName: "cloud.snow.fill", withConfiguration: rainSnowConfig)
                case 1279: return UIImage(systemName: "cloud.bolt.rain", withConfiguration: rainSnowConfig)
                default: return nil
            }
    }
}
