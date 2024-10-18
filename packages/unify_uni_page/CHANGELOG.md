## 0.0.8+bugfix1

- iOS:
  - Fixed an issue where UniPage was not released when directly closing the container after opening a new one.
  - Improved compatibility with swipe-back gesture in hybrid routing scenarios.

## 0.0.8

- feat: Android impl of UniPage postCreate

## 0.0.7

- feat: Unipage adds postCreate lifecycle method

## 0.0.6

- Updated the gestureRecognizers for both iOS and Android platforms to use EagerGestureRecognizer instead of an empty set, improving the responsiveness of the UI.

## 0.0.5

- feat: UniPageLifecycleHolder: add findUniPagesByActivity method

## 0.0.4

- feat: CommonParams
- fix: use empty Map as params to avoid casting Null to Map

## 0.0.3

- add an onPlatformViewDispose callback to AbsUniPageFactoryListener

## 0.0.2

- Android UniPage: make onForeground and public
- Merge unipage branch into master. Delete unipage branch.

## 0.0.1

- First release.
- Still in developing, not for production usage.
