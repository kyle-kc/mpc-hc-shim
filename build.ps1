$VS_PATH = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
$SHIM_PATH = "C:\Users\kylek\Source\mpc-hc-shim"
$SOURCE_FILE = Join-Path $SHIM_PATH "mpc_hc_shim.cpp"
$OUTPUT_EXE = Join-Path $SHIM_PATH "mpc-hc64.exe"

if (-not (Test-Path $VS_PATH)) {
    Write-Host "ERROR: vcvarsall.bat not found at $VS_PATH" -ForegroundColor Red
    Pause
    exit
}

Write-Host "Initializing Visual Studio Environment..."
# We call vcvarsall.bat and then run cl.exe in the same process context
# Using 'cmd /c' ensures the environment variables from vcvarsall.bat are inherited.
$compileCmd = "call `"$VS_PATH`" x86 && cl `"$SOURCE_FILE`" /Fe:`"$OUTPUT_EXE`" shell32.lib user32.lib"

Write-Host "Compiling shim..."
$process = Start-Process cmd -ArgumentList "/c", $compileCmd -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "Compilation successful." -ForegroundColor Green
        
    $TARGET_PATH = "C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64\"
    $OUTPUT_EXE = "C:\Users\kylek\Source\mpc-hc-shim\mpc-hc64.exe"

    if (Test-Path $OUTPUT_EXE) {
        Write-Host "Copying executable to target folder..."
        try {
            Copy-Item -Path $OUTPUT_EXE -Destination $TARGET_PATH -Force -ErrorAction Stop
            Write-Host "Deployment successful!" -ForegroundColor Green
        } catch {
            Write-Host "Error copying file: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Note: You may need to run this script as Administrator to overwrite files in Program Files." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Error: Output EXE was not created." -ForegroundColor Red
    }
} else {
    Write-Host "Compilation failed with exit code $($process.ExitCode)." -ForegroundColor Red
}

Pause
