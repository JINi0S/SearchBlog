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
  
  func searchBlog(query: String) -> URLComponents {
    var components = URLComponents()
    components.scheme = SearchBlogAPI.scheme
    components.host = SearchBlogAPI.host
    components.path = SearchBlogAPI.path + "blog"
    
    components.queryItems = [
      URLQueryItem(name: "query", value: query),
      URLQueryItem(name: "sort", value: "recency"),
      URLQueryItem(name: "size", value: "20")
      
    ]
    
    return components
  }
}

struct APIConstant {
  let apikey: String = "KakaoAK 395c3fbe7050fa43296c44658fbdd1d3"
  let contentType: String = "application/x-www-form-urlencoded;charset=utf-8"
}

enum SearchNetworkError: String, Error {
  case invalidURL = "유효하지 않은 URL입니다."
  case invalidJSON = "유효하지 않은 JSON입니다."
  case failedHTTPRequest = "HTTP 요청에 실패헸습니다."
  case networkError = "네트워크를 확인해주세요."
}

@MainActor
class SearchBlogNetwork: ObservableObject {
  private let session: URLSession
  let api = SearchBlogAPI()
  
  @Published var results = [Document(title: "", contents: "", url: "", blogname: "", thumbnail: "", datetime: "")]//[Document]()]
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  @MainActor
  func searchBlog(query: String) async throws {
    guard let url = api.searchBlog(query: query).url else {
      throw SearchNetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(APIConstant().apikey, forHTTPHeaderField: "Authorization")
    let (data, response) = try await URLSession.shared.data(for: request)//URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      throw SearchNetworkError.failedHTTPRequest
    }
    
    let output = try? JSONDecoder().decode(RequestResult.self, from: data)
    
    results = output?.documents ?? []
//    let task = session.dataTask(with: request, completionHandler: {[weak self] data, response, error in
//      guard let data = data, let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
//        print("Error: HTTP request failed\(SearchNetworkError.failedHTTPRequest.rawValue) \(data!) \(response!)")
//        return
//      }
//      guard let output = try? JSONDecoder().decode(RequestResult.self, from: data) else {
//        print("Error: JSON data parsing failed")
//        return
//      }
//
//      DispatchQueue.main.async { [weak self] in
//        self!.results = output.documents
//      }
//
//    }
//    )
//    // 통신 시작
//    task.resume()
  }
}
