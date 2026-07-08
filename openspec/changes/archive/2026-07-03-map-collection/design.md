## 架構

- `lib/features/location/location_service.dart`：`geolocator` 封裝，權限與 `getCurrentPosition`
- `lib/features/explore/`：`ExplorePage`（`flutter_map` + OSM）、`map_records_provider`、`MapRecordCard`
- `Record` 模型新增 `latitude`、`longitude`、`hasLocation`
- `RecordRepository.fetchMapRecords(bbox, category, limit)`、`createRecord` 帶座標
- `create_record_notifier.submit()` 上傳前讀 GPS，成功後 `invalidateMapRecords`

## API

- `POST /records`：選填 `latitude`、`longitude`（須同時有值或皆 null）
- `GET /records/map`：僅有座標紀錄；query `bbox=min_lng,min_lat,max_lng,max_lat`

## 依賴

- `geolocator`（定位）
- 既有 `flutter_map`、`latlong2`

## 權限

- Android：`ACCESS_FINE_LOCATION`、`ACCESS_COARSE_LOCATION`
- iOS：`NSLocationWhenInUseUsageDescription`
