
<img width="1400" height="788" alt="typofall_logo" src="https://github.com/user-attachments/assets/defda1d3-4820-443b-87c3-e22cc50225e0" />

# Description

`Typofall` is a powerful Swift framework for detecting and visualising typos by comparing a user’s input against a reference (ideal) text.
It handles missing characters, extra characters, misspellings, and swapped adjacent characters, then presents the result as an annotated, user‑friendly diff.

This direct approach allows you to find typos of any complexity in the user text, and therefore allows you to draw necessary conclusions.


## Features

- **Comprehensive diff detection** – finds missing, extra, misspelled, and swapped characters.
- **Quantity‑based validation** – define how many correct or wrong characters are acceptable (e.g., at least 75% correct, or up to 3 mistakes allowed).
- **Case handling** – case‑sensitive or case‑insensitive comparison, with optional text transformation (lowercase, uppercase, capitalized).
- **Text normalisations** – trim whitespace, collapse multiple spaces, etc., before comparison.
- **Ready‑to‑use UI** – `TFView` displays the diff with colors, strikethrough, underlines, and arrow indicators for swapped characters.
- **Efficient algorithm** – uses a three‑layer mathematical model to compute and refine diffs accurately.


# Usage

## 1. Import the framework

```Swift
import Typofall
import UIKit
```

## 2. Configure the diffing behavior

Create a `TFConfiguration` instance to control how the comparison works:
```Swift
let configuration = TFConfiguration(
    requiredQuantityOfCorrectCharacters: .high, // at least 75% correct
    acceptableQuantityOfWrongCharacters: .three, // up to 3 wrong characters allowed
    textNormalizations: [.trimmingWhitespace, .collapsingWhitespace],
    textCaseStrategy: .insensitive(.transformed(to: .lowercased))
)
```

| Parameter | Description |
| :-------- | :---------- |
| requiredQuantityOfCorrectCharacters | The minimum acceptable quantity of correct characters. |
| acceptableQuantityOfWrongCharacters | The maximum allowed quantity of wrong characters. |
| textNormalizations | The normalisations applied to **both** the user text and the reference text before comparison. |
| textCaseStrategy | The strategy for handling letter case during evaluation. |


## 3. Create a diff text

```Swift
let userInput = "Hola"
let correctAnswer = "Hello"

let result = TFText(
    comparing: userInput,
    against: correctAnswer,
    using: configuration
)
```


## 4. Display the diff with `TFView`

TFView is a UIScrollView subclass that renders the diff with visual cues: 
```Swift
let view = TFView { view in
    view.completelyCorrectColor = .systemGreen
    view.correctColor = .label
    view.warningColor = .systemYellow
    view.wrongColor = .systemRed
    view.missingColor = .systemGray3
    view.fontSize = 20
    view.fontWeight = .medium
    view.alignsTextToCenterIfFits = true
    view.padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    view.spacing = 4
}

view.text = result
```

Add the view to your hierarchy and constrain it as needed.


# Installation

In order to install `Typofall`, you add the following url in Xcode with the Swift Package Manager.

```
https://github.com/gosha-titov/Typofall.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/gosha-titov/Typofall.git", 
        .upToNextMinor(from: "1.0.0")
    )
]
```
