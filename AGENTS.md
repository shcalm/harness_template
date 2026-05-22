# Agent 工程治理规范

<!-- AGENTS-META
role: code agent governance context
version: 1.0
required_sections: 文件契约, 文档生命周期, 核心原则, 统一 ID, 工作模式, 质量 Gate, 任务与日志, 文档更新时机, 问题分析与解决, 模板校验
-->

目标：让 code agent 在长任务和多次续会中稳定恢复上下文、执行任务、留下可复验证据。

## 0. 文件契约

| 文件 | 角色 | DOC-CONTRACT |
| :--- | :--- | :--- |
| `AGENTS.md` / `CLAUDE.md` | 治理上下文 | 无 |
| `PROBLEM_SOLVING.md` | 调试流程参考 | 无 |
| `PRD.md` / `DESIGN.md` / `TASKS.md` / `TEST_REPORT.md` | 项目事实源 | 必须，编辑前先读 |

开发阶段后，正文中模板示例段与未填占位行已被覆盖或删除，`DOC-CONTRACT` 保留。

## 1. 文档生命周期

项目从 **Brainstorm 阶段** 起步，经一次 **生成动作** 进入 **开发阶段**，此后不再切换。

阶段判定（O(1)，读 `PRD.md` §1 第一格）：

| `PRD.md` §1「项目名称」 | 阶段 |
| :--- | :--- |
| `[项目名称]`（占位） | Brainstorm |
| 真实项目名 | 开发 |

## 2. 核心原则

* `PRD`=需求/验收，`DESIGN`=设计/恢复，`TASKS`=当前状态，`TEST_REPORT`=质量证据。
* 证据先于结论：命令、日志、测试、代码引用或人工观察。
* 全路径验证高于局部正确：关闭任务必须覆盖对应 `AC-ID`。
* 最小改动、可回滚、可审计；关键决策记录替代方案/原因/代价。
* 每次结束留下当前焦点、下一步动作、阻塞、证据路径。

## 3. 统一 ID

| 归属 | ID 前缀 | 含义 |
| :--- | :--- | :--- |
| `PRD.md` | `REQ-NNN` | 需求 |
| `PRD.md` | `AC-NNN` | 端到端验收 |
| `PRD.md` | `FLOW-NNN` | 业务流程 |
| `PRD.md` | `CON-NNN` | 约束/假设 |
| `PRD.md` | `NOGOAL-NNN` | 非目标 |
| `PRD.md` | `Q-NNN` | 待确认问题 |
| `DESIGN.md` | `DEC-NNN` | 技术决策 |
| `DESIGN.md` | `INV-NNN` | 不变量 |
| `DESIGN.md` | `CONTRACT-NNN` | 接口契约 |
| `DESIGN.md` | `OBS-NNN` | 可观测信号 |
| `DESIGN.md` | `BUG-NNN` | 失败模式 |
| `DESIGN.md` | `DEBT-NNN` | 技术债 |
| `TASKS.md` | `TASK-NNN[.M]` | 任务（支持子级） |
| `TEST_REPORT.md` | `TEST-NNN` | 测试 |

命名规约：

* R1 前缀大写 + 三位编号：`PREFIX-NNN`。
* R2 表头列名一律 `<PREFIX>-ID`；禁用驼峰变体。
* R3 一概念一前缀（接口=`CONTRACT-*`，观测=`OBS-*`）。
* R4 子级 ID 只限 `TASK-001.M`。
* R5 新 ID 类型先入此表再使用。

跨文档引用：

* `AC` → `REQ`；`TASK` → `REQ` + `AC`；`TEST` → `TASK` + `AC`。
* `Q-NNN` 在 `PRD.md` §7 定义；`TASKS.md` 阻塞区引用。
* `BUG-NNN` 在 `DESIGN.md` §8 登记；`TASKS.md` 阻塞区与 `TEST_REPORT.md` 缺陷区引用同编号。
* 关闭 `TASK` 前，`TASKS.md` 与 `TEST_REPORT.md` 追溯同一组 `AC-ID`。

## 4. 工作模式

### Brainstorm 阶段

agent 不动项目文档；对话中收集 5 项必收信息：

1. 业务目标与目标用户
2. 核心业务流程（≥1 `FLOW`）
3. ≥1 条 `REQ` + 对应 `AC`
4. 技术栈与运行环境
5. 最小运行/验证命令

齐备后 agent 主动确认"是否生成项目文档？"；缺口写成 `Q-NNN`（仅对话，不入文件）。

### 生成动作（一次性，不可重复）

用户确认后，覆盖式重写 4 份项目文档。每份文档以其 `DOC-CONTRACT` 的 `required_sections` 为骨架，逐节填实。

| 保留 | 覆盖 | 删除 |
| :--- | :--- | :--- |
| `DOC-CONTRACT` 注释块 | 占位行 → 真实内容 | 各文档「最小填写示例」段 |
| 章节标题与编号 | 表头不变，表格行填真值 | 仅含 `[xxx]` 的整行 |
| 表头列名 | PRD §1 项目名 → 真实名 | 用不到的示例 ID 行 |

`init.sh` 在技术栈明确时一并创建，否则在 `TASKS.md` 记 `Q-NNN`。

### 开发阶段

每次会话开始：

1. 读 `TASKS.md`（含 §5 会话心智摘要）：恢复焦点、下一步、心智模型。
2. 读 `PRD` / `DESIGN` / `TEST_REPORT`：对齐目标、设计、证据。
3. 按当前 `TASK-NNN` 执行；新需求→`PRD`，新决策→`DESIGN`，新状态→`TASKS`，新证据→`TEST_REPORT`。

## 5. 质量 Gate

就绪条件 (DoR)：

* 明确的 `REQ-ID/AC-ID`。
* 可执行的下一步动作。
* 预期验证方式。
* 环境恢复步骤可用，或阻塞已记录。

完成条件 (DoD)：

* 改动最小。
* `AC-ID` 已全路径验证，或失败原因已记录。
* `TEST_REPORT.md` 有命令、退出码、证据路径、环境、版本。
* `TASKS.md` 状态更新并留下一步入口。
* 剩余风险有 `BUG-ID` 或后续 `TASK-ID`。

验证记录格式：`1.[Step]->Verify:[Test/Log]`

## 6. 任务与日志

### 6.1 状态词汇

| 类别 | 用在 | 状态集 |
| :--- | :--- | :--- |
| 任务进度 | `TASKS.md` | `[ ]` 待处理 / `[/]` 进行中 / `[x]` 完成 / `[!]` 阻塞 |
| 测试结论 | `TEST_REPORT.md` | 通过 / 失败 / 未执行 / 部分通过 |

跨表一致性：

* 测试 = `失败` → 关联任务标 `[!]`。
* 测试 = `未执行` → 关联任务不可 `[x]`。
* 任务 `[x]` 前提：该任务覆盖的所有 `AC-ID` 在 `TEST_REPORT.md` 结论全 = `通过`。

### 6.2 日志与折叠

* 同时只展开一个当前焦点任务。
* 长日志写 `.log`；文档只写摘要 + 路径。
* 主任务完成后折叠子任务为单行摘要。
* 分类不确定 → 写入 `TASKS.md` 阻塞区并请求确认。

## 7. 文档更新时机

| 变化触发 | 更新位置 |
| :--- | :--- |
| 生成动作完成 | 4 份文档进入增量模式 |
| 需求/验收变化 | `PRD.md` |
| 决策/架构/失败模式 | `DESIGN.md` |
| 任务/阻塞/下一步 | `TASKS.md` |
| 测试结果 | `TEST_REPORT.md` |
| 会话结束/交接 | `TASKS.md` §5 |

测试层级与文档责任：

| 层级 | 时机 | 状态记录 | 证据归档 |
| :--- | :--- | :--- | :--- |
| 单元测试 | 开发期持续 | `TASKS.md` 子任务 `证据/输出` 列 | `TEST_REPORT.md` §4（交付时汇总） |
| 集成/全路径 | 任务完成时 | `TEST_REPORT.md` §3、§5 | `TEST_REPORT.md` |

## 8. 问题分析与解决

遇到 BUG 或系统异常时，参考 `PROBLEM_SOLVING.md`（含完整启用条件、调试方法、退出标准）。单模块且原因明确的简单问题直接处理。

## 9. 模板校验

交付前运行 `scripts/verify_docs.sh`，覆盖三项检查：

1. 章节存在性（按 `DOC-CONTRACT` / `AGENTS-META` 的 `required_sections`）。
2. Harness 版本号（`AGENTS-META.version`）。
3. 跨文档 ID 一致性（链式调用 `scripts/verify_ids.sh`；Brainstorm 阶段自动跳过）。

三项全通过后再进入测试、全路径验证、交接。
