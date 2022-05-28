//
//  APIClient.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/17.
//

import Foundation

enum ResultError: Error {
    case invalidURL
    case invalidData
    case failedDecoding
}

//Parse
struct EStatData: Decodable {
    var statClassObjects: [StatClassObject]
    var statDataObjects: [StatDataObject]
    
    enum CodingKeys: String, CodingKey {
        case getStatData = "GET_STATS_DATA"
        case statisticalData = "STATISTICAL_DATA"
        //StatClassObject
        case classInfo = "CLASS_INF"
        case classObject = "CLASS_OBJ"
        //StatDataObject
        case dataInfo = "DATA_INF"
        case dataValue = "VALUE"
    }
    
    struct StatClassObject: Decodable {
        var id: String
        var name: String
        var contents: [Content]?
    }
    
    enum StatClassCodingKeys: String, CodingKey {
        case id = "@id"
        case name = "@name"
        case contents = "CLASS"
    }
    
    struct Content:Decodable {
        var code: String
        var name: String
        var level: String
        var parentCode: String?
        
        enum CodingKeys: String, CodingKey {
            case code = "@code"
            case name = "@name"
            case level = "@level"
            case parentCode = "@parentCode"
        }
    }
    
    struct StatDataObject: Decodable {
        var tab: String
        var catOne: String
        var catSecond: String
        var catThird: String
        var time: String
        var value: String
        
        enum CodingKeys: String, CodingKey {
            case tab = "@tab"
            case catOne = "@cat01"
            case catSecond = "@cat02"
            case catThird = "@cat03"
            case time = "@time"
            case value = "$"
        }
    }
}

//Custom Decode
extension EStatData {
    init(from decoder: Decoder) throws {
        do {
            let container
            = try decoder
                .container(keyedBy: CodingKeys.self)
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .getStatData)
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .statisticalData)
            
            var statClassObjectContainer
            = try container
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .classInfo)
                .nestedUnkeyedContainer(forKey: .classObject)
            
            var statDataObjectContainer
            = try container
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .dataInfo)
                .nestedUnkeyedContainer(forKey: .dataValue)
            
            var statClassObjects:[StatClassObject] = .init()
            
            while !statClassObjectContainer.isAtEnd {
                let statClassObjectContainer
                = try statClassObjectContainer
                    .nestedContainer(keyedBy: StatClassCodingKeys.self)
                
                let id = try statClassObjectContainer.decode(String.self, forKey: .id)
                let name = try statClassObjectContainer.decode(String.self, forKey: .name)
                if let contents = try? statClassObjectContainer.decode([Content].self, forKey: .contents) {
                    let statClassObject = StatClassObject(id: id, name: name, contents: contents)
                    statClassObjects.append(statClassObject)
                } else {
                    let content = try statClassObjectContainer.decode(Content.self, forKey: .contents)
                    let contents = [content]
                    let statClassObject = StatClassObject(id: id, name: name, contents: contents)
                    statClassObjects.append(statClassObject)
                }
            }
            
            var statDataObjects:[StatDataObject] = []
            while !statDataObjectContainer.isAtEnd {
                let dataObject = try statDataObjectContainer.decode(StatDataObject.self)
                statDataObjects.append(dataObject)
            }
            
            self.statClassObjects = statClassObjects
            self.statDataObjects = statDataObjects
        } catch {
            throw ResultError.failedDecoding
        }
    }
}

class APIClient {
    
    let url = "http://api.e-stat.go.jp/rest/3.0/app/json/getStatsData?cdCat02=170%2C290%2C300%2C320%2C340%2C440%2C450&cdCat03=1&cdCat01=110%2C130%2C150%2C170%2C190%2C210%2C230&appId=f513b61021309aaaa7e5f0b537f7dafc330669da&lang=J&statsDataId=0003289686&metaGetFlg=Y&cntGetFlg=N&explanationGetFlg=Y&annotationGetFlg=Y&sectionHeaderFlg=1&replaceSpChars=0"
        
    //completion Handlerを利用してのAPI通信
    func fetchDataUsingCompletionHandler(completion: @escaping ((Result<EStatData,ResultError>) -> Void)){
        guard let getURL = URL(string: self.url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: getURL)
        
        let task: URLSessionTask
        = URLSession
            .shared
            .dataTask(with: request) { data, response, error in
                print(#file, Thread.current)
                
                guard let data = data else {
                    completion(.failure(.invalidData))
                    return
                }
                
                guard let statData
                        = try?
                        JSONDecoder()
                        .decode(EStatData.self,
                                from: data)  else {
                            completion( .failure(.failedDecoding))
                            return
                        }
                completion(.success(statData))
            }
        task.resume()
    }
    
    //async/awaitを利用してのAPI通信
    func fetchDataUsingAsyncAwait() async throws -> EStatData {
        let getURL = URL(string: self.url)
        let request = URLRequest(url: getURL!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let statData = try JSONDecoder().decode(EStatData.self, from: data)
        
        return statData
    }
}
