//
//  SearchBlogNetwork.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/13/23.
//

import Foundation

struct APIConstant {
  let apikey: String = Bundle.main.apiKey
  let contentType: String = "application/x-www-form-urlencoded;charset=utf-8"
}

@MainActor
class SearchBlogNetwork: ObservableObject {
  private let session: URLSession
  
  @Published var results: [Document] = []
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  // TODO: SearchNetworkError 에러핸들링
  @MainActor
  func searchBlog(query: String, page: Int) async throws {
    guard let url = URL.makeURL(query: query, page: String(page)).url else {
      print("SearchNetworkError.invalidURL")
      throw SearchNetworkError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue(APIConstant().apikey, forHTTPHeaderField: "Authorization")
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      print(response)
      throw SearchNetworkError.failedHTTPRequest
    }
    
    let output = try JSONDecoder().decode(RequestResult.self, from: data).documents
    print("output", output)
    results += output 
  }
}
