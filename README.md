# Timebox

A macOS menu bar app that displays a visual progress bar along the top edge of the screen — designed for MacBook models with a notch.

## What it does

- Click the clock icon in the menu bar, enter a duration in minutes, and hit **Start**
- A thin 3px bar fills left-to-right across the top of your screen, shifting from green → yellow → red as time runs out
- On completion, the bar pulses and a system notification fires
- Launches at login automatically

## Requirements

- macOS 26+ (Tahoe)
- MacBook with a notch (MacBook Air M2+, MacBook Pro M1+)

## Stack

Pure AppKit — no SwiftUI. `NSWindow` at `.screenSaver` level with a `CALayer` progress bar.

## Building

Open `Timebox.xcodeproj` in Xcode and press `⌘R`.
