//
//  GlasscastWidgetBundle.swift
//  GlasscastWidget
//
//  Created by Mayur Bakraniya on 19/01/26.
//

import WidgetKit
import SwiftUI

@main
struct GlasscastWidgetBundle: WidgetBundle {
    var body: some Widget {
        GlasscastWidget()
        GlasscastWidgetControl()
        GlasscastWidgetLiveActivity()
    }
}
