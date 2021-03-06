//
//  SettingsView.swift
//  RSSBud
//
//  Created by Cay Zhang on 2020/8/10.
//

import SwiftUI

struct SettingsView: View {
    var storedBaseURL = RSSHub.BaseURL()
    @State var baseURLString: String
    @State var isAlertPresented = false
    
    @ObservedObject var rulesCenter = RSSHub.Radar.rulesCenter
    @AppStorage("lastRSSHubRadarRemoteRulesFetchDate", store: RSSBud.userDefaults) var _lastRemoteRulesFetchDate: Double?
    
    var lastRemoteRulesFetchDate: Date? {
        get { _lastRemoteRulesFetchDate.map(Date.init(timeIntervalSinceReferenceDate:)) }
        set { _lastRemoteRulesFetchDate = newValue?.timeIntervalSinceReferenceDate }
    }
    
    init() {
        _baseURLString = State(wrappedValue: storedBaseURL.string)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("RSSHub Radar")) {
                    HStack {
                        Text("RSSHub URL")
                        Spacer()
                        ValidatedTextField(
                            "RSSHub URL",
                            text: storedBaseURL.$string,
                            validation: storedBaseURL.validate(string:)
                        ).foregroundColor(.secondary)
                        .keyboardType(.URL)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                    }
                    
                    NavigationLink(destination: RSSHub.Radar.RulesEditor()) {
                        HStack {
                            Text("Rules")
                            Spacer()
                            if let date = lastRemoteRulesFetchDate {
                                Text("Updated \(date, style: .relative) ago")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Button(
                            rulesCenter.isFetchingRemoteRules ? "Updating Rules..." : "Update Rules Now"
                        ) {
                            rulesCenter.fetchRemoteRules()
                            rulesCenter.scheduleRemoteRulesFetchTask()
                        }.environment(\.isEnabled, !rulesCenter.isFetchingRemoteRules)
                        
                        Spacer()
                        
                        if rulesCenter.isFetchingRemoteRules {
                            ProgressView()
                        }
                    }
                }
                
                NavigationLink(
                    "Quick Subscriptions",
                    destination: IntegrationSettingsView().navigationTitle("Quick Subscriptions")
                )
            }.navigationTitle("Settings")
        }.listStyle(InsetGroupedListStyle())
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("Base URL is invalid."))
        }
    }
}

struct IntegrationSettingsView: View {
    var backgroundColor: Color? = nil
    
    @Integration var integrations
    
    func validate(urlString: String) -> Bool {
        URLComponents(string: urlString)?.host != nil
    }
    
    var body: some View {
        List(selection: $integrations) {
            ForEach(Integration.Key.allCases) { key in
                switch key {
                case .tinyTinyRSS:
                    VStack(alignment: .leading, spacing: 2.0) {
                        Text(key.rawValue)
                        ValidatedTextField("App URL", text: _integrations.$ttrssBaseURLString, validation: validate(urlString:))
                            .foregroundColor(.secondary)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                    }.tag(key)
                case .miniflux:
                    VStack(alignment: .leading, spacing: 2.0) {
                        Text(key.rawValue)
                        ValidatedTextField("App URL", text: _integrations.$minifluxBaseURLString, validation: validate(urlString:))
                            .foregroundColor(.secondary)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                    }.tag(key)
                case .freshRSS:
                    VStack(alignment: .leading, spacing: 2.0) {
                        Text(key.rawValue)
                        ValidatedTextField("App URL", text: _integrations.$freshRSSBaseURLString, validation: validate(urlString:))
                            .foregroundColor(.secondary)
                            .keyboardType(.URL)
                            .disableAutocorrection(true)
                    }.tag(key)
                default:
                    Text(key.rawValue).tag(key)
                }
            }.listRowBackground(backgroundColor)
        }.background(backgroundColor)
        .environment(\.editMode, .constant(.active))
    }
}

extension RSSHub.Radar {
    struct RulesEditor: View {
        @State var rules: String = RSSHub.Radar.rulesCenter.rules
        
        var body: some View {
            TextEditor(text: $rules)
                .font(.system(size: 12, weight: .light, design: .monospaced))
                .disableAutocorrection(true)
                .navigationTitle("Rules")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
            
            NavigationView {
                IntegrationSettingsView()
            }
            
            NavigationView {
                RSSHub.Radar.RulesEditor()
            }
        }
    }
}
