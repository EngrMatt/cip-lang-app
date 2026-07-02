Field Language App MVP 規格書（Flutter App）


版本：v1.0


本文件定義田野語料收集 App MVP 範圍，提供 Flutter 開發與 OpenSpec 使用。

本階段聚焦於手機端語料收集流程，不包含 AI、登入驗證、離線同步等功能。


產品目標

讓田野調查人員透過手機快速完成語料蒐集工作，包含錄音、拍照、填寫資訊與上傳。

MVP 功能清單



1. 語料列表頁

- 顯示所有語料紀錄

- 顯示標題、類型、建立日期

- 點擊查看詳細內容

- 提供新增語料按鈕



2. 新增語料頁

- 語料標題（必填）

- 語料類型（必填）

- 備註（選填）



3. 錄音功能

- 開始錄音

- 停止錄音

- 重新錄音

- 預覽錄音



4. 拍照功能

- 開啟相機

- 拍照

- 預覽照片

- 刪除照片



5. 上傳功能

- 上傳基本資料

- 上傳錄音

- 上傳照片



6. 語料詳細頁

- 顯示基本資訊

- 顯示照片

- 錄音播放器



User Story



US-001

身為田野調查員

我希望建立新的語料紀錄

以便保存採集內容



US-002

身為田野調查員

我希望錄製訪談內容

以便保存語音資料



US-003

身為田野調查員

我希望拍攝現場照片

以便保留現場資訊



US-004

身為田野調查員

我希望上傳資料

以便集中管理



畫面規劃



Screen 01

語料列表頁



Screen 02

新增語料頁



Screen 03

錄音介面



Screen 04

照片管理



Screen 05

語料詳細頁



API 整合



GET /records



POST /records



GET /records/{id}



POST /upload/audio



POST /upload/image



技術規劃



Framework

Flutter 3.x



State Management

Riverpod



Networking

Dio



Audio Record

record



Audio Player

just_audio



Camera

image_picker



Storage

AWS S3 (透過 API 上傳)



Phase 2



- 帳號登入

- GPS定位

- 離線同步

- AI逐字稿

- AI摘要分析

- 分享功能

- 匯出功能

測試
