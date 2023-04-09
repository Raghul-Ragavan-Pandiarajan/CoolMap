//
//  DetailsViewController.swift
//  CoolMap
//
//  Created by Raghul Ragavan on 07/04/23.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var weatherCondLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [ItemWeatherData] = []
    private let utilityFunctions = Utilities()
    
    var weatherResponse: WeatherResponse? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        overrideUserInterfaceStyle = .dark
    }
    
    func loadData() {
        guard let weatherResponse = weatherResponse else {
            print("No value")
            return
        }
        print(weatherResponse)
        setWeatherDetails(weatherResponse)
        loadForecastDetails()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadForecastDetails() {
        guard let forecastDays = weatherResponse?.forecast.forecastday else {
            return
        }
        
        items = []
        for day in forecastDays.prefix(7) {
            let localtime = day.date
            let maxTemp = day.day.maxtemp_c
            let minTemp = day.day.mintemp_c
            let weatherImageCode = day.day.condition.code
            guard let weatherImg = utilityFunctions.getWeatherImage(code: weatherImageCode) else {
                continue
            }
            let dayOfWeek = utilityFunctions.formatDate(dateString: localtime)
            let maxTemperature = "\(Int(maxTemp))\u{00B0}"
            let minTemperature = "\(Int(minTemp))\u{00B0}"
            
            guard let dayOfWeek = dayOfWeek else {
                return
            }
            items.append(ItemWeatherData(dayOfWeek: dayOfWeek, maxTemperature: maxTemperature, minTemperature: minTemperature, weatherImage: weatherImg))
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func setWeatherDetails(_ weatherResponse: WeatherResponse) {
        DispatchQueue.main.async { [self] in
            locationLabel.text = weatherResponse.location.name
            TempLabel.text = "\(Int(weatherResponse.current.temp_c))\u{00B0}"
            weatherCondLabel.text = weatherResponse.current.condition.text
            highLabel.text = "\(Int(weatherResponse.forecast.forecastday[0].day.maxtemp_c))\u{00B0}"
            lowLabel.text = "\(Int(weatherResponse.forecast.forecastday[0].day.mintemp_c))\u{00B0}"
        }
    }
}



extension DetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath)
        let item = items[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = item.dayOfWeek
        let maxTempWidth = items.map { $0.maxTemperature.count }.max() ?? 0
        let minTempWidth = items.map { $0.minTemperature.count }.max() ?? 0
        
        var formattedString = ""
        let maxTempStr = item.maxTemperature.padding(toLength: maxTempWidth, withPad: " ", startingAt: 0)
        let minTempStr = item.minTemperature.padding(toLength: minTempWidth, withPad: " ", startingAt: 0)
        formattedString += "H: \(maxTempStr)\t\tL: \(minTempStr)"
        
        content.secondaryText = formattedString
        
        
        content.image = item.weatherImage
        
        cell.contentConfiguration = content
        return cell
    }
}

struct ItemWeatherData {
    let dayOfWeek: String
    let maxTemperature: String
    let minTemperature: String
    let weatherImage: UIImage
}
