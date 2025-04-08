//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import SwiftUI

/// A view that displays corner guides to help position a face in the camera frame
public struct CornerGuidesView: View {
    /// The color of the corner guides
    public var color: Color
    
    /// The size of the frame
    public var frameSize: CGFloat
    
    /// Initialize a new CornerGuidesView
    /// - Parameters:
    ///   - color: The color of the corner guides (default: white)
    ///   - frameSize: The size of the frame (default: screen width minus 40)
    public init(color: Color = .white, frameSize: CGFloat? = nil) {
        self.color = color
        self.frameSize = frameSize ?? UIScreen.main.bounds.width - 40
    }
    
    public var body: some View {
        ZStack {
            // Top-left corner
            CornerView(color: color)
                .position(x: 20, y: 20)
            
            // Top-right corner
            CornerView(color: color)
                .rotationEffect(.degrees(90))
                .position(x: frameSize - 20, y: 20)
            
            // Bottom-left corner
            CornerView(color: color)
                .rotationEffect(.degrees(-90))
                .position(x: 20, y: frameSize - 20)
            
            // Bottom-right corner
            CornerView(color: color)
                .rotationEffect(.degrees(180))
                .position(x: frameSize - 20, y: frameSize - 20)
        }
        .frame(width: frameSize, height: frameSize)
    }
}

/// A view that displays a single corner of the guides
public struct CornerView: View {
    /// The color of the corner
    public var color: Color
    
    public var body: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(color)
                .frame(width: 30, height: 5)
                .offset(x: 15, y: 0)
            
            // Vertical line
            Rectangle()
                .fill(color)
                .frame(width: 5, height: 30)
                .offset(x: 0, y: 15)
        }
        .frame(width: 40, height: 40)
    }
}
