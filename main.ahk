#include <FindText>
#include <RapidOcr/RapidOcr>
#include util.ahk
#Include <ImagePut>

; 单实例运行
#SingleInstance Force

if !A_IsAdmin {
    MsgBox("请以管理员身份运行")
    ExitApp
}

ShowToolTip("
(
云顶之弈突变搜索
按 F1 开始搜索
按 F2 停止搜索
)")


; 安装键盘钩子
InstallKeybdHook
; 设置坐标模式为像素
CoordMode("Pixel", "Screen")

ocr := RapidOcr()
; 指示是否停止搜索
stopSearch := false

; 当前搜索记录
currentSearchHistory := Map()

/**
 * 使用OCR识别指定区域的文本
 * @param x1 
 * @param y1 
 * @param x2 
 * @param y2 
 * @param widthRatio 宽度比例
 * @param heightRatio 高度比例
 * @returns {String} 
 */
FindTextByOcr(x1, y1, x2, y2, wRatio := 1, hRatio := 1) {
    x1 := x1 * wRatio
    y1 := y1 * hRatio
    x2 := x2 * wRatio
    y2 := y2 * hRatio
    x := x1
    y := y1
    w := Abs(x2 - x1) + 1
    h := Abs(y2 - y1) + 1
    ; 获取指定区域的截图
    pBitmap := FindText().BitmapFromScreen(&x, &y, &w, &h)
    ; 将截图转换为 ImagePutBuffer
    pBuf := ImagePutBuffer(pBitmap)
    ; 构造用于传递给`ocr`的结构体
    NumPut("ptr", pBuf.ptr, "uint", pBuf.size // pBuf.height, "uint", pBuf.width, "uint", pBuf.height, "uint", 4, "uint", 0, "uint", 0, st_BF := Buffer(40, 0))
    ; 使用`ocr`进行识别
    text := ocr.ocr_from_bitmapdata(st_BF)
    ; 去除空格
    text := Trim(text, " `t`n`r")
    return text
}

; 搜索记录写到日志文件
searchHistoryWriteToFile() {
    outText := ""
    for key, value in currentSearchHistory {
        outText .= key "," value "`n"
    }
    ; 确保日志目录存在
    logDir := "logs"
    if !FileExist(logDir)
    {
        ; 创建
        DirCreate(logDir)
    }
    ; 写入到文件
    FileAppend(outText, "logs/" A_Now ".txt", "`n UTF-8")
}


; 确保在英雄联盟客户端中运行
; #HotIf WinActive("ahk_exe League of Legends.exe")
; #HotIf

; 绑定热键F1
$F1::
{
    if !WinExist("ahk_exe League of Legends.exe") {
        MsgBox("游戏未运行")
        return
    }
    global stopSearch
    stopSearch := false
    currentSearchHistory.Clear()
    ; 读取配置文件拿到搜索目标突变
    targetAnomalies := ReadConfigFile()
    ; 判断目标突变是否为空
    if (targetAnomalies == "") {
        MsgBox("配置文件中未设置突变目标")
        return
    }
    ; 绑定窗口
    FindText().BindWindow(WinExist("ahk_exe League of Legends.exe"), 4)
    ; 获取窗口大小, 由于本脚本测试时是在4K分辨率下进行的, 在另外的分辨率下需要调整坐标
    WinGetPos(&WindowX, &WindowY, &WindowW, &WindowH, "League of Legends")
    ; 4k: 3840 * 2160.
    ; 计算宽度和高度比例
    wRatio := WindowW / 3840
    hRatio := WindowH / 2160

    text := FindTextByOcr(1680, 1780, 2130, 1850, wRatio, hRatio)
    ; 判断是否以`选择一名要进化的英雄`开头
    if (InStr(text, "选择一名要进化的英雄") != 1) {
        ShowToolTip("异常突变未出现")
        return
    }
    ShowToolTip("开始搜索指定的异常突变")
    loop {
        if (stopSearch) {
            break
        }
        text := FindTextByOcr(1230, 1860, 2000, 1920, wRatio, hRatio) ; 目标文本: {突变名称}
        ; 获取`text`第一行
        text := SubStr(text, 1, InStr(text, "`n") - 1)
        ; 以`{突变名称}`为键, 记录出现的次数
        currentSearchHistory[text] := currentSearchHistory.Has(text) ? currentSearchHistory.Get(text) + 1 : 1
        if (text == targetAnomalies) {
            ShowToolTip("找到指定异常突变")
            break
        } else {
            ; 确保英雄联盟窗口处于激活状态
            WinActivate("League of Legends")
            ; 发送d键刷新
            Send "d"
        }

        ; 防止循环过快
        Sleep 100
    }
    ShowToolTip("搜索结束")
    ; 写到日志文件
    searchHistoryWriteToFile()
}

; 绑定热键F2以停止搜索
$F2::
{
    global stopSearch
    stopSearch := true
}