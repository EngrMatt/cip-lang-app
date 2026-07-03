## ADDED Requirements

### Requirement: 拍照後裁剪

系統 SHALL 在使用者拍照後進入裁剪介面，確認後才保存照片。

#### Scenario: 裁剪確認

- **WHEN** 使用者完成拍照並確認裁剪
- **THEN** 系統保存裁剪後照片供上傳使用

#### Scenario: 取消裁剪

- **WHEN** 使用者取消裁剪
- **THEN** 系統不保存該次照片
