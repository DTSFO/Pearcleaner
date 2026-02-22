//
//  macOS12Compatibility.swift
//  Pearcleaner
//
//  Compatibility shims that let the project compile when targeting macOS 12.
//  On macOS 13+, native SwiftUI APIs are used.
//

import Foundation
import SwiftUI

@available(macOS, introduced: 10.15, obsoleted: 13.0)
public enum ScrollIndicatorVisibility {
    case automatic
    case visible
    case hidden
    case never
}

@available(macOS, introduced: 10.15, obsoleted: 13.0)
public enum ToolbarPlacement {
    case windowToolbar
}

@available(macOS, introduced: 10.15, obsoleted: 13.0)
public enum WindowResizability {
    case contentMinSize
}

@available(macOS, introduced: 10.15, obsoleted: 13.0)
extension View {
    @ViewBuilder
    func scrollIndicators(_ visibility: ScrollIndicatorVisibility, axes: Axis.Set = [.vertical]) -> some View {
        self
    }

    @ViewBuilder
    func toolbarBackground(_ visibility: Visibility, for bars: ToolbarPlacement) -> some View {
        self
    }
}

@available(macOS, introduced: 10.15, obsoleted: 13.0)
extension Scene {
    func windowResizability(_ resizability: WindowResizability) -> some Scene {
        self
    }
}

func currentRegionIdentifier() -> String {
    if #available(macOS 13.0, *) {
        return Locale.autoupdatingCurrent.region?.identifier ?? "US"
    } else {
        return Locale.autoupdatingCurrent.regionCode ?? "US"
    }
}
