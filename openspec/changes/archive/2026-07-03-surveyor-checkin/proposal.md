## Why

田野調查需追蹤調查員身分，並在上傳語料時自動帶入調查員資訊，無需後端 API 變更。

## What Changes

- 新增調查員簽到頁（姓名必填、地區選填）
- `shared_preferences` 持久化 `SurveyorProfile`
- 路由：無 profile 導向 `/checkin`，有 profile 進 `/records`
- 列表 AppBar「切換調查員」
- 上傳時將 `[調查員: 姓名 | 地區]` 前綴注入 `note`

## Capabilities

### New Capabilities

- `surveyor-checkin`：虛擬調查員簽到與 note 注入

### Modified Capabilities

（無）

## Non-goals

- 後端帳號登入
- 多裝置 profile 同步
