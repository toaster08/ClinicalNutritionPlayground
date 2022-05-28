//
//  BMICalculatorViewController.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import UIKit

final class BMICalculatorViewController: UIViewController {
    
    private lazy var viewModel = BMICalculatorViewModel(notificationCenter: notificationCenter)
    private let notificationCenter = NotificationCenter()
    
    @IBOutlet private weak var heightSlider: UISlider!
    @IBOutlet private weak var weightSlider: UISlider!
    @IBOutlet private weak var sexSegementedControl: UISegmentedControl!
    @IBOutlet private weak var ageTextField: UITextField!
    @IBOutlet private weak var ageStepper: UIStepper!
    
    @IBOutlet private weak var bodyProfileView: UIView!
    @IBOutlet private weak var bmiResultLabel: UILabel!
    @IBOutlet private weak var rohrelIndexResultLabel: UILabel!
    @IBOutlet private weak var obesityIndexLabel: UILabel!
    
    @IBOutlet private weak var bmiView: UIView!
    @IBOutlet private weak var rohrerIndexView: UIView!
    @IBOutlet private weak var obesityIndexView: UIView!
    
    @IBOutlet private weak var profileView: UIView!
    @IBOutlet private weak var heightLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configure()
        
        let color3 = UIColor(named: "Color")?.cgColor
        let color2 = UIColor(named: "Color-1")?.cgColor
        let color1 = UIColor(named: "Color-2")?.cgColor
        
        let gradLayer = CAGradientLayer()
        gradLayer.frame = view.frame
        gradLayer.colors = [color3, color2, color1]
        gradLayer.startPoint = .init(x: 0, y: 00)
        gradLayer.endPoint = .init(x: 0, y: 1.0)
        view.layer.insertSublayer(gradLayer, at: 0)
        
        sexSegementedControl.addTarget(
            self,
            action: #selector(valueChanged),
            for: .valueChanged)
        ageStepper.addTarget(
            self,
            action: #selector(ageStepperValueChanged),
            for: .valueChanged)
        ageStepper.addTarget(
            self,
            action: #selector(valueChanged),
            for: .valueChanged)
        heightSlider.addTarget(
            self,
            action: #selector(valueChanged),
            for: .valueChanged)
        weightSlider.addTarget(
            self,
            action: #selector(valueChanged),
            for: .valueChanged)
        
        //notificationを受け取って起動
        notificationCenter.addObserver(
            self,
            selector: #selector(updateBMILabel),
            name: viewModel.changeBMI,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(updateRohrerIndexLabel),
            name: viewModel.changeRohrerIndex,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(updateObesityIndexLabel),
            name: viewModel.changeObesityIndex,
            object: nil)
        notificationCenter.addObserver(
            self,
            selector: #selector(updateStandardBodyWeightLabel(notification:)),
            name: viewModel.changeStandardBodyWeight,
            object: nil)
        
        valueChanged()
    }
    
    private func configure() {
        //ViewModelかModelに移したい
        let defaultHeight: Float = 170.0
        let defaultWeight: Float = 60.0
//        let defaultAge:Int = 18
//        let defaultSex: SexType = .male
        
        heightSlider.maximumValue = 250.0
        heightSlider.minimumValue = 0
        weightSlider.maximumValue = 200.0
        weightSlider.minimumValue = 0
        
        heightSlider.value = defaultHeight
        weightSlider.value = defaultWeight
  
        heightLabel.text = String(defaultHeight)
        weightLabel.text = String(defaultWeight)
        
        ageStepper.stepValue = 1
    }
    
    private func setup() {
        [bmiView,
         rohrerIndexView,
         obesityIndexView,
         profileView]
            .forEach {
                $0?.layer.borderWidth = 1
                $0?.layer.borderColor = UIColor.white.cgColor
                $0?.layer.cornerRadius = 10
            
                $0?.layer.shadowColor = UIColor.gray.cgColor
                $0?.layer.shadowOffset = CGSize(width: 0, height: 2)
                $0?.layer.shadowOpacity = 0.6
            }
    }
    
    @objc private func valueChanged() {
        let height = heightSlider.value
        let weight = weightSlider.value
        let age = Int(ageTextField.text ?? "") ?? 0
        let sex = SexType(rawValue: sexSegementedControl.selectedSegmentIndex)
        
        heightLabel.text = String(format: "%.1f", height)
        weightLabel.text = String(format: "%.1f", weight)
        
        viewModel
            .profileValueChanged(height: height,
                                 weight: weight,
                                 age: age,
                                 sex: sex)
    }
 
    @objc private func ageStepperValueChanged()  {
        let age = ageStepper.value
        ageTextField.text = String(format: "%.f", age)
    }
    
    @objc private func updateBMILabel(notification: Notification) {
        guard let bmi = notification.object as? String else { return }
        bmiResultLabel.text = bmi
    }
    
    @objc private func updateRohrerIndexLabel(notification: Notification)  {
        guard let rohrerIndex = notification.object as? String else { return }
        rohrelIndexResultLabel.text = rohrerIndex
    }
    
    @objc private func updateObesityIndexLabel(notification: Notification)  {
        guard let obesityIndex = notification.object as? String else { return }
        obesityIndexLabel.text = obesityIndex
    }
    
    @objc private func updateStandardBodyWeightLabel(notification: Notification)  {
        guard let standardBodyWeight = notification.object as? String else { return }
        print(standardBodyWeight)
    }
}
