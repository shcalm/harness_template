# Agent 工程治理规范

目标：让 Codex 在长任务和多次续会中稳定恢复上下文、执行任务、留下可复验证据。

## 0. 文件契约

* 每个项目文档顶部都应保留 `DOC-CONTRACT` 注释块。
* `DOC-CONTRACT` 是该文件的永久维护约束，编辑该文件前先读取。
* 进入 Active Project Mode 后，正文可以替换模板示例和占位符，但 `DOC-CONTRACT` 保留。
* `scripts/verify_docs.sh` 检查每个项目文档是否存在 `DOC-CONTRACT`。

## 1. 文档生命周期

本套文件拷贝进新项目时：
* `AGENTS.md`：长期治理规范，保留并持续约束 Agent。
* `PRD.md`、`DESIGN.md`、`TASKS.md`、`TEST_REPORT.md`：种子模板，第一轮项目沟通后由 Agent 填充/替换为真实项目内容。
* 判断模式：大量 `[占位符]`、示例行、示例 `REQ-001/AC-001` = Seed Template Mode；出现真实项目名、真实需求、真实任务、真实验证 = Active Project Mode。
* Seed Template Mode 结束条件：`PRD` 已有真实项目名与至少一条 `REQ/AC`，`DESIGN` 已有环境与恢复步骤，`TASKS` 已有当前焦点任务，`TEST_REPORT` 已有测试矩阵，且 `init.sh/progress.md` 已创建。
* 进入 Active Project Mode 后，上述四份文档就是项目事实源；后续只做增量更新，保留历史事实和证据。

## 2. 核心原则

* 仓库文档是事实源：`PRD`=需求/验收，`DESIGN`=设计/恢复，`TASKS`=当前状态，`TEST_REPORT`=质量证据。
* 证据先于结论：判断、修复、完成声明必须有命令、日志、测试、代码引用或人工观察记录。
* 全路径验证高于局部正确：完成任务必须覆盖对应 `AC-ID`。
* 小步、可回滚、可审计：最小改动；关键决策记录替代方案、原因、代价。
* 降低接力成本：每次结束都留下当前焦点、下一步动作、阻塞、证据路径。

## 3. 统一 ID

使用同一套 ID 串联文档：`REQ-001` 需求，`AC-001` 验收，`TASK-001` 任务，`TEST-001` 验证，`DEC-001` 决策，`BUG-001` 缺陷/阻塞，`Q-001` 待确认问题。

引用规则：
* `AC-ID` 关联 `REQ-ID`。
* `TASK-ID` 关联 `REQ-ID/AC-ID`。
* `TEST-ID` 关联 `TASK-ID/AC-ID`。
* `Q-ID` 记录在 `PRD.md` 的 Open Questions，并在 `TASKS.md` 的阻塞区引用。
* 关闭任务前，`TASKS.md` 与 `TEST_REPORT.md` 追溯到同一组 `AC-ID`。

## 4. 工作模式

### Seed Template Mode

第一轮项目沟通后，Agent 自动完成初始化：
* 填充 `PRD.md`：项目目标、非目标、流程、`REQ-ID`、`AC-ID`。
* 填充 `DESIGN.md`：环境、依赖、构建、运行、架构、关键决策。
* 填充 `TASKS.md`：第一个 `TASK-ID`、当前焦点、下一步动作。
* 填充 `TEST_REPORT.md`：预期测试矩阵；未运行项记录为待验证。
* 创建 `init.sh`：环境检查、依赖检查、最小健康检查/验证入口。
* 创建 `progress.md`：当前目标、最近决策、下一步动作、风险。

`init.sh` 创建条件：技术栈、依赖安装方式、最小验证入口已明确；条件不足时在 `TASKS.md` 记录 `Q-ID`。

### Active Project Mode

每次会话开始：
1. 读 `progress.md`、`TASKS.md`，恢复当前焦点和下一步动作。
2. 读 `PRD.md`、`DESIGN.md`、`TEST_REPORT.md`，对齐目标、设计、证据。
3. 按当前 `TASK-ID` 执行；新需求写 `PRD`，新决策写 `DESIGN`，新状态写 `TASKS`，新证据写 `TEST_REPORT`。

## 5. 质量 Gate

Definition of Ready：
* 有明确 `REQ-ID/AC-ID`。
* 有可执行下一步动作。
* 有预期验证方式。
* 环境恢复步骤可用，或阻塞已记录。

Definition of Done：
* 改动保持最小范围。
* 对应 `AC-ID` 已全路径验证，或失败原因已记录。
* `TEST_REPORT.md` 有命令、退出码、日志/产物路径、环境、版本。
* `TASKS.md` 已更新状态并保留下一步入口。
* 剩余风险有 `BUG-ID` 或后续 `TASK-ID`。

验证记录格式：`1.[Step]->Verify:[Test/Log]`

## 6. 任务与日志

* 状态：`[ ]` 待处理，`[/]` 进行中，`[x]` 完成，`[!]` 阻塞。
* 同一时间只展开一个当前焦点任务。
* 长日志写 `.log` 文件，文档只写摘要和路径。
* 完成主任务后折叠子任务，只保留主任务状态、结果摘要、验证引用。
* 分类不确定时写入 `TASKS.md` Obstacles 并请求确认。

## 7. 文档更新时机

文档更新基于工程状态变化：
* 第一轮初始化后：填充四份项目文档，创建 `init.sh/progress.md`。
* 需求或验收变化后：更新 `PRD.md`。
* 技术决策、架构边界、失败模式变化后：更新 `DESIGN.md`。
* 任务阶段、阻塞、下一步动作变化后：更新 `TASKS.md` 和 `progress.md`。
* 运行测试或全路径验证后：更新 `TEST_REPORT.md`。
* 会话结束或准备交接时：更新 `progress.md`，确保下一次可恢复。

任务未完成时，只更新当前状态、假设、证据和下一步动作；完成结论只在通过 DoD 后写入。

## 8. 模板校验

交付前运行 `scripts/verify_docs.sh`，再进入测试、全路径验证和交接。
