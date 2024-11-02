//
//  AppDelegate.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import SwiftUI

// MARK: - Main
@main
struct Networking_CleanArchitectureIOSApp: App {
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let appDIContainer = AppDIContainer()
    
    var body: some Scene {
        WindowGroup {
            let viewModel = appDIContainer
                .makeMoviesSceneDIContainer()
                .makeMoviesListViewModel()
            
            MovieListView(viewModel: viewModel)
        }
    }
}


// MARK: - AppDelegate
//class AppDelegate: NSObject, UIApplicationDelegate {
//    
//    let appDIContainer = AppDIContainer()
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        
//    }
//}
