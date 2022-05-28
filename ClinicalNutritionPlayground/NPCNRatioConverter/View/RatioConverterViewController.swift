//
//  RatioConverterViewController.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import UIKit
import WARangeSlider
import Charts

final class RatioConverterViewController: UIViewController {
    
    private var presenter: RatioConverterPresenterInput!
    
    @IBOutlet private weak var npcnRatioLabel: UILabel!
    @IBOutlet private weak var proteinLabel: UILabel!
    @IBOutlet private weak var fatLabel: UILabel!
    @IBOutlet private weak var carbohydrateLabel: UILabel!
    
    @IBOutlet private weak var rangeSlider: RangeSlider!
    @IBOutlet private weak var chartsView: PieChartView!
    
    @IBOutlet weak var npcnRatioView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        makeChart()
        setInitialValue(presenter: presenter)
        
        let color3 = UIColor(named: "Color")?.cgColor
        let color2 = UIColor(named: "Color-1")?.cgColor
        let color1 = UIColor(named: "Color-2")?.cgColor
        
        let gradLayer = CAGradientLayer()
        gradLayer.frame = view.frame
        gradLayer.colors = [color3, color2, color1]
        gradLayer.startPoint = .init(x: 0, y: 00)
        gradLayer.endPoint = .init(x: 0, y: 1.0)
        view.layer.insertSublayer(gradLayer, at: 0)

        rangeSlider.addTarget(
            self,
            action: #selector(sliderValueChanged),
            for: .valueChanged)
//        view.addSubview(rangeSlider)
    }
    
    func inject(presenter: RatioConverterPresenterInput) {
        self.presenter = presenter
    }
    
    private func setup() {
        self.navigationItem.title = "Convert PFC Ratio to NPC/N Ratio"

        npcnRatioView.layer.cornerRadius = 15
        npcnRatioView.layer.borderColor = UIColor.white.cgColor
        npcnRatioView.layer.borderWidth = 1
  
        npcnRatioView.layer.shadowColor = UIColor.gray.cgColor
        npcnRatioView.layer.shadowOffset = CGSize(width: 0, height: 2)
        npcnRatioView.layer.shadowOpacity = 0.6
                
    }
    
    private func makeChart() {
          chartsView.centerText = "PFC比率"
//          view.addSubview(chartsView)
    }
    
    private func dataSetFormat() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        return formatter
    }
    
    @objc private func sliderValueChanged() {
        //この知識はここだけ
        let protein = rangeSlider.lowerValue
        let fat = rangeSlider.upperValue - rangeSlider.lowerValue
        let carbohydrate = rangeSlider.maximumValue - rangeSlider.upperValue
        
        presenter
            .sliderValueChanged(protein: protein,
                                fat: fat,
                                carbohydrate: carbohydrate)
    }
}

extension RatioConverterViewController: RatioConverterPresenterOutput {
    
    func setInitialValue(protein: Double,fat: Double,carbohydrate: Double,
                         presenter: RatioConverterPresenterInput) {
        rangeSlider.maximumValue = 100.0
        rangeSlider.minimumValue = 0.0
        rangeSlider.lowerValue = protein
        rangeSlider.upperValue = protein + fat
        //sliderValueにも設定
        presenter
            .sliderValueChanged(protein: protein,
                                fat: fat,
                                carbohydrate: carbohydrate)
    }
    
    func updateChart(with dataSet: PieChartDataSet) {
        dataSet.colors = ChartColorTemplates.liberty()
        dataSet.valueTextColor = UIColor.black
        dataSet.entryLabelColor = UIColor.black
        chartsView.data = PieChartData(dataSet: dataSet)
        
        // データを％表示にする
        let dataSetFormatter = dataSetFormat()
        chartsView.data?
          .setValueFormatter(DefaultValueFormatter(formatter: dataSetFormatter))
        chartsView
          .usePercentValuesEnabled = true
    }
    
    func updateNPCNRatio(valueString: String) {
        npcnRatioLabel.text = valueString
    }
    
    func updateNutritionLabel(in pfcRatio: (protein: Double, fat: Double, carbohydrate: Double)) {
        proteinLabel.text = String(format: "%.1f", pfcRatio.protein)
        fatLabel.text = String(format: "%.1f", pfcRatio.fat)
        carbohydrateLabel.text = String(format: "%.1f", pfcRatio.carbohydrate)
    }
}
