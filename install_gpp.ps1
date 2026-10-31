# 1. 定义 MSYS2 的路径（如果你装在别的盘，比如 D 盘，请把 C 改成 D）
$MSYS2_ROOT = "C:\msys64"
$UCRT_BIN = "$MSYS2_ROOT\ucrt64\bin"
$BASH_EXE = "$MSYS2_ROOT\usr\bin\bash.exe"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  一键配置 MSYS2 环境 (PowerShell 版)" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# 检查 MSYS2 是否存在
if (-Not (Test-Path $BASH_EXE)) {
    Write-Host "❌ 找不到 MSYS2，请检查你的安装路径是否正确: $MSYS2_ROOT" -ForegroundColor Red
    exit
}

Write-Host "`n[1/3] 正在进入 MSYS2 替换清华镜像源并安装 g++..." -ForegroundColor Yellow
# 使用 bash 执行换源和安装命令
$bashCommand = @"
sed -i "s#https\?://mirror.msys2.org/#https://mirrors.tuna.tsinghua.edu.cn/msys2/#g" /etc/pacman.d/mirrorlist*
pacman -Syy
pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc
"@
& $BASH_EXE -lc $bashCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ g++ 安装失败，请检查网络或错误日志。" -ForegroundColor Red
    exit
}

Write-Host "`n[2/3] 正在配置 Windows 系统环境变量..." -ForegroundColor Yellow
# 获取当前系统环境变量中的 Path
$OldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")

# 检查路径是否已经存在，避免重复添加
if ($OldPath -split ';' -contains $UCRT_BIN) {
    Write-Host "✅ 环境变量中已存在该路径，无需重复添加。" -ForegroundColor Green
} else {
    # 追加新路径，并写回系统变量
    $NewPath = $OldPath.TrimEnd(';') + ";" + $UCRT_BIN
    [Environment]::SetEnvironmentVariable("Path", $NewPath, "Machine")
    Write-Host "✅ 成功将 $UCRT_BIN 添加到系统环境变量！" -ForegroundColor Green
}

Write-Host "`n[3/3] 正在验证 g++ 安装..." -ForegroundColor Yellow
if (Test-Path "$UCRT_BIN\g++.exe") {
    Write-Host "🎉 大功告成！g++ 已经准备就绪。" -ForegroundColor Green
    Write-Host "注意：你需要【重启 PowerShell】或重新打开 VS Code 才能在全局使用 g++ 命令。" -ForegroundColor Magenta
} else {
    Write-Host "❌ 验证失败，找不到 g++.exe。" -ForegroundColor Red
}
