## ADDED Requirements

### Requirement: 錄音波形顯示

系統 SHALL 在錄音過程中顯示即時音訊波形；若波形元件不可用則 fallback 至圖示與計時 UI。

#### Scenario: 錄音中顯示波形

- **WHEN** 使用者開始錄音且裝置支援波形
- **THEN** 系統顯示即時波形
