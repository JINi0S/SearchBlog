//
//  Ex+URL.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 1/10/24.
//

import Foundation

extension URL {
  static let scheme = "https"
  static let host = "dapi.kakao.com"
  static let path = "/v2/search/"
  
  static func makeURL(query: String, page: String) -> URLComponents {
    var components = URLComponents()
    components.scheme = self.scheme
    components.host = self.host
    components.path = self.path + "blog"
    components.queryItems = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "sort", value: "recency"),
      URLQueryItem(name: "page", value: page),
      URLQueryItem(name: "size", value: "20")
    ]
    
    return components
  }
}
