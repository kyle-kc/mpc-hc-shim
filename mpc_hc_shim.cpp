#include <windows.h>
#include <string>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // Step 1: Launch PowerShell Synchronously
    std::string scriptPath = "C:\\Users\\kylek\\Source\\restart-explorer\\Restart-Explorer.ps1";
    std::string psParams = "-WindowStyle Hidden -ExecutionPolicy Bypass -File \"" + scriptPath + "\"";
    
    SHELLEXECUTEINFOA sei = {0};
    sei.cbSize = sizeof(SHELLEXECUTEINFOA);
    sei.fMask = SEE_MASK_NOCLOSEPROCESS;
    sei.hwnd = NULL;
    sei.lpVerb = "open";
    sei.lpFile = "powershell.exe";
    sei.lpParameters = psParams.c_str();
    sei.nShow = SW_HIDE;
    
    if (ShellExecuteExA(&sei)) {
        WaitForSingleObject(sei.hProcess, INFINITE);
        CloseHandle(sei.hProcess);
        Sleep(2000); 
    }
    
    // Step 2: Launch original EXE with correct arguments
    std::string originalExe = "C:\\Program Files (x86)\\K-Lite Codec Pack\\MPC-HC64\\mpc-hc64_orig.exe";
    
    std::string args = "";
    if (lpCmdLine && *lpCmdLine != '\0') {
        std::string cmd = lpCmdLine;
        // Strip existing quotes from the caller to prevent doubling
        if (cmd.front() == '\"') cmd.erase(0, 1);
        if (cmd.back() == '\"') cmd.pop_back();
        
        // Re-wrap the path in a single set of quotes
        args = "\"" + cmd + "\"";
    }
    
    // Construct the final command line
    std::string fullCmd = "\"" + originalExe + "\" " + args;
    
    // CreateProcessA requires a mutable buffer. 
    char* cmdBuffer = (char*)malloc(fullCmd.length() + 1);
    if (cmdBuffer) {
        strcpy(cmdBuffer, fullCmd.c_str());
        
        STARTUPINFOA si = {0};
        si.cb = sizeof(si);
        PROCESS_INFORMATION pi = {0};
        
        if (CreateProcessA(NULL, cmdBuffer, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
            CloseHandle(pi.hProcess);
            CloseHandle(pi.hThread);
        }
        free(cmdBuffer);
    }
    
    return 0;
}