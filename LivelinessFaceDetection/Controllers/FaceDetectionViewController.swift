//
//  FaceDetectionViewController.swift
//  LivelinessFaceDetection
//
//  Created by Izaan Saleem on 04/12/2023.
//

import UIKit
import MLKitVision
import MLKitFaceDetection
import AVFoundation
import CoreMedia

class FaceDetectionViewController: BaseViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak private var videoPreview: UIView!
    
    //MARK: - Properties
    private var videoCapture: CameraPreview?
    
    var squareLayer = CALayer()
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpCamera()
        
        self.videoPreview.layer.borderWidth = 4
        self.videoPreview.layer.cornerRadius = 10
        self.videoPreview.layer.borderColor = UIColor.green.cgColor
        self.videoPreview.clipsToBounds = true
    }
    
    private func setUpCamera() {
        SharedFaceDetection.shared.setupFaceDetection()
        
        videoCapture = CameraPreview()
        videoCapture?.delegate = self
        videoCapture?.fps = 15
        videoCapture?.setUp(sessionPreset: .vga640x480) { success in
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture?.previewLayer {
                    self.videoCapture?.previewLayer?.frame = self.videoPreview.bounds
                    self.videoPreview.layer.addSublayer(previewLayer)
                }
                // start video preview when setup is done
                self.videoCapture?.start()
            }
        }
    }
    
    private func drawSquareOnFace(faces: [Face], in originalImage: UIImage) {
        for face in faces {
            let boundingBox = face.frame
            let imageSize = originalImage.size
            
            let faceRectConverted = CGRect(
                x: imageSize.width - boundingBox.origin.x - boundingBox.size.width - 46,
                y: boundingBox.origin.y + 50,
                width: boundingBox.size.width,
                height: boundingBox.size.height + 20
            )
            
            var labelText = ""

            if face.smilingProbability > 0.3 {
                labelText = "Smiling 🙂"
            } else {
                labelText = "👀"
            }
            
            self.label.numberOfLines = 0
            self.label.textColor = .green
            self.label.text = labelText
            self.label.font = UIFont.systemFont(ofSize: 20)
            self.label.sizeToFit()
            self.label.center = CGPoint(x: faceRectConverted.midX, y: faceRectConverted.maxY + self.label.frame.height / 2 + 5)
            self.label.frame.size.width = face.frame.width
            
            // Add the label to your image view or any other container
            self.view.addSubview(self.label)
            
            self.squareLayer.bounds = faceRectConverted
            self.squareLayer.position = CGPoint(x: faceRectConverted.midX, y: faceRectConverted.midY)
            self.squareLayer.borderWidth = 2.0
            self.squareLayer.borderColor = UIColor.green.cgColor
            
            // Add the square layer to your image view or any other container
            self.view.layer.addSublayer(self.squareLayer)
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Video Delegate
extension FaceDetectionViewController: CameraPreviewDelegate {
    func videoCapture(_ capture: CameraPreview, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if let pixelBuffer = pixelBuffer {
            SharedFaceDetection.shared.predictUsingVision(pixelBuffer: pixelBuffer) { face, pickedImage in
                self.drawSquareOnFace(faces: face, in: pickedImage)
            }
        }
    }
}
