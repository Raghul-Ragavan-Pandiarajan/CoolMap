//
//  AddLocationViewController.swift
//  CoolMap
//
//  Created by Raghul Ragavan on 07/04/23.
//

import UIKit


class AddLocationViewController: UIViewController {
    
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var provinceLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var celciusLabel: UIButton!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var farenheitLabel: UIButton!
    weak var delegate: AddLocationViewControllerDelegate?
    let utilityFunctions = Utilities()
    let weatherApi = WeatherAPIModal()
    var weatherResponseDefault: WeatherResponse?
    var items: [WeatherItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        setdefaulttemperature()
        
        searchTextField.delegate = self
        
    }
    @IBAction func errorButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToErrorScreen", sender: nil)
    }
    
    func loadData(_ weatherResponse: WeatherResponse?) {
        guard let weatherResponse = weatherResponse else {
            print("No value")
            return
        }
        
        
        DispatchQueue.main.async { [self] in
            cityLabel.text = weatherResponse.location.name
            provinceLabel.text = weatherResponse.location.region
            DateLabel.text = utilityFunctions.formatDate(dateString: weatherResponse.forecast.forecastday[0].date)
            temperatureLabel.text = "\(Int(weatherResponse.current.temp_c))°C"
            weatherConditionLabel.text = weatherResponse.current.condition.text
            let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .thin, scale: .medium)
            weatherImage.image =  utilityFunctions.getWeatherImage(code: weatherResponse.current.condition.code)?.applyingSymbolConfiguration(config)
            weatherResponseDefault = weatherResponse
        }
        
    }
    
    


@IBAction func onSearchTapped(_ sender: UIButton) {
    setdefaulttemperature()
    loadWeather(search: searchTextField.text)
}

@IBAction func onFarenheitTapped(_ sender: UIButton) {
    
    sender.tintColor = UIColor(ciColor: .green)
    celciusLabel.tintColor = UIColor(ciColor: .white)
    
    if let temperature = temperatureLabel.text {
        guard let celsiusValue = Double(temperature.replacingOccurrences(of: "°C", with: "")) else {
            print("error")
            return
            
        }
        let fahrenheitValue = (celsiusValue * 9/5) + 32
        temperatureLabel.text = "\(Int(round(fahrenheitValue)))°F"
    }
}

@IBAction func onCelciusTapped(_ sender: UIButton) {
    setdefaulttemperature()
    
    if let temperature = temperatureLabel.text {
        guard let fahrenheitValue = Double(temperature.replacingOccurrences(of: "°F", with: "")) else {
            print("error")
            return
            
        }
        let celsiusValue = (fahrenheitValue  - 32) * (5/9)
        temperatureLabel.text = "\(Int(round(celsiusValue)))°C"
    }
    
}

func setdefaulttemperature() {
    farenheitLabel.tintColor = UIColor(ciColor: .white)
    celciusLabel.tintColor = UIColor(ciColor: .green)
}

func loadWeather(search: String?) {
    
    searchTextField.text = ""
    guard let search = search else {
        return
    }
    
    DispatchQueue.main.async { [self] in
        weatherApi.fetchWeatherDetails(for: "\(search)" ) { [self] result in
            switch result {
            case .success(let weatherResponse):
                loadData(weatherResponse)
            case .failure(let error):
                print(error)
            }
    }
    
   
    }
   
    
}
    

    @IBAction func CloseButtonPressed(_ sender: UIBarButtonItem) {
       dismiss(animated: true)
        
    }
    @IBAction func AddButtonTapped(_ sender: UIBarButtonItem) {
        guard let weatherResponseDefault = weatherResponseDefault else {
            return
        }
        guard let weatherImg = utilityFunctions.getWeatherImage(code: weatherResponseDefault.current.condition.code) else {
            return
        }
        
        
      
            let dataToPassBack = WeatherItem(location: weatherResponseDefault.location.name,
                                             region: weatherResponseDefault.location.region,
                                             country: weatherResponseDefault.location.country,
                                 temperature: "\(Int(weatherResponseDefault.current.temp_c))",
                                 maxTemperature: "\(Int(weatherResponseDefault.forecast.forecastday[0].day.maxtemp_c))",
                                 minTemperature: "\(Int(weatherResponseDefault.forecast.forecastday[0].day.mintemp_c))",
                                 weatherImage: weatherImg)
        
        
        delegate?.addLocationViewControllerDelegateDidFinish(with: dataToPassBack)
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


extension AddLocationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        
        loadWeather(search: textField.text)
        return true
    }
}



struct WeatherItem {
    let location: String
    let region: String
    let country: String
    let temperature: String
    let maxTemperature: String
    let minTemperature: String
    let weatherImage: UIImage
}



protocol AddLocationViewControllerDelegate: AnyObject {
    func addLocationViewControllerDelegateDidFinish(with data: WeatherItem)
}

    
