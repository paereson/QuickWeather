//
//  SearchViewController.swift
//  QuickWeather
//
//  Created by Michał Gruszkiewicz on 06/01/2023.
//

import UIKit
import Combine

class SearchViewController: UIViewController, IInstantiate {
    static var storyboardName: String = "Main"
    static var viewControllerIdentifier: String = "SearchViewController"
    
    // MARK: Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultsTableView: UITableView!
    
    // MARK: Vars
    var viewModel: MainViewModel?
    var searchSubscriber: AnyCancellable?
    var tableViewSubscriber: AnyCancellable?
    
    private var isHistory: Bool = true
    @Published var searchText: String = ""
    @Published var cities: CitiesModel?
    var cityRealmModel: [CityRealmModel]?
    
    var searchCity: AnyPublisher<CitiesModel?, Never> {
        return $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .flatMap { text in
                return Future { [weak self] promise in
                    if !text.isEmpty {
                        RESTService.getCitiesList(city: text) { [weak self] cities in
                            self?.cities = cities
                            self?.isHistory = false
                        }
                    } else {
                        var historyArray = CitiesModel(results: [])
                        let historyCities = PersistenceManagerImp().fetchObjects(CityRealmModel.self) as? [CityRealmModel]
                        historyCities?.forEach { historyArray.results.append($0.getResults()) }
                        self?.cityRealmModel = historyCities
                        self?.cities = historyArray
                        self?.isHistory = true
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupElements()
        setupSubscribers()
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let previousTraitCollection = previousTraitCollection else { return }
        resultsTableView.layer.borderColor = UIColor(named: "WeatherMainColor")?.resolvedColor(with: previousTraitCollection).cgColor
        searchTextField.layer.borderColor = UIColor(named: "WeatherMainColor")?.resolvedColor(with: previousTraitCollection).cgColor
    }
    
    static func instantiate(viewModel: MainViewModel) -> SearchViewController {
        let vc = SearchViewController.instantiate()
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: Funcs
    private func setupSubscribers() {
        searchSubscriber = searchCity
            .map { $0 != nil }
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in })
        
        tableViewSubscriber = $cities
            .map { $0 != nil }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resultsTableView.reloadData()
               }
    }
    
    
    private func setupElements() {
        searchTextField.delegate = self
        
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.separatorStyle = .none
        resultsTableView.rowHeight = UITableView.automaticDimension
        resultsTableView.allowsMultipleSelectionDuringEditing = false
        
        resultsTableView.layer.borderWidth = 1.0
        resultsTableView.layer.cornerRadius = 8
        resultsTableView.layer.borderColor = UIColor(named: "WeatherTextColo")?.resolvedColor(with: .init(userInterfaceStyle: traitCollection.userInterfaceStyle)).cgColor
        
        searchTextField.layer.borderWidth = 1.0
        searchTextField.layer.cornerRadius = 8
        searchTextField.layer.borderColor = UIColor(named: "WeatherTextColo")?.resolvedColor(with: .current).cgColor
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = textField.text ?? ""
        let text = (textFieldText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == searchTextField { searchText = text }
        
        return true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        var content = cell.defaultContentConfiguration()
        content.text = cities?.results[indexPath.row].name ?? ""
        cell.contentConfiguration = content
        
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let city = cities?.results[indexPath.row] {
            viewModel?.getNewWeatherData(lat: city.geometry.location.lat, lon: city.geometry.location.lng)
            
            if !isHistory {
                /// save city to history
                let realmObj = CityRealmModel()
                realmObj.createFromResults(with: city)
                PersistenceManagerImp().saveObject(realmObj, update: false)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }

    

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let results = cities?.results[indexPath.row], let model = cityRealmModel?.first(where: { ($0.latitude == results.geometry.location.lat && $0.longitude == results.geometry.location.lng) }) {
//                let model = CityRealmModel()
//                model.createFromResults(with: results)
                PersistenceManagerImp().removeObject(model)
                cities?.results.removeAll(where: { $0.geometry == results.geometry })

                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            } else {
                showSimpleAlert(title: "Something went wrong", description: "Sorry- we can't delete city")
            }
        }
    }
}
