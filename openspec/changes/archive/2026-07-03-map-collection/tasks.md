## 1. 資料與 API

- [x] 1.1 Record 模型新增 latitude、longitude、hasLocation
- [x] 1.2 RecordRepository：fetchMapRecords、createRecord 帶座標
- [x] 1.3 更新 docs/api.md（座標欄位與 GET /records/map）

## 2. GPS 上傳

- [x] 2.1 LocationService（geolocator）
- [x] 2.2 create_record_notifier 上傳前讀 GPS
- [x] 2.3 Android/iOS 定位權限宣告

## 3. 地圖頁

- [x] 3.1 map_records_provider
- [x] 3.2 ExplorePage：marker、bbox 刷新、定位按鈕
- [x] 3.3 MapRecordCard 與詳情導航

## 4. 驗證

- [x] 4.1 flutter analyze / test
