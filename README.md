# AltSwiftUI

Open Source UI framework based on SwiftUI syntax and features, adding backwards compatibility.

## Compatibility

- __Minimum iOS version__: iOS 11.0
- __SwiftUI__: Not interchangeable, but easy to share knowledge and migrate code both ways because of the high similarity in syntax.
- __UIKit__: Compatible
- __Xcode__: From Xcode 12

## Features

- [x] View rendering and automatic updates
- [x] Navigation
- [x] Collections
- [x] Essential UI components (Button, TextField, Picker, etc.)
- [x] State property wrappers
- [x] @StateObject
- [x] Animations and transitions
- [x] UIKit representables
- [x] Geometry proxy (as a binding)
- [x] Xcode previews

### Roadmap

- [ ] Lazy grids
- [ ] Environment object sub hierarchies
- [ ] Sidebar
- [ ] Shapes and paths
- [ ] @main App initializer
- [ ] @AppStorage

## Installation

### Swift Package Manager

Coming soon

### Cocoapods

Add the following to your Podfile:

```
pod 'AltSwiftUI'
```

## Usage and Documentation

AltSwiftUI has some small differences to SwiftUI, where it handles certain features slightly differently and adds some missing features as well.

### Getting Started

You can use a AltSwiftUI view hierarchy the same as in SwiftUI with `AppDelegate` or `SceneDelegate`.

Create a `HostViewController` with a root `View`, and add it to the `Window`. Even though the names are similar, don't forget you should import AltSwiftUI instead of SwiftUI.

### View Structure

The structure of a `View` is very similar to that of SwiftUI, with 2 key differences:

```swift
struct ExampleView: View {
	var viewStore = ViewValues() // Difference 1

	var body: View { // Difference 2
		Text("Welcome")
	}
}
```

1. In order for the library to internally store generic properties of a view, you need to provide a `viewStore` property initialized with an empty `ViewValues` for each view you create.

2. To target backwards compatibility, opaque return types (`some View`) which is supported from iOS 13 are not used. Instead, explicity return types are used.

### State and Rendering

State management works the same way as in SwiftUI. When a view declares a property attributed with a property wrapper, it will update the view's body when that property's value changes.

```swift
@State private var exampleText = "Original text"
@ObservedObject var myModel = MyModel()

var body: View {
	VStack {
		Text(exampleText)
		Text(myModel.value)

		Divider()
			.padding(.vertical, 10)

		MyView($myModel.value) // Will update the view when 'MyView' updates the value
		Button("Update text") {
			exampleText = "Updated text" // Will update the view on button action
		}
	}
}
```

### HStack and Multiline Texts

When using `Text` without `lineLimit` inside a `HStack`, make sure that all other elements have their width specified. Failing to do so may introduce undesired layouts.

### Previews

To work with previews, there are 2 steps that need to be done:

1. Write the preview code at the end of the file that contains the view(s) you want to preview. This works similar to SwiftUI, but the preview must also conform to `RPreviewProvider`.

```swift
#if DEBUG && canImport(SwiftUI)

import protocol SwiftUI.PreviewProvider
import protocol AltSwiftUI.View

struct MyTextPreview : RPreviewProvider, PreviewProvider {
    static var previewView: View {
        MyText()
    }
}

#endif
```

2. __Load the canvas__: As of now (Xcode 12 beta), in order to display the preview Canvas, Xcode requires that `Editor > Canvas` is enabled and the current file contains this line: `import SwiftUI`. Since AltSwiftUI files won't contain `import SwiftUI`, you must go to a file that contains it in order to open the Canvas, and then pin it so that you can use it with AltSwiftUI previews. Adding `import SwiftUI` to your file temporally to open the Canvas is also an option.

### Name conflicts for ObservableObject and Published

If you end up importing Foundation, either directly or by an umbrella framework, and try to use `ObservableObject` or `Published`, Xcode will have a hard time solving the ambiguity as Foundation currently also defines these types as _typealias_.

To solve this, you can either specify the type like `AltSwiftUI.ObservableObject` every time you use it, or you can explicitly import these 2 types, which will help resolve the ambiguity:

```swift
import Foundation
import protocol AltSwiftUI.ObservableObject
import class AltSwiftUI.Published

class MyClass: ObservableObject {
	@Published var property: Bool
}
```

### High Performance

In AltSwiftUI, certain view modifiers can cause views to update with __high performance__. Modifiers in this category will indicate it in their function documentation. You can also refer to the list below:

- `List.contentOffset()`: When the list updates the value of the binding
- `ScrollView.contentOffset()`: When the scroll view updates the value of the binding
- State changes that happen inside the closure of a `DragGesture.onChanged()`.

High performance updates __won't__ update _children views_ of `List` or `ScrollView` types. It's generally recommended for view subhierarchies that you want to modify by high performance updates to be moved to a separate `View` while passing the _state_ that causes the update as a `Binding`.

There are also a couple of modifiers you can use to alter the default behavior of high performance updates and increase performance gains. For more information see `List.ignoreHighPerformance()`, `ScrollView.ignoreHighPerformance()`, `View.strictHighPerformanceUpdate()` and `View.skipHighPerformanceUpdate()` in the documentation.

## Additional Features

### Geometry Listener

In addition to the `GeometryReader` view, AltSwiftUI also offers a `geometryListener` property. This property records changes in a view's frame and stores it in a binding, which can then be referenced in any part of the hierarchy.

Unlike `GeometryReader`, `geometryListener` doesn't generate a new view.

```swift
@State private var geometryProxy: GeometryProxy = .default

VStack {
	Text("Example")
		.geometryListener($geometryProxy)

	Color.red
		.frame(width: geometryProxy.size.width)
}

```

### Interactive Pop Gesture

Interactive pop gesture is also enabled by default for navigation views that have custom _left bar button items_ and regardless if they show the _navigation bar_ or not. To set this behavior to false in all cases, set `UIHostingController.isInteractivePopGestureEnabled` to `false`.

### Source documentation

AltSwiftUI doesn't cover 100% of SwiftUI functionality, but at the same time it also adds extra features. You can see the complete source reference [here]()(Coming soon).

## Get Involved

If you find any issues or ideas of new features/improvements, you can submit an issue in GitHub.

We also welcome you to contribute by submitting a pull request.

For more information, see [CONTRIBUTING](./CONTRIBUTING.md).

## License

MIT license. You can read the [LICENSE](./LICENSE) for more details.