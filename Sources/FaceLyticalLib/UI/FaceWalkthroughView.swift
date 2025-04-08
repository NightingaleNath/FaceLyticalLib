//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import Foundation
import SwiftUI

/// A view that displays a walkthrough for using the face detection
public struct FaceWalkthroughView: View {
    /// Binding to control the presentation state
    @Binding var isPresented: Bool
    
    /// The current step in the walkthrough
    @State private var currentStep = 0
    
    // Tutorial content for face capture
    private let tutorials = [
        TutorialStep(
            title: "Position Your Face Properly",
            description: "Center your face within the frame and make sure your entire face is visible. Keep a neutral expression for best results.",
            imageName: "face.dashed"
        ),
        TutorialStep(
            title: "Good Lighting is Essential",
            description: "Ensure your face is well lit with even lighting. Avoid harsh shadows or bright light directly behind you that can cause silhouetting.",
            imageName: "sun.max.fill"
        ),
        TutorialStep(
            title: "Remove Obstructions",
            description: "Remove sunglasses, hats, or other items that might obscure facial features. Ensure there are no objects partially blocking your face.",
            imageName: "eye.slash.fill"
        )
    ]
    
    // Add a minimum drag distance to trigger a swipe
    private let dragThreshold: CGFloat = 50
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack {
                // Face illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.29, green: 0.71, blue: 0.93), lineWidth: 2)
                        )
                        .frame(width: 250, height: 200)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 1)
                            .padding(3)
                            .frame(width: 275, height: 225)
                        
                        Image(systemName: tutorials[currentStep].imageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                    }
                }
                .padding(.top, 40)
                
                // Close button
                Button {
                    isPresented = false
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                    }
                }
                .padding(.top, 5)
                
                // Added spacer between close button and title
                Spacer().frame(height: 40)
                
                // Tutorial title
                Text(tutorials[currentStep].title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Increased space between title and description
                Spacer().frame(height: 15)
                
                // Tutorial description
                Text(tutorials[currentStep].description)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                // Navigation dots
                HStack {
                    ForEach(0..<tutorials.count, id: \.self) { index in
                        Circle()
                            .fill(currentStep == index ?
                                  Color(red: 0.29, green: 0.71, blue: 0.93) : Color.gray)
                            .frame(width: currentStep == index ? 10 : 6, height: currentStep == index ? 10 : 6)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                            .onTapGesture {
                                currentStep = index
                            }
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.bottom, 70)
                
                // Navigation buttons
                HStack {
                    Button {
                        if currentStep > 0 {
                            currentStep -= 1
                        } else {
                            isPresented = false
                        }
                    } label: {
                        Text(currentStep == 0 ? "SKIP" : "BACK")
                            .font(.system(size: 14))
                            .foregroundColor(currentStep > 0 ?
                                             Color(red: 0.29, green: 0.71, blue: 0.93) : Color.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                    
                    Spacer()
                    
                    Button {
                        if currentStep < tutorials.count - 1 {
                            currentStep += 1
                        } else {
                            isPresented = false
                        }
                    } label: {
                        Text(currentStep < tutorials.count - 1 ? "NEXT" : "DONE")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.29, green: 0.71, blue: 0.93))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            // Add swipe gesture to the entire content
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        let horizontalTranslation = gesture.translation.width
                        
                        // If the drag distance is greater than threshold
                        if abs(horizontalTranslation) > dragThreshold {
                            // Right to left swipe (negative translation) = next
                            if horizontalTranslation < 0 {
                                if currentStep < tutorials.count - 1 {
                                    withAnimation {
                                        currentStep += 1
                                    }
                                } else if currentStep == tutorials.count - 1 {
                                    isPresented = false
                                }
                            }
                            // Left to right swipe (positive translation) = previous
                            else {
                                if currentStep > 0 {
                                    withAnimation {
                                        currentStep -= 1
                                    }
                                } else if currentStep == 0 {
                                    isPresented = false
                                }
                            }
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
