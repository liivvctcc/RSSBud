//
//  FeedView.swift
//  RSSBud
//
//  Created by Cay Zhang on 2020/8/17.
//

import SwiftUI

struct FeedView: View {
    
    var feed: RSSHub.Radar.DetectedFeed
    var contentViewModel: ContentView.ViewModel
    var openURL: (URLComponents) -> Void = { _ in }
    @Integration var integrations
    @RSSHub.BaseURL var baseURL
    
    func rsshubURL() -> URLComponents {
        baseURL
            .appending(path: feed.path)
            .appending(queryItems: contentViewModel.queryItems)
            .omittingEmptyQueryItems()
    }
    
    func integrationURL(for integrationKey: Integration.Key) -> URLComponents? {
        _integrations.url(forAdding: rsshubURL(), to: integrationKey)
    }
    
    var body: some View {
        VStack(spacing: 10.0) {
            Text(feed.title)
                .fontWeight(.semibold)
                .padding(.horizontal, 15)
            
//            Text(rsshubURL().string ?? "URL Conversion Failed")
//                .padding(.horizontal, 15)
            
            HStack(spacing: 8) {
                WideButton("Copy", systemImage: "doc.on.doc.fill") {
                    rsshubURL().url.map { UIPasteboard.general.url = $0 }
                }
                
                integrationButton
            }.padding(.horizontal, 8)
        }.padding(.top, 15)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    @ViewBuilder var integrationButton: some View {
        if integrations.count == 1, let url = integrationURL(for: integrations[0]) {
            WideButton(Label(integrations[0].rawValue, systemImage: "arrowshape.turn.up.right.fill")) {
                openURL(url)
            }
        } else {
            Menu {
                ForEach(integrations) { key in
                    if let url = integrationURL(for: key) {
                        Button(key.rawValue) {
                            openURL(url)
                        }
                    }
                }
            } label: {
                Label("Subscribe", systemImage: "ellipsis")
            }.roundedRectangleBackground()
        }
    }
    
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView_Previews.previews
    }
}
