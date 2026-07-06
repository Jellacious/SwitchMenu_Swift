# SwitchMenu

A modern macOS utility built with SwiftUI to map game controllers and improve accessibility. SwitchMenu provides a bridge between your physical controller inputs and system-level actions, allowing for a more fluid and accessible experience on macOS.

## 🚀 Overview

SwitchMenu leverages the power of the `GameController` framework and `SwiftUI` to provide a lightweight, high-performance menu system. Whether you are using it for gaming, productivity, or as an assistive technology, SwitchMenu gives you granular control over how your controller interacts with your Mac.

### Key Features
- **Low-Latency Input Mapping**: Map game controller buttons to system actions.
- **Accessibility Optimized**: Designed with Switch Control and accessibility in mind.
- **SwiftUI Interface**: A clean, native macOS look and feel.
- **Lightweight & Fast**: Minimal system footprint.

## 🛠 Crucial Setup Steps

To ensure SwitchMenu functions correctly, please complete the following two configuration steps:

### 1. Accessibility Permissions
The application requires Accessibility access to monitor and map controller inputs at the system level.
1. Open **System Settings**.
2. Navigate to **Privacy & Security** > **Accessibility**.
3. Locate **SwitchMenu** in the list and toggle the switch to **On**.

### 2. Controller Home Button Shortcut
To launch the SwitchMenu interface directly from your controller, configure the system-level Home button action:
1. Open **System Settings**.
2. Navigate to **Game Controllers**.
3. Select your connected controller.
4. Go to **Enable Home Button Actions**.
5. Set **Press Home Button to Open** to **SwitchMenu**.

## 📖 Development

This project is built using:
- **Language**: Swift 5.10+
- **Frameworks**: SwiftUI, AppKit, GameController
- **Platform**: macOS 14.0+

### Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/jellacious/switchmenu_swift.git
   ```
2. Open `SwitchMenu.xcodeproj` in Xcode.
3. Build and Run (**⌘R**).

---

Developed with ❤️ by [Jellacious](https://github.com/jellacious).
