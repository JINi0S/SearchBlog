//
//  SearchBlogNetwork.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/13/23.
//

import Foundation

struct SearchBlogAPI {
  static let scheme = "https"
  static let host = "dapi.kakao.com"
  static let path = "/v2/search/"
  
  func searchBlog(query: String, page: String) -> URLComponents {
    var components = URLComponents()
    components.scheme = SearchBlogAPI.scheme
    components.host = SearchBlogAPI.host
    components.path = SearchBlogAPI.path + "blog"
    print(page)
    components.queryItems = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "sort", value: "recency"),
      URLQueryItem(name: "page", value: page),
      URLQueryItem(name: "size", value: "20")
    ]
    
    return components
  }
}

struct APIConstant {
  let apikey: String = Bundle.main.apiKey
  let contentType: String = "application/x-www-form-urlencoded;charset=utf-8"
}

enum SearchNetworkError: String, Error {
  case invalidURL = "유효하지 않은 URL입니다."
  case failedHTTPRequest = "HTTP 요청에 실패헸습니다."
  case networkError = "네트워크를 확인해주세요."
}

@MainActor
class SearchBlogNetwork: ObservableObject {
  private let session: URLSession
  let api = SearchBlogAPI()
  
  @Published var results: [Document] = []
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  @MainActor
  func searchBlog(query: String, page: Int) async throws {
    guard let url = api.searchBlog(query: query, page: String(page)).url else {
      print("SearchNetworkError.invalidURL")
      throw SearchNetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(APIConstant().apikey, forHTTPHeaderField: "Authorization")
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      print("SearchNetworkError.failedHTTPRequest")
      print(response)
      throw SearchNetworkError.failedHTTPRequest
    }
    
    let output = try JSONDecoder().decode(RequestResult.self, from: data).documents
    print("output", output)
    results += output // ?? []// output?.documents ?? []
  }
}
