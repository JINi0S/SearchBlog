//
//  WebView.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/15/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  
  var urlToLoad: String
  
  func makeUIView(context: Context) -> WKWebView {
    guard let url = URL(string: self.urlToLoad) else {
      return WKWebView()
    }
    let webView = WKWebView()
    
    webView.load(URLRequest(url: url))
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {    
  }
}

#Preview {
  WebView(urlToLoad: "https://www.naver.com")
}
