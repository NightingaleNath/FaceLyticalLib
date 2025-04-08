//
//  File.swift
//
//
//  Created by Nathaniel Nkrumah on 08/04/2025.
//

import AVFoundation
import SwiftUI
import Vision

/// Manages camera operations, face detection, and photo capture
public class CameraManager: NSObject, ObservableObject {
    /// Current image captured by the camera
    @Published public var currentImage: UIImage?
    
    /// Boolean indicating if a face is detected in the frame
    @Published public var faceDetected: Bool = false
    
    /// Boolean indicating if image capture is in progress
    @Published public var isCapturing: Bool = false
    
    /// The AVCaptureSession used for camera input/output
    public var captureSession: AVCaptureSession?
    
    private var videoOutput = AVCaptureVideoDataOutput()
    private var photoOutput = AVCapturePhotoOutput()
    
    /// Callback for when an image is captured
    public var onImageCaptured: ((UIImage) -> Void)?
    
    // Define region of interest for face detection (initially full frame)
    private var regionOfInterest: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    // Store the actual visible frame for cropping captured photos
    private var visibleFrameRect: CGRect = .zero
    private var previewFrameRect: CGRect = .zero
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated)
    private var faceLandmarksRequest: VNDetectFaceLandmarksRequest?
    
    /// Initialize a new CameraManager
    public override init() {
        super.init()
        setupFaceDetection()
    }
    
    /// Set the region of interest for face detection
    /// - Parameters:
    ///   - viewFrame: The frame of the visible view area
    ///   - previewFrame: The frame of the entire preview area
    public func setRegionOfInterest(viewFrame: CGRect, previewFrame: CGRect) {
        // Store the actual frame rectangles for later use in cropping
        self.visibleFrameRect = viewFrame
        self.previewFrameRect = previewFrame
        
        // Calculate the normalized ROI (0-1 range) for Vision framework
        let normalizedROI = CGRect(
            x: (viewFrame.origin.x - previewFrame.origin.x) / previewFrame.width,
            y: 1.0 - ((viewFrame.origin.y - previewFrame.origin.y) + viewFrame.height) / previewFrame.height,
            width: viewFrame.width / previewFrame.width,
            height: viewFrame.height / previewFrame.height
        )
        
        self.regionOfInterest = normalizedROI
    }
    
    /// Check and request camera permissions
    public func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.setupCaptureSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.setupCaptureSession()
                        }
                    }
                }
            default:
                break
        }
    }
    
    /// Setup the camera capture session
    public func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        if captureSession.canSetSessionPreset(.high) {
            captureSession.sessionPreset = .high
        }
        
        // Setup the device
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Failed to create camera input: \(error.localizedDescription)")
            return
        }
        
        // Setup video data output
        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Setup photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // Set video orientation
        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }
        
        self.captureSession = captureSession
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
            
            // Important: Notify that the session is ready
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    /// Setup face detection
    private func setupFaceDetection() {
        // Setup face landmarks request
        faceLandmarksRequest = VNDetectFaceLandmarksRequest()
    }
    
    /// Capture a photo when face is detected
    public func capturePhoto() {
        // Set isCapturing to true when starting photo capture
        DispatchQueue.main.async {
            self.isCapturing = true
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /// Stop the capture session
    public func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    // Crop the captured image to match the visible frame in the UI
    private func cropImageToVisibleFrame(_ image: UIImage) -> UIImage? {
        guard !visibleFrameRect.isEmpty && !previewFrameRect.isEmpty else {
            return image // No crop data available, return original
        }
        
        guard let cgImage = image.cgImage else {
            return image
        }
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // Calculate the crop rectangle in normalized coordinates (0-1)
        let normalizedCropRect = CGRect(
            x: (visibleFrameRect.origin.x - previewFrameRect.origin.x) / previewFrameRect.width,
            y: (visibleFrameRect.origin.y - previewFrameRect.origin.y) / previewFrameRect.height,
            width: visibleFrameRect.width / previewFrameRect.width,
            height: visibleFrameRect.height / previewFrameRect.height
        )
        
        // Convert to pixel coordinates for cropping
        // Note: Y-coordinate needs adjusting because UIKit coordinates have origin at top-left
        let cropRect = CGRect(
            x: normalizedCropRect.origin.x * imageWidth,
            y: normalizedCropRect.origin.y * imageHeight,
            width: normalizedCropRect.width * imageWidth,
            height: normalizedCropRect.height * imageHeight
        )
        
        // Ensure crop rectangle is within image bounds
        let safeCropRect = CGRect(
            x: max(0, cropRect.origin.x),
            y: max(0, cropRect.origin.y),
            width: min(imageWidth - cropRect.origin.x, cropRect.width),
            height: min(imageHeight - cropRect.origin.y, cropRect.height)
        )
        
        // Crop the image
        if let croppedCGImage = cgImage.cropping(to: safeCropRect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Create a request handler
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )
        
        // Process the request
        do {
            // First detect face rectangles with ROI applied
            let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
                guard let self = self,
                      error == nil,
                      let faceObservations = request.results as? [VNFaceObservation],
                      !faceObservations.isEmpty else {
                    DispatchQueue.main.async {
                        self?.faceDetected = false
                    }
                    return
                }
                
                // Now perform landmarks detection on the same faces
                let landmarksRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
                    guard let self = self,
                          error == nil,
                          let observations = request.results as? [VNFaceObservation] else {
                        DispatchQueue.main.async {
                            self?.faceDetected = false
                        }
                        return
                    }
                    
                    // Check if any face has all the required landmarks
                    let hasCompleteface = observations.contains { face in
                        guard let landmarks = face.landmarks else { return false }
                        
                        // Check for all required facial features
                        let hasLeftEye = landmarks.leftEye != nil && !landmarks.leftEye!.normalizedPoints.isEmpty
                        let hasRightEye = landmarks.rightEye != nil && !landmarks.rightEye!.normalizedPoints.isEmpty
                        let hasNose = landmarks.nose != nil && !landmarks.nose!.normalizedPoints.isEmpty
                        let hasMouth = landmarks.outerLips != nil && !landmarks.outerLips!.normalizedPoints.isEmpty
                        
                        return hasLeftEye && hasRightEye && hasNose && hasMouth
                    }
                    
                    DispatchQueue.main.async {
                        self.faceDetected = hasCompleteface
                    }
                }
                
                // Set region of interest on landmarks request to only detect in the visible frame
                landmarksRequest.regionOfInterest = self.regionOfInterest
                
                // Perform the landmarks detection
                try? imageRequestHandler.perform([landmarksRequest])
            }
            
            // Set region of interest on face detection request to only detect in the visible frame
            faceDetectionRequest.regionOfInterest = self.regionOfInterest
            
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
            print("Failed to perform face detection: \(error)")
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let capturedImage = UIImage(data: imageData) else {
            // Reset capturing state if there was an error
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Crop the captured image to match only what was visible in the UI frame
            let croppedImage = self.cropImageToVisibleFrame(capturedImage)
            
            // Update UI and callback with the cropped image
            self.currentImage = croppedImage
            
            // Reset capturing state after processing is complete
            self.isCapturing = false
            
            // Notify with the captured image
            self.onImageCaptured?(croppedImage ?? capturedImage)
        }
    }
}
