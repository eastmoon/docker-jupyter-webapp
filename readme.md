# 基於 Docker 環境建立 Python 與 Jupyter 網路應用程式

此專案為 Jupyter 網路應用程式專案，其伺服器架構如下：

+ Server：[Jupyter](https://jupyter.org/)
+ Language & Library :
    - [Python](https://www.w3schools.com/python/)，腳本語言
    - [Scikit-learn](https://scikit-learn.org/stable/index.html)，機械學習函式庫
    - [Pandas](https://pandas.pydata.org/)，資料處理函式庫
    - [Matplotlib](https://matplotlib.org/)，數據視覺化函式庫

對應專案目錄設計如下：

```
<project name>
    └ src
    └ docker
    └ doc
```

+ src : Python 原始碼
+ docker : 專案編譯、封裝、測試執行相關虛擬主機容器 Dockerfile
+ doc : 本專案調言與技術說明文件

## 執行專案

+ 操作專案的開發、編譯、封裝指令

```
dockerw.bat [dev | convert | run]
```

+ 開發模式

依據 Jupyter Notebook 網路應用程式的開發環境，使用即時編譯與視覺處理提供開發環境。

```
dockerw dev [--open]
```
> 需注意，此開發環境使用 Docker 啟動，在伺服器完全開啟前會等候約一段時間自動開啟 Chrome 無痕模式並帶上登入代碼
>
> 倘若開啟後沒頁面或需要代碼，可能伺服器尚未啟動，請等候一段時間後再次輸入 ```dockerw dev --open``` 來開啟頁面

+ 轉換專案

Jupyter 使用的專案檔案為 *.ipynb，透過此指令將其轉換為 *.py 檔，供執行指令執行。

```
dockerw convert
```

+ 執行模式

啟動執行環境並執行目標專案

```
dockerw run "--exec=<python filename>"
```
> 若不指定檔案，則會列出在 ```src``` 目錄下的 *.py 檔案。
>
> ```--exec``` 需要提供的是檔案名稱，無需提供附檔名。

## 數據設計參考文獻

+ [Linear Models](https://scikit-learn.org/stable/modules/linear_model.html)
    - [迴歸模型簡介](https://pyecontech.com/2019/12/10/%E6%A9%9F%E5%99%A8%E5%AD%B8%E7%BF%92%E9%A6%96%E9%83%A8%E6%9B%B2-%E8%BF%B4%E6%AD%B8%E6%A8%A1%E5%9E%8B%E7%B0%A1%E4%BB%8B/)
    - [迴歸模型實作](https://pyecontech.com/2019/12/28/python-%E5%AF%A6%E4%BD%9C-%E8%BF%B4%E6%AD%B8%E6%A8%A1%E5%9E%8B/)
    - [多元線性迴歸分析(Multiple regression analysis)-統計說明與SPSS操作](https://www.yongxi-stat.com/multiple-regression-analysis/)
+ [Matplotlib](https://www.happycoder.org/2017/10/13/python-data-science-and-machine-learning-matplotlib-tutorial/)
