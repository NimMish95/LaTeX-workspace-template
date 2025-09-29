模板參考 [Kon Yi 的LaTeX筆記模板](https://github.com/Konyi0613/LaTeX/tree/main/Template)
字體預設使用： [蘋方繁體中文](https://github.com/ZWolken/PingFang)

# LaTeX 工作空間使用指南

## 目錄結構

```
LaTeX workspace/
├── templates/                 # 模板區
│   ├── shared/               # 共用資源
│   │   ├── header.tex       # 樣式設定
│   │   ├── ListStyle.tex    # 列表樣式
│   │   ├── Math.tex         # 數學巨集
│   ├── Note/             # 筆記模板（支援多lecture）
│   │   ├── master.tex       # 主文件
│   │   ├── appendix.tex     # 附錄 (目前不適用)
│   │   └── lectures/        # lecture文件夾
│   └── HW/               # 作業模板（單文件）
│       └── master.tex           # 作業文件
├── input/                   # 工作輸入區
├── output/                  # PDF輸出區  
├── build/                   # 編譯產物區（隱藏）
├── new_project.bat       # 項目創建腳本
└── compile.bat           # 編譯腳本
```

## 使用流程

### 0. 設置環境(搭配VS code的LaTeX workshop插件)
1. 開啟你VS code工作區的`setting.json`
2. 將`workspace_setting.json`的內容複製到你自己工作區的`setting.json`

使用方法見 [[#3. 編譯]]

### 1. 創建新項目

**筆記項目：**
```batch
new_project.bat "LinearAlgebra/Note/Note1" Note_v2
```

**作業項目：**
```batch
new_project.bat "LinearAlgebra/Homeworks/HW1" HW_v2
```

這會創建以下結構：
```
input/
├── LinearAlgebra/
│   ├── Note/
│   │   └── Note1/           # 筆記項目
│   │       ├── master.tex   # 主文件
│   │       ├── appendix.tex # 附錄
│   │       └── lectures/    # 在這裡創建 lec_1.tex, lec_2.tex...
│   └── Homeworks/
│       └── HW1.tex       # 直接編輯這個文件
```

### 2. 編輯內容

**對於筆記（Note）：**
- 在 `input/LinearAlgebra/Note/Note1/lectures/` 中創建：
  - `lec_1.tex`
  - `lec_2.tex` 
  - `lec_3.tex`
  - ...

每次上課就創一個新的lec.tex

**對於作業 (HW)：**
- 直接編輯作業檔案即可

### 3. 編譯

- 使用 `compile.bat` 完整編譯
- 使用 `quick_compile.bat` 快速編譯 (目錄、編號等結構可能會出錯，但速度快約4倍)

範例：
```batch
compile.bat "LinearAlgebra/Note/Note1"
quick_compile.bat "LinearAlgebra/Homeworks/HW1"
```

#### 搭配LaTeX workshop
- 對當前檔案使用`MyQuickCompiler`將對該檔案執行`quick_compile.bat`
- 對當前檔案使用`MyFullCompiler`將對該檔案執行`compile.bat`

### 4. 查看結果

編譯完成後，PDF 會出現在：
```
output/
├── LinearAlgebra/
│   ├── Note/
│   │   └── Note1.pdf
│   └── Homeworks/
│       └── HW1.pdf
```

## 特色功能

### 1. 自動路徑管理
- 支援多層目錄結構
- 自動創建對應的輸出目錄
- 編譯產物完全隔離在 build/ 資料夾

### 2. 模板系統
- **Note**: 支援多個 lecture 文件，自動載入
- **HW**: 簡化的單文件作業模板
- **shared**: 所有模板共用的樣式和設定

### 3. 清潔的工作環境
- input/ : 只有你的源文件
- output/ : 只有最終的 PDF
- build/ : 所有編譯產物（可隨時刪除）

## 進階使用

### 修改 lecture 範圍
編輯 `master.tex` 中的：
```tex
\lec{1}{10}  % 載入 lec_1.tex 到 lec_10.tex
```

### 自定義樣式
編輯 `templates/shared/` 中的文件來調整全域樣式。
- `templates/Math.tex` 新增自訂command

### 清理編譯產物
可以隨時刪除整個 `build/` 資料夾來清理所有編譯產物。

# 筆記技巧

## Callout區塊

### 主要區塊
- defination: 定義
- prev: 回顧
- exercise: 練習題
- eg: 舉例
- notation: 定義符號

- remark: 補充、解釋、討論
- Picture: 解釋命題的意義

- proposition: 較小的命題
- theorem: 核心定理、大型命題
- lemma: 引理，幫助證明theorem的功能性命題
- collary: 推論，從theorem可簡易推導的命題

- proof: 接在命題後面的證明區塊

### 子區塊
- observation: 觀察內容

- claim: 證明內較大的聲明，需要較多步驟說明
- check*: 證明內較小的聲明，簡單推導即可
- assume: 反證法區塊，假設使用
- explaination: 接在聲明區塊後面的說明

用法：`\begin{eg}\end{eg}`建立區塊
部分區塊可以加`*`去除編號，例如`\begin{defination*}`