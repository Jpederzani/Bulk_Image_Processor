# Bulk Photo Resizer (PowerShell GUI)

This is a simple PowerShell-based GUI application that allows users to resize product photos in bulk. The tool provides a very basic user interface to enter an input directory, an output directory, and automatically resizes any `.jpg`, `.jpeg`, or `.png` images to fit within a 600x600 pixel box (maintaining aspect ratio).

## Features

- Graphical user interface — no command line knowledge required
- Supports JPEG and PNG formats
- Automatically preserves folder structure from the source
- Resizes only if images exceed 600x600 dimensions
- Gracefully handles common image and access-related errors
- Displays confirmation and success messages after processing

## Requirements

- Windows 10 or later
- PowerShell 5.1+
- .NET Framework (comes with Windows)

## How to Use

1. **Download or clone** this repository.
2. **Right-click** `ResizePhotos.ps1` and select **Run with PowerShell**.
3. Enter the **source folder path** containing the photos to resize.
4. Enter the **destination folder path** where resized photos will be saved.
5. Click **Resize Photos**.
6. A popup will confirm successful processing and the window will close.

> 💡 Tip: You can modify the script to allow folder browsing with a file dialog if needed.

## Notes

- ***The output folder must already exist before running the tool.***
- The tool copies unmodified images if they are already within size limits.
- Errors during processing are printed to the PowerShell console but do not stop the batch.

## License

MIT License — feel free to use, modify, and share.
