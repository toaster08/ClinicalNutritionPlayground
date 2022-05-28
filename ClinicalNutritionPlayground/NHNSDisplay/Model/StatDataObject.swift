//
//  EStatDataObject.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/17.
//

import Foundation

struct ProfessionProfile {
    let categoryID: String
    let categoryName: String
    let professionCode: String
    let professionName: String
}

struct AgeProfile {
    let ageID: String
    let ageName: String
    let ageCode: String
    let ageCOdeName: String
}

struct ProfessionEmployeeData {
    var age: String
    var job: String
    var file: String
    var value: String
}
