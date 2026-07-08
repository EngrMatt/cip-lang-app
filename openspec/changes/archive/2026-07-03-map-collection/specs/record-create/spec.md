## ADDED Requirements

### Requirement: 採集 GPS 座標

系統 SHALL 於上傳語料時嘗試讀取裝置 GPS，並於 `POST /records` 帶入座標。

#### Scenario: 取得座標成功

- **WHEN** 使用者完成新增語料並上傳，且 GPS 可用
- **THEN** 系統於建立請求帶入 `latitude` 與 `longitude`

#### Scenario: 取得座標失敗

- **WHEN** GPS 不可用或使用者拒絕定位權限
- **THEN** 系統仍允許建立語料（不帶座標），該筆不顯示於地圖
