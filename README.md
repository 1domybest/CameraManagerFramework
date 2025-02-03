
# OTIS_CameraManager_Example

# CameraManagerLibrary

[![Documentation](https://img.shields.io/badge/library-documentation-orange)](https://1domybest.github.io/CameraManagerLibrary/documentation/cameramanagerframework/)


<p align="center">
  
A camera manager library that makes it easy to use and customize all camera features.

Libarary: https://github.com/1domybest/CameraManagerLibrary

documentation : https://1domybest.github.io/CameraManagerLibrary/documentation/cameramanagerframework/

> If you're interested in learning more about me, feel free to visit my profile [here!](https://github.com/1domybest)"😻
</p>

<br>

## Sample Code

[OTIS_CameraManager_Example](https://github.com/1domybest/OTIS_CameraManager_Example)


<br>

## SingleCamera PreView
<p align="center">
  <img src="https://github.com/1domybest/CameraManagerLibrary/blob/main/Sample/SingleCamera.jpg" alt="SingleCamera" height="500" width="281" />    
</p>


## MultiCamera PreView
<p align="center">
  <img src="https://github.com/1domybest/CameraManagerLibrary/blob/main/Sample/MultiCamera.jpg" alt="MultiCamera" height="500" width="281" />  
</p>


>> **Note**: you can see more sample gif or pic [here](https://github.com/1domybest/CameraManagerLibrary/tree/main/Sample)

</br>

## Installation:

Project -> General -> Frameworks, Libraries, and Embedded Content -> press + -> Add Package Dependency -> https://github.com/1domybest/CameraManagerLibrary -> Add Package

<p align="center">
  <img src="https://github.com/1domybest/CameraManagerLibrary/blob/main/Sample/installation.png" alt="installation"/>  
</p>



</br>

## Permissions:

```swift
<key>NSCameraUsageDescription</key>
<string>This app requires access to the camera to take photos.</string>
```

or

**Go to Targets in Project -> Info -> Custom IOS Target Properties -> Press + Button -> Write down "Privacy - Camera Usage Description"**

<p align="center">
  <img align="center" src="https://github.com/1domybest/CameraManagerLibrary/blob/main/Sample/permission.png" alt="permission"/>
</p>




## How to Use

>> **Warning**: "Please make sure to use `CameraManager.initialize()` when creating an instance of CameraManager. 
>> After use, be sure to call `CameraManager.unreference()` to prevent memory leaks."
>>

### SingleCamera

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


## CameraOptions

| options | Description | Default |
| --- | --- | --- |
| `startPostion` | when camera session started first time you can chose what position you want | .back |
| `cameraScreenMode` | Modes for Camera Screen | .singleScreen |
| `cameraSessionMode` | Modes For Camera Session | .singleSession |
| `cameraRenderingMode` | Modes for rendering the camera output. | .normal |
| `tapAutoFocusAndExposure` | if its's `true` when you tab screen Focus and Exposure will be adjusted automatically. | true |
| `showTapAutoFocusAndExposureRoundedRectangle` | if its's `true` when you tab screen yellow box  will show on screen | true |
| `enAblePinchZoom` | if its's `true` the pinch zoom will turn on | true |
| `onChangeMainScreenPostion` | Callback when you using `CameraSessionMode/multiSession` and the mainCamera View Switch between FrontCamera and BackCamera this callback will be called with postion | { _ in } |
| `onChangeScreenMode` | Callback when you using `CameraSessionMode/multiSession` and the View Switch between singleScreen and doubleScreen this callback will be called with `CameraScreenMode` | { _ in } |

## Version

| Name     |  |
| ---      | ---       |
| Platform | IOS         |
| Minimum Deployments | 14.0        |

</details>

## Features:

- [x] MultiCamera
- [x] SingleCamera
- [x] change Camera Position
- [x] Zooming
- [x] Change UV Exposure
- [x] set and show Thumbnail
- [x] session start and stop(pause)
- [x] Torch
- [x] offscreen render
- [x] on embeded camera View
- [x] pipe line for edit frame before render

