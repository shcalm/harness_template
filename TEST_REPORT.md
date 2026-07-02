# TEST_REPORT 模板：质量证据与交付审计

<!-- DOC-CONTRACT: TEST_REPORT.md
role: 质量证据与交付审计事实源
status: permanent
read_policy: read before editing this file
required_sections: 交付结论, 验证环境, 测试矩阵, 单元与局部验证, 全路径业务验证, 缺陷与剩余风险, 复现方式, 审计清单
ids: TEST-*, AC-*, TASK-*, BUG-*
rules:
  - 每条测试记录必须有 TEST-ID
  - 每条 TEST-ID 必须关联 AC-ID 和 TASK-ID
  - 全路径验证必须对应至少一条 full-path 记录
  - 设计阶段的验证计划统一写入 TASKS.md；本文件只记录实际执行过的验证，或交付审计明确需要标记为未执行的验证
-->

本文件记录可复验的质量证据。结论必须来自命令、日志、产物或人工观察记录。

设计阶段在 `TASKS.md` 中预留的 `TEST-ID`，只有在验证实际执行后，才在本文件形成正式记录。

## 1. 交付结论

| 字段 | 内容 |
| :--- | :--- |
| 结论 | `[通过 / 部分通过 / 失败 / 未验证]` |
| 日期 | `YYYY-MM-DD` |
| 分支 | `[branch]` |
| Commit | `[commit hash；未提交则写工作区状态]` |
| Dirty 状态 | `[clean / dirty，并列出相关文件]` |
| 覆盖范围 | `[覆盖的 REQ/AC 列表]` |
| 主要风险 | `[无 / BUG-ID / 风险摘要]` |

## 2. 验证环境

| 项 | 值 | 获取命令 |
| :--- | :--- | :--- |
| OS | `[版本]` | `uname -a` |
| Runtime | `[版本]` | `[命令]` |
| 依赖版本 | `[关键依赖]` | `[命令]` |
| 配置 | `[关键配置名和用途]` | `[命令]` |

## 3. 测试矩阵

> 本节只记录已实际执行的验证，或交付时需要明确声明“未执行”原因的验证。纯计划项不进入本矩阵。

| TEST-ID | 类型 | 关联 TASK | 覆盖 AC | 命令/操作 | 退出码 | 证据路径 | 结论 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| TEST-001 | `[unit / integration / full-path / manual]` | TASK-001 | AC-001 | `[命令或人工步骤]` | `[0/非0/人工]` | `[logs/xxx.log / screenshot / artifact]` | `[通过/失败/未执行]` |
| TEST-002 | full-path | TASK-001 | AC-001 | `[端到端命令或人工步骤]` | `[0/非0/人工]` | `[logs/full_path.log / screenshot / artifact]` | `[通过/失败/未执行]` |

## 4. 单元与局部验证

> 本节是交付时的汇总摘要，从 `TASKS.md` 各子任务的 `证据/输出` 列归纳而来，不用于开发过程实时跟踪。开发过程中单元测试的失败状态和验证计划记录在 `TASKS.md` 子任务行。

格式：

```text
1.[Step]->Verify:[Test/Log]
```

记录：

```text
1.[步骤]->Verify:[[命令], [日志路径]]
```

关键输出摘要：

```text
[保留 50 行以内关键输出；完整日志写路径]
```

## 5. 全路径业务验证

| AC-ID | 场景 | 前置条件 | 步骤 | 观察结果 | 证据 | 结论 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| AC-001 | `[来自 PRD 的场景]` | `[环境/数据/服务状态]` | `1. ... 2. ...` | `[实际观察]` | TEST-002 | `[通过/失败]` |

通过标准：
* 实际观察必须匹配 `PRD.md` 对应 `AC-ID` 的预期结果。
* 如果只通过局部测试，结论写“部分通过”。
* 如果验证依赖人工观察，必须写观察时间、观察对象和判定依据。

## 6. 缺陷与剩余风险

| BUG-ID | 关联 AC/TASK | 严重级别 | 现象 | 影响 | 证据 | 后续动作 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| BUG-001 | AC-001 / TASK-001 | `[P0/P1/P2]` | `[缺陷现象]` | `[影响范围]` | `[日志/测试]` | TASK-002 |

## 7. 复现方式

从干净环境复现本报告结论：

1. 切换版本：`[git checkout ...]`
2. 初始化环境：`./init.sh`
3. 启动服务：`[命令]`
4. 执行验证：`[命令]`
5. 对照证据：`[日志路径 / 产物路径]`

## 8. 审计清单

| Gate | 状态 | 证据 |
| :--- | :--- | :--- |
| `PRD` 有对应 `REQ/AC` | `[通过/失败]` | `[文件行号或 ID]` |
| `DESIGN` 已记录关键决策 | `[通过/失败]` | DEC-001 |
| `TASKS` 已更新当前状态 | `[通过/失败]` | TASK-001 |
| 单元/局部验证已执行 | `[通过/失败]` | TEST-001 |
| 全路径验证已执行 | `[通过/失败]` | TEST-002 |
| 已知风险已记录 | `[通过/失败]` | BUG-001 / 无 |

## 9. 最小填写示例

| TEST-ID | 类型 | 关联 TASK | 覆盖 AC | 命令/操作 | 退出码 | 证据路径 | 结论 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| TEST-001 | unit | TASK-001 | AC-001 | `pytest tests/test_upload.py::test_upload_success -q` | 0 | `logs/test_upload_success.log` | 通过 |
| TEST-002 | full-path | TASK-001 | AC-001 | `scripts/e2e_upload.sh sample.pdf` | 0 | `logs/e2e_upload.log` | 通过 |

```text
1.上传 2MB PDF->Verify:[pytest tests/test_upload.py::test_upload_success -q, logs/test_upload_success.log]
2.完成上传全路径->Verify:[scripts/e2e_upload.sh sample.pdf, logs/e2e_upload.log]
```
