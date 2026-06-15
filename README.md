# Timebox

A macOS menu bar app that displays a visual progress bar along the top edge of the screen — designed for MacBook models with a notch.

## What it does

- Click the clock icon in the menu bar, enter a duration in minutes, and hit **Start**
- A thin bar fills left-to-right across the top of your screen, shifting from green → yellow → red as time runs out
- On completion, the bar pulses 3 times in sync with haptic feedback through the trackpad
- A silent banner notification fires so you're covered even if you've looked away
- Launches at login automatically

## Requirements

- macOS 26+ (Tahoe)
- MacBook with a notch (MacBook Air M2+, MacBook Pro M1+)

## Notification setup

On first launch, approve the notification permission dialog. If you missed it, go to **System Settings → Notifications → Timebox** and enable notifications with alert style set to **Banners**.

## Stack

Pure AppKit — no SwiftUI. `NSWindow` at `.screenSaver` level with a `CALayer` progress bar. `NSHapticFeedbackManager` for trackpad feedback. `UNUserNotificationCenter` for silent banner notifications.

## Building

Open `Timebox.xcodeproj` in Xcode and press `⌘R`.
