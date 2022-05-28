//
//  Person.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import Foundation

enum SexType: Int {
    //生物学的な性別
    case male = 0
    case female
}

struct Person {
    private(set) var age: Int?
    private(set) var sex: SexType?
    private(set) var height: Float
    private(set) var weight: Float
    
    init?(height: Float, weight: Float, age: Int?, sex: SexType?) {
        guard 0 <= height, 0 <= weight else { return nil }
        
        if let age = age, let sex = sex {
            self.height = height
            self.weight = weight
            self.age = age
            self.sex = sex
        } else {
            self.height = height
            self.weight = weight
            self.age = nil
            self.sex = nil
        }
    }
}


