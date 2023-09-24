# ScreenCaptureRedaction
Redact content when screen is recorded, or app is inactive

## Usage
```swift
import ScreenCaptureRedaction

struct MyView: View {
    var body: some View {
        ScreenCaptureRedactionView {
            Text("Really really sensitive information")
        }
    }
}
```

Alternatively,
```swift
import ScreenCaptureRedaction

struct MyView: View {
    var body: some View {
        Text("Really really sensitive information")
            .redactWhenScreenRecorded()
    }
}
```
