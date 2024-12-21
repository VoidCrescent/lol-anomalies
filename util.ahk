#include <BTT>

/**
 * @param string 需要打印的字符串
 */
print(string) {
    OutputDebug(string . "`n")
}

/**
 * @param text 需要去除非中文字符的字符串
 * @return {string} 去除非中文字符后的字符串
 */
RemoveNonChinese(text) {
    return RegExReplace(text, "[^\p{Han}]+")
}


;#region btt


ToolTipStyle8 := { Border: 3
    , Rounded: 30
    , Margin: 30
    , BorderColorLinearGradientStart: 0xffb7407c
    , BorderColorLinearGradientEnd: 0xff3881a7
    , BorderColorLinearGradientAngle: 45
    , BorderColorLinearGradientMode: 1
    , TextColor: 0xffd9d9db
    , BackgroundColor: 0xff26293a
    , FontSize: 18
}

/**
 * 显示提示框
 * @param str 需要显示的文本
 * @param style 提示框样式
 * @param time 提示框显示时间
 */
ShowToolTip(str, style := ToolTipStyle8, time := 3000) {
    print(str)
    btt(str, , , , style)
    SetTimer () => btt(), -time
}

;#endregion btt


/**
 * 读取配置文件, 返回需要搜索的突变
 * @return {string} 配置文件内容
 */
ReadConfigFile() {
    ; ; 读取配置文件
    ; fileContent := FileRead(filename, "`n UTF-8")
    ; fileLines := StrSplit(fileContent, "`n", "`r") ; 按行拆分，处理换行符
    ; while (fileLines.Length && Trim(fileLines.Get(fileLines.Length)) = "")
    ;     fileLines.RemoveAt(fileLines.Length) ; 删除尾部空白行
    ; for each, line in fileLines
    ;     targetName := line
    ; targetName := Trim(targetName)
    ; return targetName
    return IniRead("config.ini", "config", "targetAnomalies")
}