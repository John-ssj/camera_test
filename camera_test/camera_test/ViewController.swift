//
//  ViewController.swift
//  camera_test
//
//  Created by 史圣久 on 2020/8/6.
//  Copyright © 2020 史圣久. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var subview: UIView!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var photoOutput: AVCapturePhotoOutput!
    
//    var previewView: UIView!
    var captureImageView =  UIImageView()
    var takePicture = UIButton()
    var nextPicture = UIButton()
    
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setUpCamera()
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.black
        
        view.addSubview(captureImageView)
        captureImageView.translatesAutoresizingMaskIntoConstraints = false
        captureImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        captureImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        captureImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        captureImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        captureImageView.contentMode = .scaleAspectFill
        captureImageView.clipsToBounds = true
        
        view.addSubview(takePicture)
        takePicture.backgroundColor = .white
        takePicture.layer.cornerRadius = 38
        takePicture.layer.masksToBounds = true
        takePicture.translatesAutoresizingMaskIntoConstraints = false
        takePicture.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        takePicture.widthAnchor.constraint(equalToConstant: 75).isActive = true
        takePicture.topAnchor.constraint(equalTo: captureImageView.bottomAnchor, constant: 5).isActive = true
        takePicture.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        takePicture.setBackgroundImage(UIImage(systemName: "largecircle.fill.circle")?.withRenderingMode(.alwaysOriginal), for: .normal)
        takePicture.addTarget(self, action: #selector(TakePhoto), for: .touchDown)
        
        view.addSubview(nextPicture)
        nextPicture.translatesAutoresizingMaskIntoConstraints = false
        nextPicture.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        nextPicture.widthAnchor.constraint(equalToConstant: 60).isActive = true
        nextPicture.topAnchor.constraint(equalTo: captureImageView.bottomAnchor, constant: 20).isActive = true
        nextPicture.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        nextPicture.setTitle("Next", for: .normal)
        nextPicture.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        nextPicture.addTarget(self, action: #selector(NextPhoto), for: .touchDown)
        nextPicture.alpha = 0
    }
    
    
    func setUpCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        guard let BackVideoCaptureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { print("No Back Camera"); return }
        
        
        let videoInput: AVCaptureDeviceInput
        do { videoInput = try AVCaptureDeviceInput(device: BackVideoCaptureDevice) } catch {
            print("No Device Input")
            return
        }
        if(captureSession.canAddInput(videoInput)){
            captureSession.addInput(videoInput)
        } else {
            print("Could Not Add Input To Sesstion")
            return
        }
        
        
        photoOutput = AVCapturePhotoOutput()
        if (captureSession.canAddOutput(photoOutput)) {
            captureSession.addOutput(photoOutput)
        } else {
            print("Could Not Add Output To Sesstion")
            return
        }

        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = captureImageView.layer.bounds
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        print("running")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpCamera()
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
            print("running")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @objc func NextPhoto() {
        if captureSession.isRunning { return }
        
        captureSession.startRunning()
        self.i += 1
        
        nextPicture.alpha = 0
    }
    
    //拍照按钮
    @objc func TakePhoto() {
        if !captureSession.isRunning { return }
        
        self.previewLayer.opacity = 0
        UIView.animate(withDuration: 0.25) {
            self.previewLayer.opacity = 1
        }
        
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        print("take Picture")
        
        captureSession.stopRunning()
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
        else {
            print("error")
            captureSession.startRunning()
            return }

        let image = UIImage(data: imageData)
        captureImageView.image = image
        print("set image")
        if let imageData = image!.jpegData(compressionQuality: 1) as NSData? {
            let fullPath = NSHomeDirectory().appending("/Documents/").appending("image_\(self.i)")
            imageData.write(toFile: fullPath, atomically: true)
            print("fullPath=\(fullPath)")
        }
        
        nextPicture.alpha = 1
        print("show next")
    }

}

