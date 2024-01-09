//
//  Ex+Error.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 1/10/24.
//

import Foundation

enum SearchNetworkError: String, Error {
  case invalidURL = "유효하지 않은 URL입니다."
  case failedHTTPRequest = "HTTP 요청에 실패헸습니다."
  case networkError = "네트워크를 확인해주세요."
}
