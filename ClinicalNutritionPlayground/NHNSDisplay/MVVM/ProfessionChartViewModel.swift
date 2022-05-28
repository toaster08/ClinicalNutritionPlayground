//
//  ProfessionChartViewModel.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/17.
//

import Foundation
import Charts

class ProfessionalChartViewModel {

    private var sampleData:[Double: Double] = [:]
    
    private(set) var professionList: [String] = [
        "管理栄養士",
        "薬剤師",
        "作業療法士（ＯＴ）",
        "理学療法士（ＰＴ）",
        "栄養士",
        "歯科衛生士"
    ]
    
    let statDataUseCase :StatDataUseCaseProtocol
    
    init(statDataUseCase: StatDataUseCaseProtocol = StatDataUseCase() ){
        self.statDataUseCase = statDataUseCase
        
        self.statDataUseCase.enableEStatData {
            DispatchQueue.main.async { [weak self] in
                let object = self?.statDataUseCase.getEmployee(by: (self?.professionList[0])!)
                self?.sampleData = [:]
                object?.forEach {
                    let age = Double($0.age) ?? 0
                    let value = Double($0.value)
                    self?.sampleData[age] = value
                }
            }
        }
    }
    
    func getProfessionCount() -> Int {
        professionList.count
    }
    
    func makeChartDataSet(data: [Double: Double],
                          completion: @escaping ((BarChartDataSet) -> Void)) {
        
        var dataEntries = [BarChartDataEntry]()
        
        data.forEach {
            let dataEntry
            = BarChartDataEntry(
                x: $0.key,
                y: $0.value
            )
            dataEntries.append(dataEntry)
        }
        var barChartDataSet: BarChartDataSet!
        barChartDataSet = BarChartDataSet(entries: dataEntries, label: "SampleDataChart")
        completion(barChartDataSet)
    }
    
    func loadData(at row: Int) -> [Double: Double]{
        let object = statDataUseCase.getEmployee(by: self.professionList[row])
        var sampleData: [Double: Double] = [:]
        
        object.forEach {
            let age = Double($0.age) ?? 0
            let value = Double($0.value)
            sampleData[age] = value
        }
        
        return sampleData
    }
}
