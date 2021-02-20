//
//  ViewController.swift
//  MyWeather
//
//  Created by Даир Алаев on 19.02.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var controlView: UIPageControl!
    @IBOutlet var table: UITableView!
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    var cities = [City]()
    var currentCityNumber: Int = 0
    var currentCityNumberDirection: Int = 0

    
    let locationManager = CLLocationManager()
    
    var currentLocation: String?
    var current: CurrentWeather?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register 2 cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)

        
        table.delegate = self
        table.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCities()
        requestWeatherForLocation(cityNumber: currentCityNumber)
    }
    
    func setupCities() {
        cities.append(City(name: "Almaty", latitude: 43.238949, longtitude: 76.889709))
        cities.append(City(name: "NYC", latitude: 40.730610, longtitude: -73.935242))
        cities.append(City(name: "London", latitude: 51.509865, longtitude: -0.118092))

    }
    
    @IBAction func controlViewChanged(_ sender: Any) {
        if currentCityNumber == 2 {
            currentCityNumberDirection = 1
        } else if currentCityNumber == 0 {
            currentCityNumberDirection = 0
        }
        
        if currentCityNumberDirection == 0 {
            currentCityNumber = currentCityNumber + 1
        } else {
            currentCityNumber = currentCityNumber - 1
        }

        requestWeatherForLocation(cityNumber: currentCityNumber)
    }
    
    func requestWeatherForLocation(cityNumber: Int) {
        
        let lat = cities[cityNumber].latitude
        let long = cities[cityNumber].longtitude
        currentLocation = cities[cityNumber].name
        
        print("\(long) | \(lat)")
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]&units=si"
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            //Validation
            guard let data = data, error == nil else{
                print("something went wrong")
                return
            }
            
            //Convert data to models
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            }
            catch {
                print("error \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            let entries = result.daily.data
            
            let current = result.currently
            self.current = current
            
            self.hourlyModels = result.hourly.data
            
            self.models.removeAll()
            self.models.append(contentsOf: entries)
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
            }
            //Update UI
            
        }).resume()
    }
    
    func createTableHeader() -> UIView{
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
        
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
                
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/5))
                
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height, width: view.frame.size.width-20, height: headerView.frame.size.height/2))
        
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(summaryLabel)
        
        tempLabel.textAlignment = .center
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        
        summaryLabel.font = summaryLabel.font.withSize(30)
        tempLabel.font = UIFont.boldSystemFont(ofSize: 60)


        
        guard let currentWeather = self.current else {
            return UIView()
        }
        locationLabel.text = currentLocation

        tempLabel.text = "\(Int(currentWeather.temperature))°"
        summaryLabel.text = self.current?.summary
        
        return headerView
        
    }
    
    //Table
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
           
        return 2
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 1 cell that is collectiontableviewcell
            return 1
        }
        // return models count
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
            cell.configure(with: hourlyModels)
            return cell
        }

            // Continue
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
            cell.configure(with: models[indexPath.row])
            return cell
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else {
            return 50
        }
    }
}

struct WeatherResponse: Codable {
    let latitude: Float
    let longitude: Float
    let timezone: String
    let currently: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
}

struct CurrentWeather: Codable {
    let time: Int
    let summary: String
    let icon: String
    let temperature: Double
    let apparentTemperature: Double
}

struct DailyWeather: Codable {
    let summary: String
    let icon: String
    let data: [DailyWeatherEntry]
}

struct DailyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let temperatureHigh: Double
    let temperatureLow: Double
    let apparentTemperatureHigh: Double
    let apparentTemperatureLow: Double
    let temperatureMin: Double
    let temperatureMax: Double
}

struct HourlyWeather: Codable {
    let summary: String
    let icon: String
    let data: [HourlyWeatherEntry]
}

struct HourlyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let temperature: Double
}

struct City: Codable {
    var name: String
    var latitude: Double
    var longtitude: Double
}
