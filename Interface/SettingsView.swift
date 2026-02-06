//
//  SettingsView.swift
//  Interface
//
//  Created by Harsh Sharma on 05/02/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue

    private var appTheme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: appThemeRaw) ?? .system },
            set: { appThemeRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: appTheme) {
                    ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
