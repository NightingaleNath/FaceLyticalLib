//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import Foundation
/// Provides static strings for user instructions in the face detection process
public struct Instructions {
    /// When no face is detected in the frame
    public static let positionFace = "Position your face in the frame"
    
    /// When a face is detected and ready to capture
    public static let faceDetected = "Face detected, tap button to capture"
    
    /// When capture is in progress
    public static let capturing = "Capturing face, please hold still"
}
