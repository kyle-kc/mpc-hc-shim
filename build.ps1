$VS_PATH = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
$SHIM_PATH = "C:\Users\kylek\Source\mpc-hc-shim"
$SOURCE_FILE = Join-Path $SHIM_PATH "mpc_hc_shim.cpp"
$OUTPUT_EXE = Join-Path $SHIM_PATH "mpc-hc64.exe"

$TARGET_DIR = "C:\Program Files (x86)\K-Lite Codec Pack\MPC-HC64"
$TARGET_ORIG = Join-Path $TARGET_DIR "mpc-hc64_orig.exe"
$TARGET_EXE = Join-Path $TARGET_DIR "mpc-hc64.exe"

if (-not (Test-Path $VS_PATH)) {
    Write-Host "ERROR: vcvarsall.bat not found at $VS_PATH" -ForegroundColor Red
    Pause
    exit
}

Write-Host "Initializing Visual Studio Environment..."
$compileCmd = "call `"$VS_PATH`" x86 && cl `"$SOURCE_FILE`" /Fe:`"$OUTPUT_EXE`" shell32.lib user32.lib"

Write-Host "Compiling shim..."
$process = Start-Process cmd -ArgumentList "/c", $compileCmd -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "Compilation successful." -ForegroundColor Green
        
    if (Test-Path $OUTPUT_EXE) {
        Write-Host "Deploying to target folder..."
        try {
            # Step 1: Backup original executable if mpc-hc64_orig.exe doesn't exist yet
            if ((Test-Path $TARGET_EXE) -and (-not (Test-Path $TARGET_ORIG))) {
                Write-Host "Backing up original mpc-hc64.exe to mpc-hc64_orig.exe..." -ForegroundColor Cyan
                Move-Item -Path $TARGET_EXE -Destination $TARGET_ORIG -Force -ErrorAction Stop
            }

            # Step 2: Copy shim binary to target folder as mpc-hc64.exe
            Copy-Item -Path $OUTPUT_EXE -Destination $TARGET_DIR -Force -ErrorAction Stop
            Write-Host "Deployment successful!" -ForegroundColor Green
        } catch {
            Write-Host "Error deploying file: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Note: You may need to run this script as Administrator to write to Program Files." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Error: Output EXE was not created." -ForegroundColor Red
    }
} else {
    Write-Host "Compilation failed with exit code $($process.ExitCode)." -ForegroundColor Red
}

Pause