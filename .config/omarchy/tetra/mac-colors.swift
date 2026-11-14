// Installs each Tetra variant as a macOS colour palette ("Tetra Dark", "Tetra
// Mirage", "Tetra Light"), so it shows up under the palettes tab of every
// app's colour panel (Keynote, Pages, Freeform, Color Picker, ...).
//
// Usage (on a Mac): swift ~/.config/omarchy/tetra/mac-colors.swift
// Re-run after regenerating the themes. Reads colors.toml from
// ~/.config/omarchy/themes/tetra-*/ and writes ~/Library/Colors/Tetra *.clr.
import AppKit

let home = FileManager.default.homeDirectoryForCurrentUser
let colorsDir = home.appendingPathComponent("Library/Colors")
try FileManager.default.createDirectory(at: colorsDir, withIntermediateDirectories: true)

// Palette order: what you reach for first, then the full ANSI set, then shades.
let order = ["accent", "selection", "muted",
             "red", "orange", "yellow", "brown", "green", "cyan", "blue", "magenta",
             "bright_red", "bright_yellow", "bright_green", "bright_cyan", "bright_blue", "bright_magenta",
             "darker_background", "dark_background", "background", "lighter_background",
             "dark_foreground", "foreground", "light_foreground", "bright_foreground"]

func hexColor(_ hex: String) -> NSColor? {
    guard hex.count == 7, let v = UInt32(hex.dropFirst(), radix: 16) else { return nil }
    return NSColor(srgbRed: CGFloat(v >> 16 & 0xff) / 255, green: CGFloat(v >> 8 & 0xff) / 255,
                   blue: CGFloat(v & 0xff) / 255, alpha: 1)
}

for variant in ["dark", "mirage", "light"] {
    let toml = home.appendingPathComponent(".config/omarchy/themes/tetra-\(variant)/colors.toml")
    guard let text = try? String(contentsOf: toml, encoding: .utf8) else {
        print("skipped tetra-\(variant): no \(toml.path)")
        continue
    }
    // colors.toml is flat `key = "#rrggbb"` lines; that's all this needs to read.
    var colors: [String: NSColor] = [:]
    for line in text.split(separator: "\n") {
        let parts = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2, let c = hexColor(parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))) {
            colors[parts[0]] = c
        }
    }
    let name = "Tetra \(variant.capitalized)"
    let list = NSColorList(name: name)
    for key in order {
        if let c = colors[key] {
            list.insertColor(c, key: key.replacingOccurrences(of: "_", with: " "), at: list.allKeys.count)
        }
    }
    let out = colorsDir.appendingPathComponent("\(name).clr")
    try list.write(to: out)
    print("wrote \(out.path) (\(list.allKeys.count) colours)")
}
