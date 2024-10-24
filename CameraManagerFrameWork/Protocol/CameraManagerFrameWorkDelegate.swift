//
//  AppendQueueProtocol.swift
//  HypyG
//
//  Created by 온석태 on 11/25/23.
//

import AVFoundation
import Foundation

// 우선순위
// 1. videoChangeAbleCaptureOutput [렌더링 전 수정]
// 2. videoOffscreenRenderCaptureOutput [offscreen 직접 렌더링 x ]
// 3. videoCaptureOutput [렌더링 후]

// 우선순위
// 1. PixelBuffer
// 1. CMSampleBuffer

///
/// AppendQueueProtocol 프로토콜
///
/// - Parameters:
/// - Returns:
///
@objc public protocol CameraManagerFrameWorkDelegate {
    ///
    /// 비디오관련 버퍼 생성시 매프레임마다 callback
    ///
    /// - Parameters:
    ///    - pixelBuffer ( CVPixelBuffer ) : 카메라에서 받아온 프레임 버퍼
    ///    - time ( CMTime ) : SampleBuffer에 등록된 타임스탬프
    /// - Returns:
    ///
    @objc optional func videoCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position)
    
    ///
    /// 비디오관련 버퍼 생성시 매프레임마다 callback
    ///
    /// - Parameters:
    ///    - pixelBuffer ( CVPixelBuffer ) : 카메라에서 받아온 프레임 버퍼
    ///    - time ( CMTime ) : SampleBuffer에 등록된 타임스탬프
    /// - Returns:
    ///
    @objc optional func videoCaptureOutput(sampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position)
    
    
    ///
    /// 비디오관련 버퍼 생성시 매프레임마다 callback
    ///
    /// - Parameters:
    ///    - pixelBuffer ( CVPixelBuffer ) : 카메라에서 받아온 프레임 버퍼
    ///    - time ( CMTime ) : SampleBuffer에 등록된 타임스탬프
    /// - Returns:
    ///
    @objc optional func videoOffscreenRenderCaptureOutput(pixelBuffer: CVPixelBuffer, time: CMTime, position: AVCaptureDevice.Position)
    
    ///
    /// 비디오관련 버퍼 생성시 매프레임마다 callback
    ///
    /// - Parameters:
    ///    - pixelBuffer ( CVPixelBuffer ) : 카메라에서 받아온 프레임 버퍼
    ///    - time ( CMTime ) : SampleBuffer에 등록된 타임스탬프
    /// - Returns:
    ///
    @objc optional func videoOffscreenRenderCaptureOutput(CMSampleBuffer: CMSampleBuffer, position: AVCaptureDevice.Position)
    
    ///
    /// 비디오관련 버퍼 생성시 매프레임마다 callback
    ///
    /// - Parameters:
    ///    - pixelBuffer ( CVPixelBuffer ) : 카메라에서 받아온 프레임 버퍼
    ///    - time ( CMTime ) : SampleBuffer에 등록된 타임스탬프
    /// - Returns:
    ///
    @objc optional func videoChangeAbleCaptureOutput(
           pixelBuffer: CVPixelBuffer,
           time: CMTime,
           position: AVCaptureDevice.Position
       ) -> CVPixelBuffer?
    
    ///
    /// 비디오관련 버퍼 생성시 매프레임마다 callback
    ///
    /// - Parameters:
    ///    - pixelBuffer ( CVPixelBuffer ) : 카메라에서 받아온 프레임 버퍼
    ///    - time ( CMTime ) : SampleBuffer에 등록된 타임스탬프
    /// - Returns:
    ///
    @objc optional func videoChangeAbleCaptureOutput(
        CMSampleBuffer: CMSampleBuffer,
        position: AVCaptureDevice.Position
    ) -> CMSampleBuffer?

}
