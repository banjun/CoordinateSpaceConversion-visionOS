
## CoordinateSpaceConversion-visionOS

Sample for visionOS coordinate space conversion among volumetric windows, plain windows and immersive space.

See [AppModel.swift](CoordinateSpaceConversion/AppModel.swift)

## Screenshots

https://github.com/user-attachments/assets/7c408b0b-2de2-458a-9c16-47abb3614066

## Related Documents

RealityCoordinateSpaceConverting

<https://developer.apple.com/documentation/realitykit/realitycoordinatespaceconverting>

```
func transform(from: some RealityCoordinateSpace, to: some CoordinateSpaceProtocol) -> AffineTransform3D
func transform(from: some CoordinateSpaceProtocol, to: some RealityCoordinateSpace) -> AffineTransform3D
```


## Related WWDC Video

[Dive deep into volumes and immersive spaces - WWDC24](https://developer.apple.com/videos/play/wwdc2024/10153/?time=1122)
