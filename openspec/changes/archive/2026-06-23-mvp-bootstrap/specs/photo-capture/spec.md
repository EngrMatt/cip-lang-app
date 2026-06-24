## ADDED Requirements

### Requirement: 拍照功能

系統 SHALL 允許使用者透過相機拍攝現場照片。

#### Scenario: 開啟相機拍照

- **WHEN** 使用者點擊拍照且已授予相機權限
- **THEN** 系統開啟相機並允許拍攝照片

#### Scenario: 拍照完成

- **WHEN** 使用者完成拍照
- **THEN** 系統保存照片至暫存位置並顯示預覽

### Requirement: 照片預覽與刪除

系統 SHALL 允許使用者預覽與刪除已拍攝的照片。

#### Scenario: 預覽照片

- **WHEN** 使用者查看已拍攝照片
- **THEN** 系統顯示照片預覽

#### Scenario: 刪除照片

- **WHEN** 使用者點擊刪除照片
- **THEN** 系統移除暫存照片並允許重新拍攝

### Requirement: 相機權限

系統 SHALL 在拍照前檢查並請求相機權限。

#### Scenario: 權限未授予

- **WHEN** 使用者尚未授予相機權限
- **THEN** 系統引導使用者授權或顯示權限說明
