//
//  ContentView.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/8/23.
//

import SwiftUI

struct ContentView: View {
  let document: Document
  
    var body: some View {
        VStack {
          Text(document.title)
            .font(.title)
          Text(document.contents)
            .font(.body)
        }
        .padding()
        .navigationTitle(document.blogname)
    }
}

#Preview {
  ContentView(document: Document(title: "", contents: "", url: "", blogname: "", thumbnail: "", datetime: ""))
}
