//
//  ViewController.swift
//  Tinkoff
//
//  Created by Илья Москалев on 03.09.2021.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

class ViewController: UIViewController {
    
    //MARK: UI Outlets
    // Labels showing API data
    @IBOutlet var companyNameLabel: UILabel!
    @IBOutlet var companySymbolLabel: UILabel!
    @IBOutlet var companyPriceLabel: UILabel!
    @IBOutlet var companyPriceChangeLabel: UILabel!
    // Views for UI improvements
    // View at the top of the screen
    @IBOutlet var topViewContainer: UIView!
    // Includes
    @IBOutlet var containerStack: UIStackView!
    @IBOutlet var nameStack: UIStackView!
    @IBOutlet var symbolStack: UIStackView!
    @IBOutlet var priceStack: UIStackView!
    @IBOutlet var changePriceStack: UIStackView!
    // View in the middle of the screen
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var imageView: UIImageView!
    // View at the bottom of the screen
    @IBOutlet var botContainerView: UIView!
    // Includes
    @IBOutlet var companyPickerView: UIPickerView!
    // Choose section where from to load companies (gainers, losers etc.)
    @IBOutlet var sectionpickerView: UIPickerView!
    
    // MARK: Arrays declaration
    private var _companies = [Stock]() {
        didSet {
            DispatchQueue.main.async {
                self.companyPickerView.reloadAllComponents()
                self.requestUIUpdate()
            }
        }
    }
    // Категории из которых выбираются акции для загрузки
    private let sections: [String] = ["mostactive", "gainers", "losers","iexvolume", "iexpercent"]
    private let sectionsNames: [String] = ["Most Active", "Gainers", "Losers","Iex volume", "Iex percent"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        sectionpickerView.delegate = self
        sectionpickerView.dataSource = self
        
        activityIndicator.startAnimating()
        
        updateView()
        requestListOfQuotes()
        requestUIUpdate()
    }
    // MARK: Preloading companies
    private func requestListOfQuotes() {
        activityIndicator.startAnimating()
        companyPickerView.isHidden = true
        let selectedRow = sectionpickerView.selectedRow(inComponent: 0)
        let selectedStock = sections[selectedRow]
        
        NetworkManager.shared().requestListOfQuotes(from: selectedStock) { array, error in
            if error != nil {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Oops", message: "Some network error occured", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    ac.addAction(UIAlertAction(title: "Reload", style: .default, handler: { action in
                        self.requestListOfQuotes()
                    }))
                    self.present(ac, animated: true)
                }
            } else {
                self._companies = array!
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.companyPickerView.isHidden = false
                }
            }
        }
    }
    
    // MARK: Network request & update ui
    private func requestUIUpdate() {
        if _companies.isEmpty {
            return
        } else {
            let selectedRow = companyPickerView.selectedRow(inComponent: 0)
            let selectedStock = _companies[selectedRow]
            
            imageView.cacheImage(symbol: selectedStock.symbol)
            
            companyNameLabel.text = selectedStock.companyName
            companySymbolLabel.text = selectedStock.symbol
            companyPriceLabel.text = String(selectedStock.latestPrice)
            companyPriceChangeLabel.text = String(selectedStock.change)
            if selectedStock.change > 0 {
                self.companyPriceChangeLabel.textColor = Colors.systemGreen
            } else {
                self.companyPriceChangeLabel.textColor = Colors.systemRedActiv
            }
            activityIndicator.stopAnimating()
        }
    }
    
    private func updateView() {
        let stackArray = [nameStack, symbolStack, priceStack, changePriceStack]
        let labelArray = [companyNameLabel, companySymbolLabel, companyPriceLabel, companyPriceChangeLabel]
        // Top part
        topViewContainer.layer.cornerRadius = 25
        topViewContainer.backgroundColor = Colors.containerView
        containerStack.backgroundColor = Colors.containerView
        
        for stack in stackArray {
            stack?.layer.cornerRadius = 10
            stack?.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            stack?.isLayoutMarginsRelativeArrangement = true
            stack?.backgroundColor = Colors.stackView
        }
        for label in labelArray {
            label?.textColor = Colors.textColor
        }
        // Middle
        activityIndicator.hidesWhenStopped = true
        view.backgroundColor = Colors.systemBack
        
        // Bottom
        botContainerView.layer.cornerRadius = 70
        botContainerView.backgroundColor = Colors.containerView
        
        companyPickerView.layer.cornerRadius = 70
        companyPickerView.backgroundColor = Colors.containerView
        
        sectionpickerView.backgroundColor = Colors.stackView
        sectionpickerView.layer.cornerRadius = 30
    }
}

// MARK: Extensions
// Picker data sourse
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == companyPickerView {
            return _companies.count
        }
        return sections.count
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
}

// Picker delegate
extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == companyPickerView {
            // Checking _companies array is filled?
            if _companies.isEmpty {
            // If not, don't load companyPickerView
                return nil
            } else {
            // If true, load companyPickerView row title as .companyName
                return _companies[row].companyName
            }
        }
        
        return sectionsNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == companyPickerView {
            requestUIUpdate()
        } else {
            requestListOfQuotes()
        }
    }
}
