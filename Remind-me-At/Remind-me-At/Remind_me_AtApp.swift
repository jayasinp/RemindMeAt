//
//  Remind_me_AtApp.swift
//  Remind-me-At
//
//  Created by Pravin Jayasinghe on 27/8/2024.
//

import SwiftUI

@main
struct Remind_me_AtApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
