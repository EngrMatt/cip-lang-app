# record-create

## Purpose

新增語料表單：收集標題、類型與備註等基本資訊。

## Requirements

### Requirement: 新增語料表單

系統 SHALL 提供表單讓使用者輸入語料基本資訊。

#### Scenario: 顯示表單欄位

- **WHEN** 使用者進入新增語料頁
- **THEN** 系統顯示標題（必填）、類型（必填）、備註（選填）欄位

#### Scenario: 必填欄位驗證

- **WHEN** 使用者未填寫標題或類型即嘗試繼續
- **THEN** 系統顯示驗證錯誤並阻止繼續

#### Scenario: 填寫完成

- **WHEN** 使用者填寫所有必填欄位
- **THEN** 系統允許進入錄音或拍照步驟

### Requirement: 語料類型選擇

系統 SHALL 提供語料類型選擇方式（下拉選單或預設選項）。

#### Scenario: 選擇類型

- **WHEN** 使用者選擇語料類型
- **THEN** 系統記錄所選類型供後續上傳使用

### Requirement: 採集 GPS 座標

系統 SHALL 於上傳語料時嘗試讀取裝置 GPS，並於 `POST /records` 帶入座標。

#### Scenario: 取得座標成功

- **WHEN** 使用者完成新增語料並上傳，且 GPS 可用
- **THEN** 系統於建立請求帶入 `latitude` 與 `longitude`

#### Scenario: 取得座標失敗

- **WHEN** GPS 不可用或使用者拒絕定位權限
- **THEN** 系統仍允許建立語料（不帶座標），該筆不顯示於地圖

### Requirement: 族語符號快捷輸入

系統 SHALL 在標題與備註輸入欄位上方提供族語常用符號快捷列，點擊後於游標處插入符號。

#### Scenario: 插入符號

- **WHEN** 使用者點擊符號 Chip
- **THEN** 系統於目前游標位置插入該符號
