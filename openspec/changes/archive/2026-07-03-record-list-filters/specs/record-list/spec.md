## MODIFIED Requirements

### Requirement: 顯示語料列表

系統 SHALL 以列表形式顯示語料紀錄，並支援依類型與媒體狀態篩選。

#### Scenario: 依類型篩選

- **WHEN** 使用者選擇類型 Filter Chip
- **THEN** 系統以 `category` 參數重新載入列表

#### Scenario: 依媒體狀態篩選

- **WHEN** 使用者選擇「含錄音」「含照片」或「僅基本資料」
- **THEN** 系統在前端依 `audio_url` / `image_url` 篩選已載入項目
