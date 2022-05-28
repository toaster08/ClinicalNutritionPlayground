//
//  RatioConverterUseCase.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import Foundation

protocol RatioConverterUseCaseInput {
    func createPFCRatio(protein: Double, fat: Double, carbohydrate: Double) -> PFCRatio?
    func convertNPCNRatio(from pfcRatio: PFCRatio) -> Double?
}

class RatioConverterUseCase: RatioConverterUseCaseInput {
    
    func createPFCRatio(protein: Double, fat: Double, carbohydrate: Double) -> PFCRatio? {
        return PFCRatio(protein: protein, fat: fat, carbohydrate: carbohydrate) ?? nil
    }
    
    func convertNPCNRatio(from pfcRatio: PFCRatio) -> Double? {
        let npcnRatio = NPCNRatio(pfcRatio: pfcRatio).Value
    
        switch  npcnRatio {
        case .infinity : return .infinity
        case .nan: return nil
        default : return npcnRatio
        }
    }
}
