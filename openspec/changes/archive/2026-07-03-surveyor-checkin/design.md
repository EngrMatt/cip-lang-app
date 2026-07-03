## 架構

- `lib/features/onboarding/`：CheckinPage、SurveyorProfile、SurveyorStorage、Riverpod provider
- `go_router` redirect 依 profile 是否存在
- `create_record_notifier.submit()` 呼叫 `mergeNoteWithSurveyorPrefix`

## 依賴

- `shared_preferences`
