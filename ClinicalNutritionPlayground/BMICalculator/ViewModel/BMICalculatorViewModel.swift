//
//  ViewModel.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import Foundation

final class BMICalculatorViewModel {
    
    let changeBMI = Notification.Name("changeBMI")
    let changeRohrerIndex = Notification.Name("changeRohrerIndex")
    let changeObesityIndex = Notification.Name("changeObesityIndex")
    let changeStandardBodyWeight = Notification.Name("changeStandardBodyWeight")
    
    private let notificationCenter: NotificationCenter
    private let personProfileUseCase: PersonProfileUseCaseProtocol
    
    init(notificationCenter: NotificationCenter,
         personProfileUseCase: PersonProfileUseCaseProtocol = PersonProfileUseCase()) {
        self.notificationCenter = notificationCenter
        self.personProfileUseCase = personProfileUseCase
    }
    
    func profileValueChanged(height: Float, weight: Float,age: Int?, sex: SexType?) {
        guard let person
                = personProfileUseCase
                .profiledPerson(height: height,
                                weight: weight,
                                age: age,
                                sex: sex) else {
                    
                    return
                }
        
        
        let bmiValue = personProfileUseCase.calculateBMI(in: person)
        let bmiValueString = String(format: "%.1f", bmiValue)
        
        let rohrerIndex = personProfileUseCase.calculateRohrerIndex(in: person)
        let rohrerIndexString = String(format: "%.1f", rohrerIndex)
        
        let result = personProfileUseCase.calculateObesityIndex(in: person)
        let obesityIndexString: String
        switch result {
        case .success(let result):
            obesityIndexString = String(format: "%.1f", result)
        case .failure:
            obesityIndexString = "---"
        }
        
        let calculateSBW = personProfileUseCase.calculateStandardBodyWeight(for: person)
        let standardBodyWeightString: String
        switch calculateSBW {
        case .success(let result):
            standardBodyWeightString = String(format: "%.1f", result)
        case .failure:
            standardBodyWeightString = "---"
        }
        
        notificationCenter
            .post(name: changeBMI,
                  object: bmiValueString)
        notificationCenter
            .post(name: changeRohrerIndex,
                  object: rohrerIndexString)
        notificationCenter
            .post(name: changeObesityIndex,
                  object: obesityIndexString)
        notificationCenter
            .post(name: changeStandardBodyWeight,
                  object: standardBodyWeightString)
    }
}
