//
//  StatDataUseCase.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/27.
//

import Foundation

protocol StatDataUseCaseProtocol {
    func enableEStatData(completion: @escaping () -> Void)
    func getEmployee(by jobName: String) -> [ProfessionEmployeeData]
    func getProfessionNameList() -> [String]
}

class StatDataUseCase: StatDataUseCaseProtocol{
    
    let apiClient = APIClient()
    var professions: [ProfessionProfile] = []
    var ages: [AgeProfile] = []
    var datas: [ProfessionEmployeeData] = []
    
    func enableEStatData(completion: @escaping () -> Void) {
        Task {
            do {
                let result =  try await apiClient.fetchDataUsingAsyncAwait()
                result.statClassObjects.forEach { [weak self] object in
                    if object.name.contains("職種") {
                        let categoryId = String(object.id)
                        let categoryName = String(object.name)
                        _ = object.contents.map { [weak self] container in
                            container.map { content in
                                let contentCode = content.code
                                let contentName = content.name
                                let job = ProfessionProfile(categoryID: categoryId,
                                                             categoryName: categoryName,
                                                             professionCode: contentCode,
                                                             professionName: contentName)
                                professions.append(job)
                            }
                        }
                    }
                }
                
                result.statClassObjects.forEach { object in
                    if object.name.contains("年次") {
                        let ageId = String(object.id)
                        let ageName = String(object.name)
                        _ = object.contents.map { [weak self] container in
                            container.map { content in
                                let ageCode = content.code
                                let ageCodeName = content.name
                                let age = AgeProfile(ageID: ageId,
                                                           ageName: ageName,
                                                           ageCode: ageCode,
                                                           ageCOdeName: ageCodeName)
                                ages.append(age)
                            }
                        }
                    }
                }
                
                result.statDataObjects.forEach { [weak self] object in
                    let data = ProfessionEmployeeData(age: object.catOne,
                                                 job: object.catSecond,
                                                 file: object.catThird,
                                                 value: object.value)
                    datas.append(data)
                }
                completion()
            } catch {
        
            }
        }
    }
    
    func getEmployee(by jobName: String) -> [ProfessionEmployeeData] {
            let jobCode = professions.filter {
                $0.professionName == jobName ? true : false
            }.first?.professionCode
            
            let data = datas.filter {
                $0.job == jobCode ? true : false
            }
            return data
    }
    
    func getProfessionNameList() -> [String] {
        let professionNameList = professions.map {
            $0.professionName
        }
        return professionNameList
    }
}
