//
//  PersonProfileUseCase.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import Foundation

//not error type
enum CalculatorResult<T> {
    case success(T)
    case failure
}

protocol PersonProfileUseCaseProtocol {
    func profiledPerson(height: Float,
                        weight: Float,
                        age: Int?,
                        sex: SexType?) -> Person?
    func calculateBMI(in person: Person) -> Float
    func calculateRohrerIndex(in person: Person) -> Float
    func calculateObesityIndex(in person: Person) -> CalculatorResult<Float>
    func calculateStandardBodyWeight(for person: Person) -> CalculatorResult<Float>
}

enum BodyMassIndexType {
    case underweight
    case normalRange
    case preObese
    case obeseClassⅠ
    case obeseClassⅡ
    case obeseClassⅢ
    case none

    var description: String {
        switch self {
        case .underweight: return "低体重"
        case .normalRange: return "標準"
        case .preObese: return "肥満（１度）"
        case .obeseClassⅠ: return "肥満（２度）"
        case .obeseClassⅡ: return "肥満（３度）"
        case .obeseClassⅢ: return "肥満（4度）"
        case .none: return "範囲外"
        }
    }
    
    init?(bmi: Float) {
        self = .none
        let group = self.classifyGroup(for: bmi)
        self = group
    }
    
    func classifyGroup(for bmi: Float) -> Self {
        switch bmi {
        case 40.0...: return .obeseClassⅢ
        case 35.0..<40.0: return .obeseClassⅡ
        case 30.0..<35.0: return .obeseClassⅠ
        case 25.0..<30.0: return .preObese
        case 18.5..<25.0: return .normalRange
        case ..<18.5: return .underweight
        default: return .none
        }
    }
}

enum RohrerIndexType {
    case underweight
    case preUnderWeight
    case normalRange
    case preOverWeight
    case overWeight
    case none

    var description: String {
        switch self {
        case .underweight: return "やせすぎ"
        case .preUnderWeight: return "やせぎみ"
        case .normalRange: return "普通"
        case .preOverWeight: return "太りぎみ"
        case .overWeight : return "太りすぎ"
        case .none: return "範囲外"
        }
    }
    
    init?(rohrerIndex: Float) {
        self = .none
        let group = self.classifyGroup(for: rohrerIndex)
        self = group
    }
    
    func classifyGroup(for rohrerIndex: Float) -> RohrerIndexType {
        switch rohrerIndex {
        case 160...: return .overWeight
        case 145..<160: return .preOverWeight
        case 115..<145: return .normalRange
        case 100..<115: return .preUnderWeight
        case ..<100: return .underweight
        default: return .none
        }
    }
}

enum ObesityIndexType {
    case severeObesity
    case moderateObesity
    case mildObesity
    case normalRange
    case none

    var description: String {
        switch self {
        case .severeObesity: return "高度肥満"
        case .moderateObesity: return "中等度肥満"
        case .mildObesity: return "軽度肥満"
        case .normalRange: return "普通"
        case .none: return "範囲外"
        }
    }
    
    init?(obesityIndex: Float) {
        self = .none
        let group = self.classifyGroup(for: obesityIndex)
        self = group
    }
    
    func classifyGroup(for obesityIndex: Float) -> ObesityIndexType {
        switch obesityIndex {
        case 50...: return .severeObesity
        case 30..<50: return .moderateObesity
        case 20..<30: return .mildObesity
        case -20..<20: return .normalRange
        default: return .none
        }
    }
}

class PersonProfileUseCase: PersonProfileUseCaseProtocol {
    
    func profiledPerson(height: Float, weight: Float, age: Int?, sex: SexType?) -> Person? {
        //result使ってしまってるが本来必要なさそう
        guard let person
                = Person(height: height, weight: weight, age: age, sex: sex) else {
                    return nil
                }
        return person
    }
    
    func calculateBMI(in person: Person) -> Float {
        let bmi = person.weight / pow((person.height * 0.01), 2)
        return bmi
    }
    
    func calculateRohrerIndex(in person: Person) -> Float {
        let rohrerIndex = person.weight / pow((person.height * 0.01),3) * 10
        return rohrerIndex
    }
    
    func calculateObesityIndex(in person: Person) -> CalculatorResult<Float> {
        guard let age = person.age,
              let standardBodyWeight =  calculateStandardWeightForChild(in: person) else {
                  return .failure
              }

        if age < 18 {
            let bodyWeight = person.weight
            let obesityIndex = (bodyWeight - standardBodyWeight) / standardBodyWeight * 100
            return .success(obesityIndex)
        } else {
            return .failure
        }
        
    }
    
    func calculateStandardBodyWeight(for person: Person) -> CalculatorResult<Float> {
        guard let age = person.age else { return .failure }
        
        if age < 18 {
            guard let standardBodyWeight
                    = calculateStandardWeightForChild(in: person) else {
                return .failure
            }
            return .success(standardBodyWeight)
            
        } else if 18 <= age {
            guard let standardBodyWeight
                    = calculateStandardWeightForAdult(in: person) else {
                return .failure
            }
            return .success(standardBodyWeight)
            
        } else {
            return .failure
        }
    }
    
    //age 18-
    private func calculateStandardWeightForAdult(in person: Person) -> Float? {
        guard let age = person.age, 18 <= age else { return nil }
        let height = person.height * 0.01
        return height * height * 22.0
    }
    
    //age -17
    private func calculateStandardWeightForChild(in person: Person) -> Float? {
        guard let sex = person.sex,
              let age = person.age, age < 18 else { return nil }
        
        //身長cm
        let height = person.height
        //テストコード必要
        let pattern = (age: age, height: height)
        switch sex {
        case .male:
            switch pattern {
            case (age: ..<6 , height: 70..<120) :
                return 0.00206 * pow(height, 2) - 0.1166 * height + 6.5273
            case (age: 6... , height: 100..<140) :
                return 0.0000303882 * pow(height, 3) - 0.00571495 * pow(height, 2) + 0.508124 * height - 9.17791
            case (age: 6... , height: 140..<149) :
                return -0.000085013 * pow(height, 3) + 0.0370692 * pow(height, 2) - 4.6558 * height + 191.847
            case (age: 6... , height: 149..<184) :
                return -0.000310205 * pow(height, 3) + 0.151159 * pow(height, 2) - 23.6303 * height + 1231.04
            default : return nil
            }
        case .female:
            switch pattern {
            case (age: ..<6 , height: 70..<120 ) :
                return 0.00249 * pow(height, 2) - 0.1858 * height + 9.0360
            case (age: 6... , height: 100..<140) :
                return 0.000127719 * pow(height, 3) - 0.0414712 * pow(height, 2) + 4.8575 * height - 184.492
            case (age: 6... , height: 140..<149) :
                return -0.00178766 * pow(height, 3) + 0.803922 * pow(height, 2) - 119.31 * height + 5885.03
            case (age: 6... , height: 149..<171) :
                return 0.000956401 * pow(height, 3) - 0.462755 * pow(height, 2) + 75.3058 * height - 4068.31
            default : return nil
            }
        }
    }
    
    func targetBMI(for person: Person) -> ClosedRange<Float>? {
        guard let age = person.age else { return nil }
        switch age {
        case 18..<49: return (18.5...24.9)
        case 49..<64: return (20.0...24.9)
        case 65..<74: return (21.5...24.9)
        case 75...: return (21.5...24.9)
        default: return nil
        }
    }
}


