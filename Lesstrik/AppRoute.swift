//
//  AppRoute.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 20/03/25.
//

import SwiftUI

final class AppRoute:ObservableObject{
    enum Page{
        case home
        case dailyUsage
    }
    
    @Published var currentPage:Page = .home
}
