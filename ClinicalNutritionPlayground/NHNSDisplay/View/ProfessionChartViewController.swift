//
//  ProfessionChartViewController.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/17.
//
import Foundation
import UIKit
import Charts

class ProfessionChartViewController: UIViewController {
    
    private lazy var viewModel = ProfessionalChartViewModel()
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var professionPickerView: UIPickerView!

    let statDataUseCase = StatDataUseCase()
    var sampleData:[Double: Double] = [:]
    var professionList: [String] = [
        "管理栄養士",
        "薬剤師",
        "作業療法士（ＯＴ）",
        "理学療法士（ＰＴ）",
        "栄養士",
        "歯科衛生士"
    ]
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        professionPickerView.delegate = self
        professionPickerView.dataSource = self
        
        setup()
        configure()
    }
    
    func configure() {
        statDataUseCase.enableEStatData {
            DispatchQueue.main.async { [weak self] in
                let object = self?.statDataUseCase.getEmployee(by: (self?.professionList[0])!)
                self?.sampleData = [:]
                object?.forEach {
                    let age = Double($0.age) ?? 0
                    let value = Double($0.value)
                    self?.sampleData[age] = value
                }
                self?.displayChart(data: self!.sampleData)
            }
        }
    }
    
    func setup() {
        navigationController?
            .navigationBar
            .backItem?
            .backBarButtonItem?
            .tintColor
        = .white
        
        let color3 = UIColor(named: "Color")?.cgColor
        let color2 = UIColor(named: "Color-1")?.cgColor
        let color1 = UIColor(named: "Color-2")?.cgColor
        
        let gradLayer = CAGradientLayer()
        gradLayer.frame = view.frame
        gradLayer.colors = [color3, color2, color1]
        gradLayer.startPoint = .init(x: 0, y: 00)
        gradLayer.endPoint = .init(x: 0, y: 1.0)
        view.layer.insertSublayer(gradLayer, at: 0)
    }
    
    func displayChart(data: [Double: Double]) {
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [BarChartDataEntry]()
        
        data.forEach {
            let dataEntry
            = BarChartDataEntry(x: $0.key, y: $0.value)
            dataEntries.append(dataEntry)
        }
        
        // グラフにデータを適用
        var barChartDataSet: BarChartDataSet!
        barChartDataSet = BarChartDataSet(entries: dataEntries, label: "SampleDataChart")
        barChartDataSet.colors = [.white]
        barChartDataSet.valueTextColor = .white
        
        barChartView.data
        = BarChartData(dataSet: barChartDataSet)
        
        // X軸(xAxis)
        barChartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
        barChartView.barData?.barWidth = 6
        barChartView.gridBackgroundColor = .white
        barChartView.rightAxis.enabled = false // 右側の縦軸ラベルを非表示
        barChartView.xAxis.labelTextColor = .white
        // Y軸(leftAxis/rightAxis)
        barChartView.leftAxis.axisMaximum = self.sampleData.values.max() ?? 100 //y左軸最大値
        barChartView.leftAxis.axisMinimum = 0 //y左軸最小値
        barChartView.leftAxis.labelCount = self.sampleData.keys.count // y軸ラベルの数
        barChartView.leftAxis.axisLineColor = .white
        barChartView.leftAxis.zeroLineColor = .white
        barChartView.leftAxis.gridColor = .white
        barChartView.leftAxis.labelTextColor = .white
        // その他の変更
        barChartView.highlightPerTapEnabled = false // プロットをタップして選択不可
        barChartView.legend.enabled = false // グラフ名（凡例）を非表示
        barChartView.pinchZoomEnabled = false // ピンチズーム不可
        barChartView.doubleTapToZoomEnabled = false // ダブルタップズーム不可
        barChartView.extraTopOffset = 20 // 上から20pxオフセットすることで上の方にある値(99.0)を表示する
        barChartView.animate(xAxisDuration: 0) // 2秒かけて左から右にグラフをアニメーションで表示する
        //        view.addSubview(chartView)
    }
}

extension ProfessionChartViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return viewModel.professionList.count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        pickerView.setValue(UIColor.white, forKey: "textColor")
        return viewModel.professionList[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let object = statDataUseCase.getEmployee(by: self.professionList[row])
        self.sampleData = [:]
        object.forEach {
            let age = Double($0.age) ?? 0
            let value = Double($0.value)
            self.sampleData[age] = value
        }
//        let sampleData = viewModel.loadData(at: row)
        self.displayChart(data: sampleData)
    }
}
