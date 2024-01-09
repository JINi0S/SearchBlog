//
//  MainView.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/8/23.
//

import SwiftUI

struct MainView: View {
  @State var tags: [String] = ["서울", "쏘카", "포항", "애플아카데미"]
  @StateObject var vm = SearchBlogNetwork()
  @State var showSearchBar: Bool = false
  @State var searchText = ""
  @State var page: Int = 1
  @State var currentTag: String = ""
  
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return formatter
  }()
  
  let displayDateFormat: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter
  }()
  
  @State private var dateString = "2023-11-15T23:58:47.000+09:00"
  @State private var convertedDate: String?
  
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
            showSearchBar.toggle()
          } label: {
            Image(systemName: showSearchBar ?  "chevron.up":"plus")
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
    let string = htmlString.replacingOccurrences(of: "<[^>]+>|&quot;|&#39;|&#34;|&#lt;|&#gt;|&lt;|&gt;", with: "", options: .regularExpression, range: nil)
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
        vm.results = []
        tags.append(searchText)
        currentTag = searchText
        Task {
          try await vm.searchBlog(query: currentTag, page: 1)
        }
        showSearchBar = false
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
            .bold()
        }
        Button {
          let idx = tags.firstIndex(of: tag)
          tags.remove(at: Int(idx!))
        } label: {
          Image(systemName: "xmark")
            .resizable()
            .frame(width: 10, height: 10)
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 4)
      .foregroundStyle(currentTag == tag ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8))
      .background(currentTag == tag ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2) )
      .clipShape(RoundedRectangle(cornerRadius: 20))
    }
  }
  
  @MainActor
  private var scrollView: some View {
    ScrollView {
      LazyVStack(alignment: .leading) {
        ForEach(vm.results, id: \.url) { item in
          NavigationLink {
            WebView(urlToLoad: item.url)
          } label: {
            VStack(alignment: .leading, spacing: 4) {
              
              Text(stripHTMLTags(from: item.title))
                .font(.headline)
                .multilineTextAlignment(.leading)

              if let convertedDate = formatString(dateString: item.datetime) {
                Text(convertedDate)
                  .font(.caption2)
                  .foregroundStyle(Color.gray.opacity(0.7))
              }
              
              HStack(alignment: .top) {
                Text(stripHTMLTags(from: item.contents))
                  .font(.callout)
                  .foregroundStyle(Color.gray)
                  .multilineTextAlignment(.leading)
                  .lineLimit(3)
                
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
              }
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
                page += 1
                Task {
                  do {
                    try await vm.searchBlog(query: currentTag, page: page)
                  } catch { }
                }
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity)
    }
    .refreshable {
      page = 1
      vm.results = []
      Task {
        do {
          try await vm.searchBlog(query: currentTag, page: page)
        } catch { }
      }
    }
  }
  
  func formatString(dateString: String) -> String? {
    if let date = dateFormatter.date(from: dateString) {
      return displayDateFormat.string(from: date)
    } else {
      return nil
    }
  }
  
  func dateFormat(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    if let date = dateFormatter.date(from: dateString) {
      return dateFormatter.string(from: date)
    } else {
      return dateString
    }
  }
}

#Preview {
  MainView()
}
