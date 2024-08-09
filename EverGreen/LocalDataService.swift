//
//  LocalDataService.swift
//  EverGreen
//
//  Created by Darul Firmansyah on 10/08/24.
//

import Foundation

protocol LocalDataServiceProtocol {
    func saveArrayInt(key: String, items: Set<Int>)
    func loadArrayInt(key: String) -> Set<Int>
    func storedModel(key: String, object: Encodable)
    func getModel<T>(key: String, modelType: T.Type) -> T? where T : Decodable
}

final class LocalDataService: LocalDataServiceProtocol {
    func saveArrayInt(key: String, items: Set<Int>) {
        let array = Array(items)
        UserDefaults.standard.set(array, forKey: key)
    }
    
    func loadArrayInt(key: String) -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: key) as? [Int] ?? [Int]()
        return Set(array)
    }
    
    func storedModel(key: String, object: Encodable) {
        do {
            let siteData = try JSONEncoder().encode(object)
            UserDefaults.standard.set(siteData, forKey: key)
        } catch {
            print(error)
        }
    }
    
    func getModel<T>(key: String, modelType: T.Type) -> T? where T : Decodable {
        if let json = UserDefaults.standard.data(forKey: key) {
            do {
                return try JSONDecoder().decode(modelType, from: json) as T
            } catch {
                return nil
            }
        }
        
        return nil
    }
}
