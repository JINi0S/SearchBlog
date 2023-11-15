//
//  MainView.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/8/23.
//

import SwiftUI

extension URL {
  static let baseURL = "https://dapi.kakao.com/v2/search/"
  
  static func makeEndPointString(_ endPoint: String) -> String {
    return baseURL + endPoint
  }
}

enum EndPoint {
  case blog
  case cafe
  
  var requestURL: String {
    switch self {
    case .blog:
      return URL.makeEndPointString("blog")
    case .cafe:
      return URL.makeEndPointString("cafe")
    }
  }
}

// MARK: - Welcome
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

//// MARK: - Meta
//struct Meta: Codable {
//    let totalCount, pageableCount: Int
//    let isEnd: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case totalCount = "total_count"
//        case pageableCount = "pageable_count"
//        case isEnd = "is_end"
//    }
//}


struct MainView: View {
  @State var tags: [String] = ["서울", "쏘카", "포항", "애플아카데미"]
  @StateObject var vm = SearchBlogNetwork()
  @State var showSearchBar: Bool = false
  @State var searchText = ""
  @State var page: Int = 1
  @State var currentTag: String = ""
  
  var body: some View {
    NavigationView {
      VStack {
        
        HStack {
          ScrollView(.horizontal) {
            HStack {
              tagListView
            }
          }
          .scrollIndicators(.hidden)
          
          Button {
            showSearchBar = true
          } label: {
            Image(systemName: "plus")
          }
        }
        .padding(.vertical, 12)
        
        if showSearchBar {
          searchBarView
        }
        
        scrollView
      }
      .padding(.top, 20)
      .padding(.horizontal, 20)
      .background(Color.gray.opacity(0.1))
    }
    .task {
      do {
        currentTag = tags.first!
        try await vm.searchBlog(query: currentTag, page: page)
      } catch {}
    }
  }
  
  func stripHTMLTags(from htmlString: String) -> String {
      var string = htmlString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
      string = string.replacingOccurrences(of: "&#39;", with: "", options: .regularExpression, range: nil)
      string = string.replacingOccurrences(of: "&#34;", with: "", options: .regularExpression, range: nil)

      return string
  }
  
  
}

extension MainView {
  private var searchBarView: some View {
    HStack {
      TextField(text: $searchText) {
        Text("키워드를 입력해주세요")
      }
      
      Button {
        showSearchBar = false
        tags.append(searchText)
        Task {
          try await vm.searchBlog(query: searchText, page: 1)
        }
      } label: {
        Image(systemName: "magnifyingglass")
      }
    }
    .padding(.all, 12)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.vertical, 6)
  }
  
  private var tagListView: some View {
    
    ForEach(tags, id: \.self) { tag in
      
      HStack {
        Button {
          Task {
            vm.results = []
            page = 1
            currentTag = tag
            try? await vm.searchBlog(query: currentTag, page: page)
          }
        } label: {
          Text(tag)
        }
        Button {
          let idx = tags.firstIndex(of: tag)
          tags.remove(at: Int(idx!))
        } label: {
          Image(systemName: "xmark")
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 4)
      .foregroundStyle(Color.blue.opacity(0.8))
      .background(Color.blue.opacity(0.2))
      .clipShape(RoundedRectangle(cornerRadius: 20))
    }
  }
  @MainActor
  private var scrollView: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        ForEach(vm.results, id: \.url) { item in
          NavigationLink {
            ContentView(document: item)
          } label: {
            HStack(spacing: 8) {
              /// Image item.thumbnail
              if let url = URL(string: item.thumbnail) {
                AsyncImage(url: url) { phase in
                  switch phase {
                  case .empty:
                    ProgressView()
                  case .success(let image):
                    image
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                  case .failure:
                    Image(systemName: "xmark.octagon.fill")
                      .font(.largeTitle)
                      .foregroundColor(.red)
                  @unknown default:
                    EmptyView()
                  }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
              }

              
              VStack(alignment: .leading) {
                Text(stripHTMLTags(from: item.title))
                  .font(.headline)
                Text(stripHTMLTags(from: item.contents))
                  .font(.body)
                  .foregroundStyle(Color.gray)
              }
              .multilineTextAlignment(.leading)
//              Text(item.datetime.toDate())
//                .font(.footnote)
            }
            .padding(.all, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.vertical, 4)
            .foregroundStyle(.black)
            .onAppear {
              if item.url == vm.results[vm.results.count-1].url {
                print(item.title)
                Task {
                  do {
                    page += 1
                    try await vm.searchBlog(query: currentTag, page: page)
                    print(vm.results)
                  } catch { }
                }
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity)
    }
  }
  
//  func dateFormat(_ dateString: String) -> String {
//    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateStyle = .medium
//    dateFormatter.timeStyle = .medium
//    if let date = dateFormatter.date(from: dateString) {
//      return dateFormatter.string(from: date)
//    } else {
//      print("here")
//      return dateString
//    }
//  }
  
}
extension String {
  func toDate() -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    if let date = dateFormatter.date(from: self) {
      return date
    } else {
      return nil
    }
  }
}


#Preview {
  MainView()
}
/*
 self.APITextView.text = self.dataSource[2].contents
               .replacingOccurrences(of: self.HTMLtag,
                                                   with: "",
                                                   options: .regularExpression,
                                                   range: nil)
 */
