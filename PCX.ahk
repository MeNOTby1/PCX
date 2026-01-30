#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; ===== START WINDOW =====
Gui, Font, s11, Segoe UI
Gui, Add, Text, x0 y20 w320 Center, PC Analyzer
Gui, Add, Button, x100 y80 w120 h30 gStartAnalysis, Start Analysis
Gui, Show, w320 h150, PCX v1.0
return

StartAnalysis:
Gui, Destroy

startTime := A_TickCount
TrayTip, PCX v1.0, Analyzing system..., 2

Sleep, 2000

if ((A_TickCount - startTime) > 3000)
    MsgBox, 64, PCX v1.0, Analysis is taking longer than expected. Please stay calm...

ramGB := GetRAM()
storageText := GetStorageText()
storageGB := GetStorageValue()
os := GetOS()

cpuModel := GetCPU()
cpuBrand := GetCPUBrand(cpuModel)

gpuModel := GetGPU()
gpuBrand := GetGPUBrand(gpuModel)

score := 0
maxScore := 0   ; max score

; ===== RAM SCORE =====
ramScore := 0
if (ramGB <= 4)
    ramScore := 4
else if (ramGB <= 8)
    ramScore := 10
else if (ramGB <= 16)
    ramScore := 16
else if (ramGB <= 32)
    ramScore := 30
else
    ramScore := 40
score += ramScore
maxScore += 40

; ===== STORAGE SCORE =====
storageScore := 0
if (storageGB <= 128)
    storageScore := 5
else if (storageGB <= 256)
    storageScore := 10
else if (storageGB <= 512)
    storageScore := 20
else if (storageGB <= 1024)
    storageScore := 30
else
    storageScore := 40
score += storageScore
maxScore += 40

; ===== OS SCORE =====
osScore := 0
if (os = "Windows")
    osScore := 24
else if (os = "macOS")
    osScore := 12
else if (os = "Linux")
    osScore := 32
score += osScore
maxScore += 32

; ===== CPU SCORE =====
cpuScore := 0
if (cpuBrand = "AMD")
    cpuScore += 30
else if (cpuBrand = "Intel")
    cpuScore += 20

if InStr(cpuModel, "Ryzen 3") || InStr(cpuModel, "i3")
    cpuScore += 5
else if InStr(cpuModel, "Ryzen 5") || InStr(cpuModel, "i5")
    cpuScore += 10
else if InStr(cpuModel, "Ryzen 7") || InStr(cpuModel, "i7")
    cpuScore += 18
else if InStr(cpuModel, "Ryzen 9") || InStr(cpuModel, "i9")
    cpuScore += 25

score += cpuScore
maxScore += 55   ; CPU max ≈ 55

; ===== GPU SCORE =====
gpuScore := 0
if (gpuBrand = "NVIDIA")
    gpuScore += 46
else if (gpuBrand = "AMD")
    gpuScore += 26
else if (gpuBrand = "Intel")
    gpuScore += 12

if InStr(gpuModel, "RTX")
    gpuScore += 30
else if InStr(gpuModel, "GTX")
    gpuScore += 15
else if InStr(gpuModel, "RX")
    gpuScore += 20
else if InStr(gpuModel, "UHD") || InStr(gpuModel, "Iris")
    gpuScore += 5

score += gpuScore
maxScore += 76   ; GPU max ≈ 76

; ===== PERCENTAGE =====
percent := Round((score / maxScore) * 100, 1)

; ===== RESULT WINDOW =====
Gui, Font, s14 bold, Segoe UI
Gui, Add, Text, x0 y10 w560 Center, TOTAL SCORE: %score% / %maxScore%  (%percent%`%)
Gui, Font, s10 norm, Segoe UI

Gui, Add, ListView, x20 y50 w520 h170 Grid, Category|Value|Score

LV_ModifyCol(1, 130)
LV_ModifyCol(2, 300)
LV_ModifyCol(3, 70)

LV_Add("", "RAM", ramGB " GB", "+" ramScore)
LV_Add("", "Storage", storageText, "+" storageScore)
LV_Add("", "OS", os, "+" osScore)
LV_Add("", "CPU", cpuModel, "+" cpuScore)
LV_Add("", "GPU", gpuModel, "+" gpuScore)

Gui, Add, Button, x230 y230 w100 h30 gCloseApp, Close
Gui, Show, w560 h280, PCX v1.0
return

CloseApp:
ExitApp

; ================= FUNCTIONS =================

GetRAM() {
    total := 0
    for obj in ComObjGet("winmgmts:").ExecQuery("Select Capacity from Win32_PhysicalMemory")
        total += obj.Capacity
    return Round(total / 1024 / 1024 / 1024)
}

GetStorageValue() {
    total := 0
    for obj in ComObjGet("winmgmts:").ExecQuery("Select Size from Win32_DiskDrive")
        total += obj.Size
    return Round(total / 1024 / 1024 / 1024)
}

GetStorageText() {
    total := 0
    for obj in ComObjGet("winmgmts:").ExecQuery("Select Size from Win32_DiskDrive")
        total += obj.Size

    gb := total / 1024 / 1024 / 1024
    if (gb >= 1024)
        return Round(gb / 1024, 2) " TB"
    else
        return Round(gb) " GB"
}

GetOS() {
    for obj in ComObjGet("winmgmts:").ExecQuery("Select Caption from Win32_OperatingSystem") {
        name := obj.Caption
        if InStr(name, "Windows")
            return "Windows"
        else if InStr(name, "Mac")
            return "macOS"
        else
            return "Linux"
    }
    return "Unknown"
}

GetCPU() {
    for obj in ComObjGet("winmgmts:").ExecQuery("Select Name from Win32_Processor")
        return obj.Name
}

GetCPUBrand(cpuName) {
    if InStr(cpuName, "AMD")
        return "AMD"
    else if InStr(cpuName, "Intel")
        return "Intel"
    return "Unknown"
}

GetGPU() {
    for obj in ComObjGet("winmgmts:").ExecQuery("Select Name from Win32_VideoController")
        return obj.Name
}

GetGPUBrand(gpuName) {
    if InStr(gpuName, "NVIDIA")
        return "NVIDIA"
    else if InStr(gpuName, "AMD") || InStr(gpuName, "Radeon")
        return "AMD"
    else if InStr(gpuName, "Intel")
        return "Intel"
    return "Unknown"
}
