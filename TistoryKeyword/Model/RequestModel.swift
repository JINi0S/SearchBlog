//
//  RequestModel.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/20/23.
//

import Foundation

// MARK: - RequestResult
struct RequestResult: Codable {
  //let meta: Meta
  let documents: [Document]
}

// MARK: - Document
struct Document: Codable {
  let title, contents: String
  let url: String
  let blogname: String
  let thumbnail: String
  let datetime: String
}

// MARK: - Meta
struct Meta: Codable {
    let totalCount, pageableCount: Int
    let isEnd: Bool

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case pageableCount = "pageable_count"
        case isEnd = "is_end"
    }
}
