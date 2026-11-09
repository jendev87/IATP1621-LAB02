//
//  ScaleButtonStyle.swift
//  DashboardDemo
//
//  Reusable tactile spring button style for fluid micro-interactions.
//

import SwiftUI

/// Tactile button style applying a subtle spring compression on press.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
