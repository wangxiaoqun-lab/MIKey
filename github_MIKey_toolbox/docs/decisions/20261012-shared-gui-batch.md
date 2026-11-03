# 共用 GUI 计算函数的无图形接口

日期：2026-10-12。

采用 `MIKey_run(cfg)` → `MIKeyBatchState` → `MIKey` 内的既有 `executeStage` 和处理函数。状态对象仅提供原计算函数读取的 `UserData.<field>.Value`，不创建隐藏 uifigure，不复制整套算法。

公开参数与 GUI 控件在 `MIKey_parameter_map.m` 统一映射。MAT/JSON 配置拒绝未知字段和任意步骤表达式，步序保持用户提供顺序。图形默认离屏，结束时恢复调用前路径、目录和 figure visibility，并释放本次图形对象。

服务器默认严格校验前置文件，计算异常保留原始 identifier/stack；不把内部捕获错误后的“完成”文本当作成功。无任何已知输出的步骤判为失败。`failFast=false` 可记录后继续，但最终仍抛出任务失败，供调度系统识别。

按后续用户要求支持 .nii、T2w 的无 session / ses-* 层级以及独立 session/task/run 筛选；fieldmap 保留现有约定。群组网络可指定用户路径，或按 AMCP 网络选项解析，不要求固定旧文件名。保留现有按输出存在跳过的主要行为，文档明确参数改变需隔离重新运行。

目标工具包不是 Git 仓库，因此本次不初始化或提交，保留原文件副本。运行环境记录 MATLAB/SPM 版本与 MATLAB 源码 SHA-256 清单；正式服务器实验仍应使用固定 commit 并记录 RUN_REPORT。

不同 session/task/run 范围的群组和拼接输出使用独立 selection 子目录；生物学样本单位始终为真实 subject，同一 subject 的所选 runs/sessions 先平均。新增并行开关默认关闭，避免服务器隐式启动 worker。
