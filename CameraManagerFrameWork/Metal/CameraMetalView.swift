//
//  CameraMetalView.swift
//  HypyG
//
//  Created by 온석태 on 11/24/23.
//

import CoreMedia
import Foundation
import MetalKit
import UIKit
import CoreVideo
import SwiftUI
import AVFoundation

/// ``CameraMetalView``
///
/// this view for render camera frame
///
/// if you set ``CameraOptions/cameraRenderingMode`` for ``CameraRenderingMode/normal``
public class CameraMetalView: MTKView {
    public var sampleBuffer: CMSampleBuffer?
    public var pixelBuffer: CVPixelBuffer?
    public var position: AVCaptureDevice.Position?
    public var time: CMTime?
    
    private var context: CIContext?
    var metalDevice: MTLDevice!
    var metalCommandQueue: MTLCommandQueue!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var textureCache: CVMetalTextureCache!
    var samplerState: MTLSamplerState?
    var textureLoader:MTKTextureLoader?
    public var isCameraOn: Bool = true
    public var isMirrorMode: Bool = false
    var isRecording: Bool = false
    var isMirrorModeBuffer: MTLBuffer?
    var currentOrientation: Int = 1
    var pipelineDescriptor:MTLRenderPipelineDescriptor?
    var cameraManagerFrameWorkDelegate: CameraManagerFrameWorkDelegate?
    private var _showThumbnail: Bool = false
    var showThumbnail: Bool {
        get {
            return _showThumbnail
        }
        set {
            if newValue {
                self.enableSetNeedsDisplay = true
            } else {
                self.enableSetNeedsDisplay = false
            }
            _showThumbnail = newValue
            
            if !enableSetNeedsDisplay {
                framebufferOnly = false
                enableSetNeedsDisplay = false
                self.preferredFramesPerSecond = 60
                isPaused = false
                self.setNeedsDisplay() // 뷰를 다시 그리도록 요청
            }
        }
    }
    
    var thumbnail:MTLTexture?
    var thumbnailPixelBuffer:CVPixelBuffer?
    private var borderView: UIView?
    init(cameraManagerFrameWorkDelegate: CameraManagerFrameWorkDelegate) {
        super.init(frame: .zero, device: MTLCreateSystemDefaultDevice())
        self.awakeFromNib()
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            self.metalDevice = metalDevice
            self.textureLoader = MTKTextureLoader(device: metalDevice)
            self.metalCommandQueue = metalDevice.makeCommandQueue()
            self.createTextureCache()
            self.setupSampler()
            self.setupVertices()
            self.setPipelineDescriptor()
           
        }
        self.cameraManagerFrameWorkDelegate = cameraManagerFrameWorkDelegate
        
        
        
        self.context = CIContext(mtlDevice: device!)
    }
    
    deinit {
        print("MetalView deinit")
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func unreference() {
        cameraManagerFrameWorkDelegate = nil
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        framebufferOnly = false
        enableSetNeedsDisplay = false
        self.preferredFramesPerSecond = 60
        isPaused = false
    }

    @objc private func updateDisplay() {
        // setNeedsDisplay를 호출하여 화면을 갱신합니다.
        self.setNeedsDisplay()
    }
    
    public func updateTime(frameRate: Double) {
        if Thread.isMainThread {
            if time == nil {
                time = CMTime(value: 0, timescale: CMTimeScale(frameRate)) // 시작 시간, 타임스케일 30fps
            }

            // 시간 증가 (1프레임씩 증가)
            let oneFrameTime = CMTime(value: 1, timescale: CMTimeScale(frameRate)) // 30fps에서 1프레임을 나타냄
            time = CMTimeAdd(time!, oneFrameTime)
            self.setNeedsDisplay()
        } else {
            DispatchQueue.main.async {
                self.updateTime(frameRate: frameRate)
            }
        }
    }
    
    public func setPipelineDescriptor() {
        do {
            pipelineDescriptor = MTLRenderPipelineDescriptor()
            
            // 현재 클래스의 번들을 가져옵니다.
            let frameworkBundle = Bundle(for: type(of: self))
            
            // 메탈 기본 라이브러리를 생성합니다.
            try metalDevice.makeDefaultLibrary(bundle: frameworkBundle)
            
            // 메탈 라이브러리 경로를 찾습니다.
            if let libraryPath = frameworkBundle.path(forResource: "CameraMetalShader", ofType: "metallib") {
                // 해당 경로에서 라이브러리를 생성합니다.
                let library = try metalDevice.makeLibrary(filepath: libraryPath)
                
                // 정점 및 프래그먼트 셰이더 함수 가져오기
                if let vertexFunction = library.makeFunction(name: "vertexShader"),
                   let fragmentFunction = library.makeFunction(name: "fragmentShader") {
                    // 파이프라인 상태 설정
                    pipelineDescriptor?.vertexFunction = vertexFunction
                    pipelineDescriptor?.fragmentFunction = fragmentFunction
                    pipelineDescriptor?.colorAttachments[0].pixelFormat = .bgra8Unorm
                } else {
                    print("셰이더 함수를 찾을 수 없음")
                    return
                }
            } else {
                print("메탈 라이브러리 경로를 찾을 수 없음")
                return
            }
        } catch {
            
        }
    }
    
    // 사각형 보더라인을 보여주는 메서드
    public func showFocusBorder(at point: CGPoint) {
           // 이전 borderView가 존재하면 제거
           borderView?.removeFromSuperview()

           // 새로운 borderView 생성
           let borderSize: CGFloat = 100 // 사각형의 크기 (원하는 크기로 조절)
        
           borderView = UIView(frame: CGRect(
               x: (self.bounds.width * point.x) - borderSize / 2,
               y: (self.bounds.height * point.y) - borderSize / 2,
               width: borderSize,
               height: borderSize
           ))
           
           // 보더라인 스타일 설정
           borderView?.layer.borderColor = UIColor.yellow.cgColor // 원하는 색상으로 설정
           borderView?.layer.borderWidth = 1.0 // 보더 두께 설정
           borderView?.layer.cornerRadius = 5 // 모서리 둥글게 설정 (선택사항)
           borderView?.alpha = 1.0 // 시작할 때 완전히 보이도록 설정

           // singleCameraView에 추가
           if let borderView = borderView {
               self.addSubview(borderView)

               // 애니메이션 추가
               UIView.animate(withDuration: 0.3, animations: {
                   borderView.alpha = 1.0
               }) { _ in
                   // 애니메이션이 끝난 후 사라지게
                   UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
                       borderView.alpha = 0.0
                   }) { _ in
                       // 최종적으로 borderView 제거
                       borderView.removeFromSuperview()
                   }
               }
           }
       }
    
    public func update(sampleBuffer: CMSampleBuffer? ,pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position) {
        self.position = position
        self.time = time
        self.pixelBuffer = pixelBuffer
        self.sampleBuffer = sampleBuffer
    }
    
    func setupVertices() {
        let vertices: [Vertex] = [
            Vertex(position: [-1.0, -1.0, 0.0, 1.0], texCoord: [1.0, 1.0]),
            Vertex(position: [ 1.0, -1.0, 0.0, 1.0], texCoord: [0.0, 1.0]),
            Vertex(position: [-1.0,  1.0, 0.0, 1.0], texCoord: [1.0, 0.0]),
            Vertex(position: [ 1.0, -1.0, 0.0, 1.0], texCoord: [0.0, 1.0]),
            Vertex(position: [-1.0,  1.0, 0.0, 1.0], texCoord: [1.0, 0.0]),
            Vertex(position: [ 1.0,  1.0, 0.0, 1.0], texCoord: [0.0, 0.0])
        ]
        vertexBuffer = metalDevice.makeBuffer(bytes: vertices,
                                              length: vertices.count * MemoryLayout<Vertex>.stride,
                                              options: .storageModeShared)
    }
    
    func setupSampler() {
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        samplerState = metalDevice.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    private func createTextureCache() {
        guard let device = device else { return }
        var newTextureCache: CVMetalTextureCache?
        let result = CVMetalTextureCacheCreate(nil, nil, device, nil, &newTextureCache)
        if result == kCVReturnSuccess {
            textureCache = newTextureCache
        } else {
            print("Error: Could not create a texture cache")
        }
    }
    
    func setThumbnail(cgImage: CGImage) {
        do {
            let options: [MTKTextureLoader.Option: Any] = [
                .origin: MTKTextureLoader.Origin.topLeft, // 기본 설정으로 변경
                .SRGB: false
            ]

            if let texture = try textureLoader?.newTexture(cgImage: cgImage, options: options) {
                self.thumbnail = texture
                self.thumbnailPixelBuffer = self.toPixelBuffer(image: CIImage(cgImage: cgImage))
            }
        } catch {
            
        }
    }
    
    func pixelBuffer(from texture: MTLTexture) -> CVPixelBuffer? {
        let width = texture.width
        let height = texture.height
        let pixelFormat = kCVPixelFormatType_32BGRA // 일반적으로 .bgra8Unorm 사용

        var pixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferMetalCompatibilityKey: true,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height,
            kCVPixelBufferPixelFormatTypeKey: pixelFormat
        ]
        
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attributes as CFDictionary, &pixelBuffer)

        guard let buffer = pixelBuffer,
              let cache = textureCache else { return nil }

        // CVMetalTextureCache를 사용하여 pixelBuffer로부터 Metal Texture 생성
        var cvMetalTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, cache, buffer, nil, .bgra8Unorm, width, height, 0, &cvMetalTexture)
        
        guard let pixelBufferTexture = CVMetalTextureGetTexture(cvMetalTexture!) else { return nil }

        // Command Buffer와 Blit Encoder 생성
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {
            return nil
        }

        // MTLTexture의 내용을 pixelBufferTexture로 복사
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                         sourceSize: MTLSize(width: width, height: height, depth: 1),
                         to: pixelBufferTexture, destinationSlice: 0, destinationLevel: 0,
                         destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))

        blitEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return buffer
    }

    
    func texture(from pixelBuffer: CVPixelBuffer) -> MTLTexture? {

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        var imageTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                textureCache!,
                                                                pixelBuffer,
                                                                nil,
                                                                .bgra8Unorm,
                                                                width,
                                                                height,
                                                                0,
                                                                &imageTexture)


        guard status == kCVReturnSuccess, let unwrappedImageTexture = imageTexture else { return nil }

        return CVMetalTextureGetTexture(unwrappedImageTexture)
    }

}

extension CameraMetalView: MTKViewDelegate {
    
    public func mtkView(_: MTKView, drawableSizeWillChange _: CGSize) {}
    
    public func draw(in view: MTKView) {

        guard let drawable = view.currentDrawable,
              let commandBuffer = metalCommandQueue.makeCommandBuffer(),
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let pixelBuffer = self.pixelBuffer,
              let position = self.position else {
            return
        }
        
        var texture:MTLTexture?
        
        if self.showThumbnail {
            texture = self.thumbnail
        } else {
            texture = self.texture(from: pixelBuffer)
        }
        
        guard let texture = texture else {
            self.completedAfterGpuPixel(imageBuffer: pixelBuffer)
            self.cameraManagerFrameWorkDelegate?.videoCaptureOutput?(pixelBuffer: pixelBuffer, time: time!, position: position, isThumbnail: self.showThumbnail)
            return
        }

        var mirrorModeValue: Int32 = self.showThumbnail ? 1 : isMirrorMode ? 0 : 1
        isMirrorModeBuffer = metalDevice.makeBuffer(bytes: &mirrorModeValue, length: MemoryLayout<Int32>.size, options: [])

        do {
            guard let pipelineStateDescriptor = pipelineDescriptor else {
                return
            }
            
              let pipelineState = try metalDevice.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
              guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
              
              renderEncoder.setRenderPipelineState(pipelineState)
              renderEncoder.setFragmentTexture(texture, index: 0)
              guard let samplerState = samplerState else { return }
              renderEncoder.setFragmentSamplerState(samplerState, index: 0)

              // 정점 버퍼를 설정
              if let vertexBuffer = vertexBuffer {
                  renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                  renderEncoder.setVertexBuffer(isMirrorModeBuffer , offset: 0, index: 2)
              }

              // 여기에서 drawPrimitives 메소드를 사용하여 그리기 수행
              renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6)
              
              renderEncoder.endEncoding()
              commandBuffer.present(drawable)
              commandBuffer.commit()
            
            let time = self.time
            // CGFloat.pi / 2 왼쪽 3
            // -CGFloat.pi / 2 오른쪽 4
            // -CGFloat.pi 위쪽 2
            // CGFloat.pi 정방향 1
            var ratationAngle = CGFloat.pi // 정방향
            
            var image = self.pixelBuffer
            
            if self.currentOrientation == 2 {
                ratationAngle = -CGFloat.pi
                image = processSampleBuffer(pixelBuffer, rotationAngle: ratationAngle)
            } else if self.currentOrientation == 3 {
                ratationAngle = CGFloat.pi / 2
                image = processSampleBuffer(pixelBuffer, rotationAngle: ratationAngle)
            } else if self.currentOrientation == 4 {
                ratationAngle = -CGFloat.pi / 2
                image = processSampleBuffer(pixelBuffer, rotationAngle: ratationAngle)
            }
        
            if self.showThumbnail {
                if let thumbnailPixelBuffer = self.thumbnailPixelBuffer
                {
                    cameraManagerFrameWorkDelegate?.videoCaptureOutput?(pixelBuffer: thumbnailPixelBuffer, time: time!, position: position, isThumbnail: self.showThumbnail)
                    
                    if let thumbnailSampleBuffer = self.sampleBuffer(from: thumbnailPixelBuffer, presentationTime: time!) {
                        cameraManagerFrameWorkDelegate?.videoCaptureOutput?(sampleBuffer: thumbnailSampleBuffer, position: position, isThumbnail: self.showThumbnail)
                    }
                }
            } else {
                cameraManagerFrameWorkDelegate?.videoCaptureOutput?(pixelBuffer: image!, time: time!, position: position, isThumbnail: self.showThumbnail)
                
                if let sampleBuffer = sampleBuffer {
                    cameraManagerFrameWorkDelegate?.videoCaptureOutput?(sampleBuffer: sampleBuffer, position: position, isThumbnail: self.showThumbnail)
                }
            }

          } catch let error {
              print("Failed to create pipeline state, error: \(error)")
          }
    }
    
    func processSampleBuffer(_ pixelBuffer: CVPixelBuffer, rotationAngle: CGFloat) -> CVPixelBuffer? {
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)

        // 회전 적용
        let transform = CGAffineTransform(rotationAngle: rotationAngle)
        var transformedCIImage = ciImage.transformed(by: transform)

        // 음수 extent 수정
        if transformedCIImage.extent.origin.x < 0 || transformedCIImage.extent.origin.y < 0 {
            // 이미지의 원점을 (0, 0)으로 이동
            let xOffset = -transformedCIImage.extent.origin.x
            let yOffset = -transformedCIImage.extent.origin.y
            transformedCIImage = transformedCIImage.transformed(by: CGAffineTransform(translationX: xOffset, y: yOffset))
        }

        // 새로운 CVPixelBuffer 생성
        let context = CIContext()
        let width = Int(abs(transformedCIImage.extent.width))
        let height = Int(abs(transformedCIImage.extent.height))
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, nil, &pixelBuffer)
        
        // 정확한 렌더링 영역과 색공간 설정
        if let pixelBuffer = pixelBuffer {
            context.render(transformedCIImage, to: pixelBuffer, bounds: CGRect(x: 0, y: 0, width: width, height: height), colorSpace: CGColorSpaceCreateDeviceRGB())
        }

        return pixelBuffer
    }
 
    
    func completedAfterGpuPixel(imageBuffer: CVImageBuffer) {
        guard
            let context,
            let currentDrawable = currentDrawable,
            let commandBuffer = self.metalCommandQueue?.makeCommandBuffer() else {
            return
        }
        
        let displayImage = CIImage(cvPixelBuffer: imageBuffer)
        var scaleX: CGFloat = 0
        var scaleY: CGFloat = 0
        var translationX: CGFloat = 0
        var translationY: CGFloat = 0

        let scale: CGFloat = min(drawableSize.width / displayImage.extent.width, drawableSize.height / displayImage.extent.height)
        scaleX = scale
        scaleY = scale
        translationX = (drawableSize.width - displayImage.extent.width * scale) / scaleX / 2
        translationY = (drawableSize.height - displayImage.extent.height * scale) / scaleY / 2
        
        // 좌우 반전 적용
        let mirrorTransform = CGAffineTransform(scaleX: -1, y: 1) // X 축을 -1로 설정하여 좌우 반전
            .translatedBy(x: -displayImage.extent.width, y: 0) // 반전 후 원래 위치로 이동
        
        let bounds = CGRect(origin: .zero, size: drawableSize)
        var scaledImage: CIImage = displayImage
        
        if self.isMirrorMode {
            scaledImage = scaledImage
                .transformed(by: mirrorTransform) // 좌우 반전 적용
                .transformed(by: CGAffineTransform(translationX: translationX, y: translationY))
                .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        } else {
            scaledImage = scaledImage
                .transformed(by: CGAffineTransform(translationX: translationX, y: translationY))
                .transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        }
        

        context.render(scaledImage, to: currentDrawable.texture, commandBuffer: commandBuffer, bounds: bounds, colorSpace: CGColorSpaceCreateDeviceRGB())
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        return
    }
    

    func toPixelBuffer(image: CIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?

        // kCVPixelFormatType_32BGRA 로 변경
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(image.extent.width),
            Int(image.extent.height),
            kCVPixelFormatType_32BGRA, // 여기를 BGRA로 변경
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
            return nil
        }

        // CVPixelBuffer에 CIImage의 내용을 쓰기
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let ciContext = CIContext()
        ciContext.render(image, to: pixelBuffer, bounds: image.extent, colorSpace: CGColorSpaceCreateDeviceRGB())
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }
    
    // CVPixelBuffer -> CMSampleBuffer 변환
    func sampleBuffer(from pixelBuffer: CVPixelBuffer, presentationTime: CMTime, frameRate: Int = 30) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        
        // 프레임의 지속 시간(duration)
        let frameDuration = CMTime(value: 1, timescale: CMTimeScale(frameRate))
        
        // 디코딩 시간(decodeTimeStamp)은 일반적으로 표시 시간(presentationTimeStamp)과 동일하게 설정
        let decodeTime = presentationTime

        var timingInfo = CMSampleTimingInfo(
            duration: frameDuration,
            presentationTimeStamp: presentationTime,
            decodeTimeStamp: decodeTime
        )
        
        var videoFormatDescription: CMVideoFormatDescription?
        
        // 비디오 포맷 설명 생성
        let status = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &videoFormatDescription
        )
        
        guard status == noErr, let videoFormatDescription = videoFormatDescription else {
            print("Error creating CMVideoFormatDescription: \(status)")
            return nil
        }

        // CMSampleBuffer 생성
        let bufferStatus = CMSampleBufferCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            dataReady: true,
            makeDataReadyCallback: nil,
            refcon: nil,
            formatDescription: videoFormatDescription,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )

        guard bufferStatus == noErr else {
            print("Error creating CMSampleBuffer: \(bufferStatus)")
            return nil
        }

        return sampleBuffer
    }


}
