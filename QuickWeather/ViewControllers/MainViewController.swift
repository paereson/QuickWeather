//
//  ViewController.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainTemperature: UILabel!
    @IBOutlet weak var mainDescription: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var windImageView: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var futureWeatherTableView: UITableView!
    @IBOutlet weak var futureWeatherTableViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Vars
    var viewModel = MainViewModel()
    var weatherSubscriber: AnyCancellable?
    var futureWeatherData: [List] = []
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupSubscribers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        futureWeatherTableView.superview?.layoutIfNeeded()
        futureWeatherTableViewHeightConstraint.constant = futureWeatherTableView.contentSize.height
    }
    
    // MARK: Setup
    private func configureTableView() {
        futureWeatherTableView.register(UINib(nibName: "FutureWeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "FutureWeatherTableViewCell")
        
        futureWeatherTableView.delegate = self
        futureWeatherTableView.dataSource = self
        futureWeatherTableView.alwaysBounceVertical = false
        futureWeatherTableView.allowsSelection = false
        futureWeatherTableView.separatorStyle = .none
        futureWeatherTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupSubscribers() {
        weatherSubscriber = viewModel.$weather
            .sink(receiveValue: { [weak self] weatherModel in
                self?.cityLabel.text = "\(weatherModel?.city.name ?? ""), \(weatherModel?.city.country ?? "")"
                
                let image = UIImage(systemName: weatherModel?.list.first?.weather.first?.getImage ?? "")
                self?.mainImageView.image =  image
                
                let temp = weatherModel?.list.first?.main.temp ?? 0
                self?.mainTemperature.text = "\(Int(temp))°"
                
                self?.mainDescription.text = weatherModel?.list.first?.weather.first?.description ?? ""
                self?.windLabel.text = ""
                
                self?.windSpeedLabel.text = "\(Int(weatherModel?.list.first?.wind.speed ?? 0))m/s"
                
                let indexes = [0, 8, 16, 24]
                if let weatherModel = weatherModel {
                    self?.futureWeatherData = indexes.map { weatherModel.list[$0] }
                }
                self?.futureWeatherTableView.reloadData()
            })
    }
    
    // MARK: Actions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let vc = SearchViewController.instantiate(viewModel: viewModel)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return futureWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FutureWeatherTableViewCell"
        ) as? FutureWeatherTableViewCell else {
            return UITableViewCell()
        }
        
        let weather = futureWeatherData[indexPath.row]
        
        let date = Date(timeIntervalSince1970: TimeInterval(weather.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: date)
        
        cell.dateLabel.text = "\(dateString)"
        
        cell.weatherImageView.image = UIImage(systemName: "\(weather.weather.first?.getImage ?? "")")
        cell.temperatureLabel.text = "\(Int(weather.main.temp_min))°\(Int(weather.main.temp_max))°"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

