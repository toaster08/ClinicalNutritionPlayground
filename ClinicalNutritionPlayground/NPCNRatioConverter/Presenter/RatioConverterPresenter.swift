//
//  Presenter.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import Charts

protocol RatioConverterPresenterInput: AnyObject {
    func sliderValueChanged(protein: Double, fat: Double, carbohydrate: Double)
}

protocol RatioConverterPresenterOutput: AnyObject {
    func setInitialValue(protein: Double,fat: Double,carbohydrate: Double,presenter: RatioConverterPresenterInput)
    func updateChart(with dataSet: PieChartDataSet)
    func updateNPCNRatio(valueString: String)
    func updateNutritionLabel(in pfcRatio: (protein: Double, fat: Double, carbohydrate: Double))
}

extension RatioConverterPresenterOutput {
    func setInitialValue(protein: Double = 15,
                         fat: Double = 25,
                         carbohydrate: Double = 60,
                         presenter: RatioConverterPresenterInput) {
        
        setInitialValue(protein: protein,
                        fat: fat,
                        carbohydrate: carbohydrate,
                        presenter: presenter)
    }
}

class RatioConverterPresenter: RatioConverterPresenterInput {
    
    private weak var view: RatioConverterPresenterOutput!
    private var model: RatioConverterUseCaseInput!
    
    init(view: RatioConverterPresenterOutput,
         model: RatioConverterUseCaseInput) {
        self.view = view
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sliderValueChanged(protein: Double, fat: Double, carbohydrate: Double) {
        guard let pfcRatio
                = model.createPFCRatio(protein: protein, fat: fat, carbohydrate: carbohydrate) else { return }
        
        let npcnValue = model.convertNPCNRatio(from: pfcRatio)
        let npcnValueString = format(npcnValue: npcnValue)
        view.updateNPCNRatio(valueString: npcnValueString)
        
        let dataSet = createDataSet(protein: protein, fat: fat, carbohydrate: carbohydrate)
        view.updateChart(with: dataSet)
        
        view.updateNutritionLabel(in: (protein: protein,
                                       fat: fat,
                                       carbohydrate: carbohydrate))
    }
    
    private func format(npcnValue: Double?) -> String {
        
        guard let npcnValue = npcnValue else { return "invalid number" }

        switch npcnValue {
        case .infinity: return "∞"
        case .nan: return "not a number"
        default: return String(format: "%.f", npcnValue)
        }
    }
    
    private func createDataSet(protein: Double, fat: Double, carbohydrate: Double) -> PieChartDataSet {
        let dataEntries = [
            PieChartDataEntry(value: protein, label: "たんぱく質"),
            PieChartDataEntry(value: fat, label: "脂質"),
            PieChartDataEntry(value: carbohydrate, label: "炭水化物")
        ]
        
        let dataSet = PieChartDataSet(entries: dataEntries,
                                      label: "PFCバランス")
        return dataSet
    }
    
}
