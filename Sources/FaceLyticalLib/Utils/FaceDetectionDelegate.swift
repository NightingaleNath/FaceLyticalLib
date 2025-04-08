//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import Foundation
import SwiftUI

/// Protocol for receiving face detection events
public protocol FaceDetectionDelegate {
    /// Called when a face is captured
    /// - Parameter image: The captured face image
    func faceDetectionView(didCaptureFace image: UIImage)
}

/// A class wrapper to hold the delegate (useful when working with SwiftUI views)
public class FaceDetectionDelegateHolder: ObservableObject {
    /// The delegate that will receive face detection events
    public var delegate: FaceDetectionDelegate
    
    /// Initialize a new delegate holder
    /// - Parameter delegate: The delegate that will receive events
    public init(delegate: FaceDetectionDelegate) {
        self.delegate = delegate
    }
}
