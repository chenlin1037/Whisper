//
//  AboutView.swift
//  Whisper
//
//  Created by luckly on 2026/2/23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.appTheme)

                    Text(AppConfig.appDisplayName)
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    Text("v\(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                Text(AppConfig.copyright)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("关于")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
