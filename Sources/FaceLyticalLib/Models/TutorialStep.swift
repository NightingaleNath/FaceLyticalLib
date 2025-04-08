//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import Foundation
/**
 * Data structure for face capture tutorial steps
 */
public struct TutorialStep {
    /// Title of the tutorial step
    public let title: String
    
    /// Description text for the tutorial step
    public let description: String
    
    /// SF Symbol image name for the tutorial step
    public let imageName: String
    
    /// Initialize a new tutorial step
    /// - Parameters:
    ///   - title: Title of the step
    ///   - description: Description text
    ///   - imageName: SF Symbol image name
    public init(title: String, description: String, imageName: String) {
        self.title = title
        self.description = description
        self.imageName = imageName
    }
}
