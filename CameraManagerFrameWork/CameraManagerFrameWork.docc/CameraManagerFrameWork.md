# ``CameraManagerFrameWork``

A camera manager library that makes it easy to use and customize all camera features.


## Overview

This framework, based on AVFoundation, allows for easy creation of cameras using basic
[`AVCaptureSession`](https://developer.apple.com/documentation/avfoundation/avcapturesession) and
[`AVCaptureMultiCamSession`](https://developer.apple.com/documentation/avfoundation/avcapturemulticamsession).


# PreView
___
## MainView
![MainView](mainView.png)

## SingleCamera
![SingleCamera](SingleCamera.jpg)

## MultiCamera
![MultiCamera](MultiCamera.jpg)


___

## Camera Functions

### Postion Switch 
![Postion Switch](SingleCamera_Postion.gif)

### Zooming

> ⚠️ **Warning**: Front camera zoom will only work with a single session.

![Zooming](SingleCamera_Zoom.gif)
 

### Controller UV Exposure
![Controller UV Exposure](SingleCamera_Exposure.gif)

### Show Thumbnail
![Show Thumbnail](SingleCamera_Thumbnail.gif)

### Torch ON/Off 
![Torch ON/Off](SingleCamera_Torch.gif)


___

## How to use

> 🔴 **Important**: You can Customize your Camera From ``CameraOptions``


### SingleCamera
> ⚠️ **Warning**: "Please make sure to use ``CameraManager/initialize()`` when creating an instance of CameraManager. After use, be sure to call ``CameraManager/unreference()`` to prevent memory leaks."


```swift

import CameraManagerFrameWork

var cameraOption = CameraOptions()
cameraOption.cameraSessionMode = .singleSession
cameraOption.cameraScreenMode = .singleScreen
cameraOption.enAblePinchZoom = true
cameraOption.cameraRenderingMode = .normal
cameraOption.tapAutoFocusAndExposure = true
cameraOption.showTapAutoFocusAndExposureRoundedRectangle = true
cameraOption.startPostion = .back

self.cameraMananger = CameraManager(cameraOptions: cameraOption)
self.cameraMananger?.setThumbnail(image: UIImage(named: "testThumbnail")!)
self.cameraMananger?.initialize()

```

### MultiCamera

> ⚠️ **Warning**: "Please make sure to use ``CameraManager/initialize()`` when creating an instance of CameraManager. After use, be sure to call ``CameraManager/unreference()`` to prevent memory leaks."

```swift

import CameraManagerFrameWork

var cameraOption = CameraOptions()
cameraOption.cameraSessionMode = .multiSession
cameraOption.cameraScreenMode = .doubleScreen
cameraOption.enAblePinchZoom = true
cameraOption.cameraRenderingMode = .normal
cameraOption.tapAutoFocusAndExposure = true
cameraOption.showTapAutoFocusAndExposureRoundedRectangle = true
cameraOption.startPostion = .back

cameraOption.onChangeMainScreenPostion = { currentPosition in
    self.isFrontMainCamera = currentPosition == .front ? true : false
}

cameraOption.onChangeScreenMode = { currentScreenMode in
    guard let currentScreenMode = currentScreenMode else { return }
    self.currentScreenMode = currentScreenMode
}

self.cameraMananger = CameraManager(cameraOptions: cameraOption)
self.cameraMananger?.setThumbnail(image: UIImage(named: "testThumbnail")!)
self.cameraMananger?.initialize()

```
