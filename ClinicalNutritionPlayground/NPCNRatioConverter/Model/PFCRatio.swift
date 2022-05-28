//
//  PFCRatio.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import Foundation

struct PFCRatio {
    let protein: Double
    let fat: Double
    let carbohydrate: Double
    
    init?(protein: Double, fat: Double, carbohydrate: Double) {
        guard protein >= 0 || fat >= 0 || carbohydrate >= 0 else {
            return nil
        }
        
        guard (protein + fat + carbohydrate) == 100 else {
            return nil
        }
        
        self.protein = protein
        self.fat = fat
        self.carbohydrate = carbohydrate
    }
}

struct NPCNRatio {
    private var nitrogen: Double
    private var fatEnergy: Double
    private var carbohydrateEnergy: Double
    
    var nonProteinEnergy: Double {
        fatEnergy + carbohydrateEnergy
    }
    
    var Value: Double {
        let value = nonProteinEnergy / nitrogen
        return round(value)
    }
    
    init(pfcRatio: PFCRatio) {
        nitrogen = (pfcRatio.protein) / 4 * 0.16
        fatEnergy = pfcRatio.fat
        carbohydrateEnergy = pfcRatio.carbohydrate
    }
}
