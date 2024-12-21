$version = 0.2
# 调用 7z 打包
7z a -tzip tft-anomalies-$version.zip main.exe ./Lib/RapidOcr/64bit/ ./Lib/RapidOcr/models/
