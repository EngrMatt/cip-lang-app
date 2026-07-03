## 實作

- 錄音：`RecorderController` + `AudioWaveforms`，失敗時 fallback `AudioRecorderService`
- 播放：`PlayerController` + `AudioFileWaveforms`，與 `just_audio` 並用
- 權限流程不變
