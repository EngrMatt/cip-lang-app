## ADDED Requirements

### Requirement: 播放波形顯示

系統 SHALL 在詳細頁播放錄音時顯示波形並支援 seek；波形載入失敗時仍可播放。

#### Scenario: 播放波形

- **WHEN** 語料含 audio_url 且波形載入成功
- **THEN** 系統顯示可 seek 的播放波形
