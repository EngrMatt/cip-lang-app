## ADDED Requirements

### Requirement: 錄音控制

系統 SHALL 提供開始、停止與重新錄音功能。

#### Scenario: 開始錄音

- **WHEN** 使用者點擊開始錄音且已授予麥克風權限
- **THEN** 系統開始錄製音訊並顯示錄音中狀態

#### Scenario: 停止錄音

- **WHEN** 使用者點擊停止錄音
- **THEN** 系統停止錄製並保存錄音檔至暫存位置

#### Scenario: 重新錄音

- **WHEN** 使用者點擊重新錄音
- **THEN** 系統捨棄目前錄音並允許重新開始錄製

### Requirement: 錄音預覽播放

系統 SHALL 允許使用者在提交前預覽錄音內容。

#### Scenario: 播放預覽

- **WHEN** 使用者點擊播放預覽
- **THEN** 系統播放已錄製的音訊

### Requirement: 麥克風權限

系統 SHALL 在錄音前檢查並請求麥克風權限。

#### Scenario: 權限未授予

- **WHEN** 使用者尚未授予麥克風權限
- **THEN** 系統引導使用者授權或顯示權限說明
