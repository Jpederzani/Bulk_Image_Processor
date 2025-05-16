Add-Type -Assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the window
$form = New-Object System.Windows.Forms.Form
$form.Text = "Bulk Photo Resizer"
$form.Size = New-Object System.Drawing.Size(600, 400)

# Create the label for the text field
$label_1 = New-Object System.Windows.Forms.Label
$label_1.Text = "Enter Path:"
$label_1.Location = New-Object System.Drawing.Point(10, 20)
$label_1.AutoSize = $true
$form.Controls.Add($label_1)


# Create the field
$pathField = New-Object System.Windows.Forms.TextBox
$pathField.Size = New-Object System.Drawing.Size(300, 20)
$pathField.Location = New-Object System.Drawing.Point(120, 20)
$form.Controls.Add($pathField)

# Create a "Browse for Filepath" button
$inBrowseBtn = New-Object System.Windows.Forms.Button
$inBrowseBtn.Text = "Browse"
$inBrowseBtn.Location = New-Object System.Drawing.Point(120, 42)
$inBrowseBtn.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($inBrowseBtn)    # Add button to form

# Add Event to button
$inBrowseBtn.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if($fileDialog.ShowDialog() -eq 'OK'){
        $pathField.Text = $fileDialog.SelectedPath
    }
})

# Create a help tip
$helpLabel_1 = New-Object System.Windows.Forms.Label
$helpLabel_1.Text = "Please enter the input filepath or click the `"Browse`" button.`nExample: `"C:\Pictures\Products\Input_Dir`""
$helpLabel_1.Location = New-Object System.Drawing.Point(120, 65)
$helpLabel_1.Size = New-Object System.Drawing.Size(400, 30)
$helpLabel_1.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($helpLabel_1)

# Create an output field
$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Output Path:"
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($label2)

# Create the text field
$outField = New-Object System.Windows.Forms.TextBox
$outField.Location = New-Object System.Drawing.Point(120, 100)
$outField.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($outField)

# Create another browse-folder dialog
$outBrowseBtn = New-Object System.Windows.Forms.Button
$outBrowseBtn.Text = "Browse" 
$outBrowseBtn.Location = New-Object System.Drawing.Point(120, 122)
$outBrowseBtn.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($outBrowseBtn)   # Add button to form
$outBrowseBtn.Add_Click({
    $outputDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if($outputDialog.ShowDialog() -eq 'OK'){
        $outField.Text = $outputDialog.SelectedPath
    }
})

# Create another help tip
$label2Help = New-Object System.Windows.Forms.Label
$label2Help.Text = "Please enter the output directory path or select the `"Browse`" button."
$label2Help.Location = New-Object System.Drawing.Point(120, 145)
$label2Help.Size = New-Object System.Drawing.Size(400, 38)
$label2Help.ForeColor = [System.Drawing.Color]::Blue
$form.Controls.Add($label2Help)

# Create a 'Start' button
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "Resize Photos"
$startButton.Location = New-Object System.Drawing.Point(150, 200)
$startButton.AutoSize = $true
$form.Controls.Add($startButton)

# Create a 'Cancel' button
$cancelBtn = New-Object System.Windows.Forms.Button
$cancelBtn.Text = "Cancel"
$cancelBtn.Location = New-Object System.Drawing.Point(300, 200)
$cancelBtn.AutoSize = $true
$form.Controls.Add($cancelBtn)

$cancelBtn.Add_Click({
    $form.Close()
})

$sourceRoot = $null
$outputRoot = $null

$startButton.Add_Click({
    # Add functionality and logic we wish to be executed when the user clicks the button.
    $sourceRoot = $script:pathField.Text
    $outputRoot = $script:outField.Text
    [System.Windows.Forms.MessageBox]::Show(" Input Photo Directory: $($sourceRoot)`nOutput Photo Directory: $($outputRoot)`n")

    Get-ChildItem -Path $sourceRoot -Recurse -Include *.jpg, *.png, *.JPEG | ForEach-Object {
        try{
            $imagePath = $_.FullName
            $relativePath = $_.FullName.Substring($sourceRoot.Length).TrimStart('\')
            $outputPath = Join-Path $outputRoot $relativePath

            # Debugging Print
            Write-Host "Image Path: $imagePath`nRelative Path: $relativePath`nOutput Path: $outputPath"
            # Create output directory if it doesn't exist
            $outputDir = Split-Path $outputPath
            if (-not (Test-Path $outputDir)) {
                New-Item -ItemType Directory -Path $outputDir | Out-Null
            }

            # Load and process image
            $img = [System.Drawing.Image]::FromFile($imagePath)

            if ($img.Width -le 600 -and $img.Height -le 600) {
                # Copy image as-is if already within limits
                Copy-Item $imagePath $outputPath
            } else {
                # Resize proportionally to fit within 600x600
                $ratioX = 600 / $img.Width
                $ratioY = 600 / $img.Height
                $ratio = [Math]::Min($ratioX, $ratioY)

                $newWidth = [int]($img.Width * $ratio)
                $newHeight = [int]($img.Height * $ratio)

                $thumbnail = New-Object System.Drawing.Bitmap $newWidth, $newHeight
                $graphics = [System.Drawing.Graphics]::FromImage($thumbnail)
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)

                $thumbnail.Save($outputPath, $img.RawFormat)

                # Cleanup
                $graphics.Dispose()
                $thumbnail.Dispose()
            }

        } catch [System.ArgumentException] {
            Write-Error "Argument Exception $($_.Message)"
        } catch [System.IO.FileNotFoundException]{
            Write-Error "File Not Found Exception: $($_.Message)"
        } catch [System.UnauthorizedAccessException] {
            Write-Error "Unauthorized Access Exception: $($_.Message)"
        } catch [System.NullReferenceException] {
            Write-Error "Null Reference Exception: $($_.Message)"
        } catch [System.OutOfMemoryException]{
            Write-Error "Out of Memory Exception: $($_.Message)"
        } catch [System.Exception]{
            Write-Error "Exeception Generated: $($_.Message)"
        } finally {
            if($img){
                $img.Dispose()
            }
        }
    }
    [System.Windows.Forms.MessageBox]::Show("Processing Completed`nResized photos are stored at: $($outputPath)")
    $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.close()
})

$form.ShowDialog()
