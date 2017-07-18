# SBCardPopup

[![Version](https://img.shields.io/cocoapods/v/SBCardPopup.svg?style=flat)](http://cocoapods.org/pods/SBCardPopup)
[![License](https://img.shields.io/cocoapods/l/SBCardPopup.svg?style=flat)](http://cocoapods.org/pods/SBCardPopup)
[![Platform](https://img.shields.io/cocoapods/p/SBCardPopup.svg?style=flat)](http://cocoapods.org/pods/SBCardPopup)

Easily show a `UIViewController` or `UIView` in a popup card UI.

![cardgif](https://user-images.githubusercontent.com/6288713/28306754-70b20158-6b98-11e7-8130-076f49210a37.gif)

## Example

Run `Example/SBCardPopupExample.xcodeproj`

## Usage

#### Showing a popup

Create an SBCardPopupViewController passing in your view controller. (There is a method to pass in a UIView subclass if you prefer). 

Call `show()` passing in the current view controller.

```swift
let cardPopup = SBCardPopupViewController(contentViewController: myViewController)
cardPopup.show(onViewController: self)
```

#### SBCardPopupContent protocol

Your view controller can optionally conform to the `SBCardPopupContent` protocol. This allows the view controller to enable/disable the tap and swipe to dismiss gestures.

```swift
public protocol SBCardPopupContent: class {
    weak var popupViewController: SBCardPopupViewController? {get set}
    var allowsTapToDismissPopupCard: Bool {get}
    var allowsSwipeToDismissPopupCard: Bool {get}
}
```

The protocol will also ensure that your view controller has a reference to it's `SBCardPopupViewController` container. This is useful if it needs to dismiss itself, for instance, on a button press.

```swift
@IBAction func closeButtonPressed(sender: UIButton){
	popupViewController?.close()
}
```

#### Customisation

Public properties can be modified for the `SBCardPopupViewController` corner radius, and also flags to disable dismiss gestures. These flags take precendece over the `SBCardPopupContent` protocol.

If you wish to disable gestures for all popups, it can be more convinient to do this on the `SBCardPopupViewController` before it is presented, and create a single popup presentation point in your application so that these setting are always used.

```swift
extension UIViewController {

	func presentViewControllerAsPopup(_ viewController: UIViewController) {
		
		let cardPopup = SBCardPopupViewController(contentViewController: viewController)
		cardPopup.cornerRadius = 5
		cardPopup.allowsTapToDismissPopupCard = true
		cardPopup.allowsSwipeToDismissPopupCard = false
		cardPopup.show(onViewController: self)
	}
}
```

## Creating Popup UI

`SBCardPopupViewController` uses AutoLayout, which makes it easy to size the card correctly around the content. It does, however, mean that you need to provide constraints that fully describe the height of the card.

In the following example, the top label is pinned to the top of the view controller, and the bottom label is pinned to the bottom. As there is no constraint connecting the two labels, the distance between them is not known, this will case issues when trying to size the popup card.

![IMG](https://user-images.githubusercontent.com/6288713/28306674-2550baf6-6b98-11e7-94a6-a3551709713a.png)

By adding a constraint between the two labels, the full height of the card has been described. In order to resolve errors in Interface Builder, you will need to size your view contoller to match the output of the constraints, or make one of the constraints low priority.

![IMG](https://user-images.githubusercontent.com/6288713/28306682-2982b822-6b98-11e7-96dd-581537d0d665.png)

## Installation

SBCardPopup is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SBCardPopup"
```

## Author

Steve Barnegren, steve.barnegren@gmail.com

## License

SBCardPopup is available under the MIT license. See the LICENSE file for more info.
