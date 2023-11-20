//
//  Ex+Bundle.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/17/23.
//

import Foundation

extension Bundle {
  
  var apiKey: String {
    guard let filePath = Bundle.main.path(forResource: "SecureAPIKeys", ofType: "plist"),
          let plistDict = NSDictionary(contentsOfFile: filePath) else {
      fatalError("Couldn't find file 'SecureAPIKeys.plist'.")
    }
    
    guard let value = plistDict.object(forKey: "API_KEY") as? String else {
      fatalError("Couldn't find key 'API_Key' in 'SecureAPIKeys.plist'.")
    }
    
    // 키 값을 통해 직접 가져오기
    // guard let value = plistDict["API_KEY"] as? String else {
    //     fatalError("Couldn't find key 'API_Key' in 'SecureAPIKeys.plist'.")
    // }
    
    return value
  }
}
