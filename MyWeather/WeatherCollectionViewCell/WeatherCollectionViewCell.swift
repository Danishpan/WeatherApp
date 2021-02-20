//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by Даир Алаев on 20.02.2021.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    static let identifier = "WeatherCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell",
                     bundle: nil)
    }

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var hourLabel: UILabel!


    func configure(with model: HourlyWeatherEntry) {
        self.hourLabel.text = getHourForDate(Date(timeIntervalSince1970: Double(model.time)))
        self.tempLabel.text = "\(Int(model.temperature))°"
        self.iconImageView.contentMode = .scaleAspectFit
        
        let icon = model.icon.lowercased()
        
        if icon.contains("clear") {
            self.iconImageView.image = UIImage(named: "clear")
        } else if icon.contains("rain") {
            self.iconImageView.image = UIImage(named: "rain")
        } else if icon.contains("cloud") {
            self.iconImageView.image = UIImage(named: "cloud")
        } else if icon.contains("fog") {
            self.iconImageView.image = UIImage(named: "fog")
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

func getHourForDate(_ date: Date?) -> String {
    guard let inputDate = date else {
        return ""
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "H"
    return formatter.string(from: inputDate)
}
