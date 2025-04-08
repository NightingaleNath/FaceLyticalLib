//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import Foundation
import SwiftUI
import AVFoundation

/// The main view for face detection and capture
public struct FaceDetectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var cameraManager = CameraManager()
    
    // Track the frame of our camera view for ROI calculation
    @State private var cameraFrameRect: CGRect = .zero
    
    // State to show/hide walkthrough
    @State private var showWalkthrough = false
    
    /// Callback for when a face is captured
    private var onCapture: (UIImage) -> Void
    
    /// Initialize a new FaceDetectionView
    /// - Parameter onCapture: A callback that is called when a face is captured
    public init(onCapture: @escaping (UIImage) -> Void) {
        self.onCapture = onCapture
    }
    
    public var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.07, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            VStack {
                // Camera preview
                ZStack {
                    // Camera preview layer
                    CameraPreviewRepresentable(session: cameraManager.captureSession)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    // Track the camera preview frame
                        .background(GeometryReader { geo -> Color in
                            // Capture the camera frame rect
                            DispatchQueue.main.async {
                                let frame = geo.frame(in: .global)
                                self.cameraFrameRect = frame
                                
                                // Calculate the visible frame (accounting for padding)
                                let visibleFrame = CGRect(
                                    x: frame.origin.x + 20,
                                    y: frame.origin.y + 20,
                                    width: frame.width - 40,
                                    height: frame.height - 40
                                )
                                
                                // Set the region of interest in the camera manager
                                self.cameraManager.setRegionOfInterest(
                                    viewFrame: visibleFrame,
                                    previewFrame: frame
                                )
                            }
                            return Color.clear
                        })
                    
                    // Corner guides
                    GeometryReader { geo in
                        let frameWidth = geo.size.width - 40
                        CornerGuidesView(
                            color: cameraManager.faceDetected ? .green : .white,
                            frameSize: frameWidth
                        )
                        .position(x: geo.size.width/2, y: geo.size.height/2)
                    }
                }
                
                // Instructions text
                Text(
                    cameraManager.isCapturing ? Instructions.capturing :
                        cameraManager.faceDetected ? Instructions.faceDetected :
                        Instructions.positionFace)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 20)
                
                Spacer().frame(height: 30)
                
                // Control buttons
                VStack {
                    // Bottom controls with responsive spacing
                    HStack {
                        Spacer()
                        
                        // Cancel button
                        Button {
                            cameraManager.stopSession()
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .frame(width: 35, height: 35)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Capture button
                        Button {
                            if cameraManager.faceDetected {
                                cameraManager.capturePhoto()
                            }
                        } label: {
                            Image(systemName: "lock.fill")
                                .foregroundColor(cameraManager.faceDetected ? .white : .gray)
                                .font(.system(size: 20))
                                .frame(width: 70, height: 70)
                                .background(cameraManager.faceDetected ? Color.green : Color(white: 0.3, opacity: 0.5))
                                .clipShape(Circle())
                        }
                        .disabled(!cameraManager.faceDetected)
                        
                        Spacer()
                        
                        // Help button
                        Button {
                            showWalkthrough = true
                        } label: {
                            Image(systemName: "questionmark")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .frame(width: 35, height: 35)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            
            if showWalkthrough {
                FaceWalkthroughView(isPresented: $showWalkthrough)
            }
        }
        .onAppear {
            cameraManager.onImageCaptured = { image in
                onCapture(image)
                dismiss()
            }
            cameraManager.checkPermissions()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

/// A UIViewRepresentable for displaying the camera preview
public struct CameraPreviewRepresentable: UIViewRepresentable {
    /// The capture session to display
    public var session: AVCaptureSession?
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        // Check if previewLayer exists
        if context.coordinator.previewLayer == nil {
            // Create it if it doesn't exist
            if let session = session {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = uiView.bounds
                uiView.layer.addSublayer(previewLayer)
                context.coordinator.previewLayer = previewLayer
            }
        }
        
        // Always update the frame to match current bounds
        context.coordinator.previewLayer?.frame = uiView.bounds
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
