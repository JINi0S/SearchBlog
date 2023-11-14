//
//  ContentView.swift
//  TistoryKeyword
//
//  Created by Lee Jinhee on 11/8/23.
//

import SwiftUI

struct ContentView: View {
  let title: String
    var body: some View {
        VStack {
            
          Text(title)
          Image(systemName: "globe")
              .imageScale(.large)
              .foregroundStyle(.tint)
        }
        .padding()
    }
}

#Preview {
  ContentView(title: "")
}
