# OpenSpec 工作流指南（AI Agent）

本文件說明如何在 `cip-lang-app` 專案中使用 OpenSpec OPSX 工作流與 AI 協作。

## 概覽

OpenSpec 採用 **spec-driven** schema：先寫清楚「要做什麼、為什麼、怎麼做」，再依 tasks 逐步實作。規格是單一真相來源，程式碼變更應對應到 spec 與 change artifacts。

```
探索想法 → 提案 → 規格化 → 設計 → 任務拆解 → 實作 → 歸檔
   ↓         ↓        ↓        ↓         ↓        ↓       ↓
/explore  /propose   specs   design    tasks    /apply  /archive
```

## 目錄結構

```text
openspec/
├── config.yaml          # schema 與 AI context 設定
├── project.md           # 專案背景、技術堆疊、慣例
├── AGENTS.md            # 本文件
├── specs/               # 已歸檔的系統規格（主規格庫）
└── changes/
    └── <change-name>/   # 進行中的變更
        ├── .openspec.yaml
        ├── proposal.md  # 為什麼做、做什麼、影響範圍
        ├── design.md    # 技術決策與架構
        ├── tasks.md     # 可勾選的實作清單
        └── specs/       # 本變更的 delta specs
            └── <capability>/
                └── spec.md
```

## Cursor 指令

| 指令 | 用途 | 何時使用 |
|------|------|----------|
| `/opsx:explore` | 探索模式：思考、調查、比較方案 | 想法還不清楚、需要釐清需求時 |
| `/opsx:propose` | 建立變更並產生所有 artifacts | 需求明確，準備開始規劃時 |
| `/opsx:apply` | 依 tasks.md 逐步實作 | artifacts 完成後 |
| `/opsx:sync` | 將 delta specs 同步至主 specs | 變更進行中需更新主規格時 |
| `/opsx:archive` | 歸檔完成的變更 | 所有 tasks 完成後 |

## 與 AI 協作的建議流程

### 1. 填寫專案 context

確保 `openspec/project.md` 與 `openspec/config.yaml` 反映正確的技術堆疊與慣例。AI 在建立 proposal、design、tasks 時會自動讀取這些內容。

### 2. 探索（可選）

```
/opsx:explore 我想用 Riverpod 還是 Bloc 管理錄音狀態？
```

探索模式**只思考、不寫程式碼**。適合比較方案、畫架構圖、釐清邊界。

### 3. 建立變更提案

```
/opsx:propose mvp-bootstrap
```

或描述需求：

```
我想建立 Flutter MVP，包含語料列表、錄音、拍照與上傳。請建立 OpenSpec change proposal。
```

AI 會依序產生：
1. **proposal.md** — Why / What / Capabilities / Non-goals
2. **specs/** — 各 capability 的行為規格（Given-When-Then）
3. **design.md** — 架構決策、套件選型、API 整合
4. **tasks.md** — 可勾選的實作步驟

### 4. 審閱與調整

實作前請審閱 artifacts。若有遺漏或錯誤，直接告訴 AI 更新對應檔案，例如：

- 「Non-goals 加上離線模式」
- 「design 改用 go_router 做路由」
- 「tasks 拆細一點」

### 5. 實作

```
/opsx:apply mvp-bootstrap
```

AI 會：
- 讀取 proposal、specs、design、tasks
- 依序完成 pending tasks
- 每完成一項將 `- [ ]` 改為 `- [x]`
- 遇到設計問題會暫停並詢問

### 6. 歸檔

```
/opsx:archive mvp-bootstrap
```

將完成的變更歸檔，delta specs 合併至 `openspec/specs/`，成為系統的長期規格。

## Artifact 說明

### proposal.md

回答「為什麼要做」與「做什麼」。包含 Capabilities（新增/修改的能力）與 Non-goals（明確不做的事）。

### specs/<capability>/spec.md

以 **Requirement + Scenario** 格式描述行為：

```markdown
### Requirement: 語料列表顯示
系統 SHALL 顯示所有已上傳語料的基本資訊。

#### Scenario: 成功載入列表
- **WHEN** 使用者開啟語料列表頁
- **THEN** 顯示每筆語料的標題、類型與建立日期
```

### design.md

技術決策紀錄：架構、套件、API 整合、錯誤處理、平台權限等。說明「怎麼做」與「為什麼這樣選」。

### tasks.md

實作清單，格式為 Markdown checkbox。`/opsx:apply` 依此逐項執行。

## 重要原則

1. **先規格、後程式碼** — 避免直接開寫功能而沒有對應 spec
2. **Non-goals 同樣重要** — 明確排除範圍，防止 scope creep
3. **保持 artifacts 同步** — 實作中發現設計問題，應回頭更新 design 或 spec
4. **一個 change 一個主題** — 大功能可拆成多個 change，方便 review
5. **參考姊妹專案** — `cip-lang-web` 的 API 與 Record 模型為整合依據

## CLI 參考

```bash
openspec list                    # 列出進行中的 changes
openspec status --change <name>  # 查看 artifact 完成狀態
openspec new change <name>       # 手動建立 change 目錄
```

## 常見情境

| 情境 | 建議做法 |
|------|----------|
| 想法還很模糊 | `/opsx:explore` |
| 需求已清楚 | `/opsx:propose <name>` |
| 只要改 spec 不寫 code | 直接請 AI 更新 change 內的 artifact |
| 後端 API 還沒好 | 在 design 註明 mock 策略，或先在 `cip-lang-web` 開 change |
| 實作到一半要暫停 | tasks 的 checkbox 會保留進度，下次 `/opsx:apply` 繼續 |
