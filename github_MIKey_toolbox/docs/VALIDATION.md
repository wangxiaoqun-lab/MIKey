# MIKey 脚本接口验证记录

日期：2026-10-12（Asia/Shanghai）。仅本机合成数据测试；未提交服务器作业，未处理用户研究数据。

## 环境与启动命令

- Windows 64 位；MATLAB `9.4.0.813654 (R2018a)`。
- MATLAB 可执行文件：`D:/Program Files/MATLAB/R2018a/bin/matlab.exe`。
- SPM12：`D:/Program Files/MATLAB/mytoolbox/spm12`。
- 目标工具包：`K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main`，没有 Git 仓库或 commit。
- 源码记录：本目录 `SOURCE_SHA256.json`；每次实际运行的环境也保存 MATLAB 源码 SHA-256。

主要调用（外层 catch 打印完整堆栈后 `exit(1)`，成功 `exit(0)`）：

```matlab
addpath('K:/toolbox/MIKey_toolbox_main/MIKey_toolbox_main/tests');
result = test_mikey_batch('D:/Program Files/MATLAB/mytoolbox/spm12');
test_mikey_failure_reports('D:/Program Files/MATLAB/mytoolbox/spm12', ...
    result.syntheticDirectory);
```

启动选项：`-wait -nosplash -nodesktop -logfile <log> -r <上述带 try/catch 的命令>`。R2018a 不使用 `-batch`。控制台记录保存在 `validation/20261012/`。

## 已通过

1. MATLAB Code Analyzer 检查新入口及主文件，未发现 PARSE 错误；MISS_HIT 以 MATLAB 2018a 语法检查新增代码、样例和测试通过。未因原文件的风格/性能建议进行无关重构。
2. 配置的 MAT/JSON 导入、嵌套 GUI config、数字/步序校验、未知字段拒绝和禁止步骤表达式求值。
3. 示例数据仅做只读预检查：10 个 BOLD、1 个 T2w；通配筛选及单被试 `sub-01` 均正确。没有对示例数据执行计算。
4. 合成 `5 × 6 × 4 × 48` BOLD 与 `5 × 6 × 4` T2w 的步骤 1，像素值误差 < `1e-4`；仿射空间按因子 2 缩放，48 帧保持。
5. 步骤 2 掩膜输出与预期的逐体素乘积误差 < `1e-4`。
6. 步骤 8 使用非默认 FWHM `[1 2 3]`，执行真实 SPM 平滑，生成期望文件并在日志记录实际参数。
7. 步骤 12 使用真实回归/去趋势/滤波及 SPM 写盘；步骤 13 生成 `2 × 2`、全部元素有限的 Fisher-z FC 矩阵。
8. dry run 不生成 derivatives；已有缩放结果正确跳过；运行后路径、工作目录与 figure visibility 恢复。
9. 缺少步骤 4 前置输入、损坏 NIfTI 均被识别为失败；最终抛出 `MIKey:RunFailed`。
10. 单被试 `[4 13]`：`failFast=true` 只记录第一步失败；false 时记录步骤 4 失败并继续步骤 13 已有输出检查，最终任务仍失败。报告保存原因、堆栈、有效配置、源码清单及最终 failed 状态。
11. 初版按写死的 final_network 文件名检查；后续按用户澄清取消此限制，改为检查实际选择的 AMCP/用户网络。
12. Slurm/PBS 示例通过 Git Bash `bash -n`，文件为 LF 换行；没有实际执行 sbatch/qsub。

成功标记：`MIKEY_CONFIG_PASS`、`MIKEY_SOURCE_PASS`、`MIKEY_SMOKE_PASS`、`MIKEY_FINAL_CHECK_PASS`、`MIKEY_FAILURE_REPORTS_PASS`。

合成数据一次测试中的步骤耗时（不是服务器性能基准）：

|步骤|秒数|
|---|---:|
|1 首次缩放|2.65|
|1 已有输出跳过|0.37|
|2 掩膜|1.52|
|8 平滑|4.19|
|12 回归|1.76|
|13 FC|0.46|

## 验证期间暴露的问题与修复

第一次端到端测试的有效计算通过，但损坏输入测试提前得到错误的 preflight 结果：原 `dir(fullfile(bidsPath,'sub-01'))` 实际列出被试目录内部条目。增加统一 `MIKey_subjects`，先在 BIDS 根目录列出 `sub-*` 再匹配筛选；再次测试全部通过。该问题会影响单被试服务器作业，已覆盖预检查与真实单被试执行。

其他修复：GUI 配置 save/load 嵌套不一致和 nonexistent bandpass 控件、先验网络下拉映射、GUI 平滑字符串被忽略、回归默认参数 `nargin` 偏差、TR 回退未使用用户值、组织分割输出变量及脆弱路径拼接。组织分割不再删除目录下所有 MAT 文件，保留参数以便复现。

## 尚未验证与已知限制

没有真实采集数据的 fieldmap/时序/头动/配准/标准化、噪声 PCA 与群组策略评估、个体分区、组织分割的端到端科学验证。步骤 3–7、9–11、14–17 的脚本 dispatch 与语法已检查，但不能据此声称其科学结果已验证。

后续已支持用户/AMCP 网络路径以及 session 层级和独立 task/run 筛选。仍未支持压缩 NIfTI 或完整 BIDS 自动验证。部分旧计算按文件存在跳过，不能检测旧结果是否对应新参数。GUI 已进行离屏创建与新控件/统一参数映射检查；保存/加载文件弹窗没有自动操作测试，底层配置导入及脚本计算已验证。

修改前副本位于 `backups/20261012-headless/`。没有创建 commit，正式服务器实验应从后续固定 commit 的代码副本运行并写 RUN_REPORT。

## 后续更新：用户模板与 session/task/run 筛选

用户澄清 AMCP_temp 中已有可用网络，固定 final_network 文件名不是必需。已将五处写死路径替换为统一模板解析：显式 groupNetworkPath → Use Custom 网络 → Network 下拉对应 AMCP 网络。预检查仅验证选中模板。GUI 新增 Group Network 输入与浏览按钮。

GUI 顶部新增 Ses/Task/Run；配置新增 sessionFilter/taskFilter/runFilter。支持 subject/session 目录、精确值、通配符、逗号列表、none 和可选 entity 前缀。任务/run 筛选作用于功能扫描，session 作用于数据及衍生目录；缺少 session T2w 时复用 subject-level T2w。

新增测试与结果：

- `test_mikey_batch`：无 session 旧流程回归通过（1/2/8/12/13）；`MIKEY_SMOKE_PASS`。
- `test_mikey_gui_filters`：实际 GUI 离屏创建、筛选和模板字段、配置映射与 batch-state 一致；`MIKEY_GUI_FILTERS_PASS`。
- `test_mikey_bids_filters`：2 subjects × 2 sessions × 2 tasks × 2 runs，另有无 session/无 run 数据；仅选中 sub-01/ses-baseline/task-rest/run-02 被实际缩放，其余扫描无输出；共享解剖、列表选择、none、无匹配、范围隔离和配置导入通过。自定义 user_network.nii 实际执行分区 15/16；`MIKEY_BIDS_FILTERS_PASS`。
- `test_mikey_group_selection`：每个 session 放置所有 task/run 的回归结果，群组分析仅读取选中 4 runs（不是全部 16）；个体差异校正每个 subject 平均 2 selected runs，最终 n_subjects=2（不是 4 sessions）；`MIKEY_GROUP_SELECTION_PASS`。
- 拼接验证通过，记录在 `mikey-concat-selection.log`：实际生成单 run 的 session 拼接文件及 selection 子目录，并通过既有 valid_runs 元数据核对只拼接 1 run；MIKEY_CONCATENATED_SELECTION_PASS。更新后的全部 MIKey 根目录函数 MATLAB checkcode 无 PARSE 错误；MIKEY_UPDATED_CHECKCODE_PASS。

验证期间还修复了单次迭代进度图的相同坐标范围/重复 bar X 值问题，未改变分区迭代计算。新增 parcellationUseParallel 开关（GUI/脚本），默认 false；true 时需并行 Toolbox/worker 资源。Windows 测试遇到 SPM MEX 长路径写盘限制，改用短的 `C:/MIKeyTest/<unique>/` 合成目录，未改写业务输出命名约定。

这些是执行、筛选、参数路由及文件生成检查；小型合成数据产生的少体素网络和 Dice NaN 不构成真实科学性能验证，后续仍需真实采集条件的配准、分区/组织分割质量与策略有效性验证。更新日志保存于 `validation/20261012/`。

## 后续更新：界面排版与自定义 PC 候选

GUI 新建独立控件构建函数，兼容 R2018a，以三栏画布和水平/垂直滚动条保证缩小窗口后仍可访问完整参数。插值 0–7 说明采用四行灰色文字；每个复选框显式设置完整 Text，避免 20 像素控件保留默认 Check Box 文字造成遮挡。默认、自定义模板/label 的文字同步展开。

步骤 9/10/12 的标题分别改为 Non-brain Noise PCs Estimation、Noise Regression Strategy Estimation、Final Noise Regression Strategy。步骤 15 GUI 为单个正整数 ROI Num，默认 100；脚本原 clustROINums 多值接口保留。灰色说明表示全脑分为 N 个空间 ROI，并指出 k-means 不保证严格等体积。

`test_mikey_ui_layout` 已通过实际 MATLAB 控件验证：全部自定义控件展开后，所有画布控件位于边界内，任意两可见控件的矩形不重叠；980×680 窗口的两轴滚动工作；GUI/配置/batch state 的新参数一致；MIKEY_UI_LAYOUT_PASS。

`test_mikey_pc_strategies` 在两个合成 runs（80/64 帧、各 6 可用 PCs）实际执行步骤 10/11/12：候选 0/1/3 被记录，第二个 run 改为 0/2/3 后重新估计，相同候选再运行正确跳过；群组比较仅采用共同 0/3，矩阵为 2×3，标签为 No regress、12rp、12rp+3；正式回归生成两个期望 NIfTI。默认范围、超界/非法 PC 输入、配置导入和旧结果读取也通过；MIKEY_PC_STRATEGIES_PASS。

新增结果以 pc_configs 记录真实数量；群组不再根据 MAT 字段总数推断 20 步长，避免新元数据或自定义数量导致错标。正式回归读取所选数量；未回归基线不增加头动/PC 项。旧接口/输出文件名保持兼容。

computer-use helper 在初始化重试后可导入，但 list_apps 在重试和 kernel reset 后仍三次返回 `computer-use request timed out: list_apps`。因此未进行像素级截图核验，未使用其他 Windows UI 自动化方式绕过；实际 GUI 创建、控件矩形和缩放/滚动检查已通过。仅终止本任务创建的 Layout Preview MATLAB 进程，未关闭用户其他应用。

测试使用独立合成临时目录；原研究数据、附带 demo 数据与业务 Git 历史未改动。原 MIKey 主文件备份在 `backups/20261012-ui-pc-strategies/`。


## 2026-10-12 update: compressed inputs and modality-specific masks

This update supersedes the earlier .nii-only input and generic-mask limitations. Raw BOLD, T2w and four-component fieldmap images can be .nii or .nii.gz. Step 2 uses *_desc-boldbrain_mask for functional data and *_desc-anatbrain_mask for anatomy; Step 9 shares the functional mask. Both mask formats are accepted, with legacy names supported as a fallback. GUI layout remains the original three columns.

The first actual synthetic run passed scaling (6 images), modality-specific masking (2 images), and Step 9 (12 frames, 11 PCs), including byte-for-byte preservation of compressed sources. Final regression evidence is in validation/20261012/mikey-nifti-mask-final.log and the corresponding task record. Source hashes are refreshed after validation. This verifies execution/routing, not real-acquisition scientific validity.


## 2026-10-13: BOLD time-point filtering and GUI controls

Header-only .nii/.nii.gz filtering passed the strict T < N boundary, invalid values, actual selected scaling and group-estimation checks. Live GUI callback tests passed Pause/Resume (no output progress while paused), Stop (one output retained, next step absent) and restarting a new run without closing MATLAB. Existing layout, configuration/filter mapping and Step 2/3 diagnostics passed. Root Code Analyzer and changed-file MATLAB 2018a syntax checks passed. Evidence: validation/20261013/.

GUI control is cooperative; native SPM/MEX calls must return before responding at a checkpoint. The GUI test launcher's final status was 1 despite all PASS markers and a saved result MAT; no MATLAB error stack was logged. The discrepancy is recorded in tasks/20261013-mikey-timepoints-controls.md. Synthetic tests do not establish real-acquisition scientific validity or immediate interruption inside a native function.


## 2026-10-14: BIDS derivative image naming

Primary image names now place entities before the final imaging suffix; producer/consumer paths, SPM prefixes, 4D scan expansion and motion-file lookup share that contract. Legacy input paths remain readable. Anatomy, fieldmap components, boldref and dseg outputs retain their data-type semantics; dataset and image metadata are written without overwriting existing sidecars.

Real-SPM synthetic stages 1/2/8/12/13 passed. Filename/metadata tests, copy-only SPM routing tests for 4-7, Code Analyzer and MATLAB 2018a parsing passed. Compressed-input stages 1/2/9 passed. A combined later GUI run suffered a native MATLAB access violation, so that combined suite is not reported as passing. A fresh isolated run passed GUI/diagnostic assertions but its outer launcher returned 1 without a MATLAB error stack; this remains a limitation. The final metadata-only process passed with exit 0. See tasks/20261014-mikey-bids-naming.md and validation/20261014/ for exact scope, logs and failures.

No official complete BIDS Validator run or real-acquisition scientific validation was performed. Custom statistic/density maps and analysis caches remain auxiliary MIKey work products. No raw/demo images, GUI layout or Git history were changed.


## 2026-10-14: responsive Stage 1 run controls

Stage 1 now yields between bounded copy/gzip transfers and BOLD volume reads/writes, rather than waiting for a whole 4D run. Incomplete outputs are removed on cancellation. Real-SPM data/geometry/copy tests and stages 1/2/8/12/13 passed. GUI callback tests passed Pause/Resume within the first run, Stop before publication, no subsequent selected step and restarting without exiting MATLAB. The GUI launcher's exit status was 1 despite PASS markers; the I/O/smoke launcher exited 0. A long-timer prototype failed and was removed. Event-level testing in nodesktop mode was blocked by MATLAB Connector; desktop retry status is in the task record. See tasks/20261014-mikey-responsive-controls.md and validation/20261014-responsive-controls/ for evidence and limitations.

The final desktop test passed execution-button UI event dispatch plus mid-run control-handler assertions (MIKEY_RESPONSIVE_UI_DESKTOP_PASS); root native Code Analyzer passed (MIKEY_RESPONSIVE_CODE_ANALYZER_PASS). Pause/Resume/Stop physical pointer-click verification and inspection of the user's existing window remain unavailable. The desktop launcher again returned 1 after all PASS markers, without a MATLAB error stack. Details and failed harness attempts are preserved in the task record.


## 2026-10-15: registration failure gates

Stages 6/7 now perform mandatory world-space pre/post geometry and foreground checks, recheck cached outputs, check BOLD counts/spatial grids, and stop the selected GUI/script pipeline on failure even when failFast=false. Stage 6 estimates on a private T2w copy; failed candidates are retained when possible. No automatic header repair or optimizer change was introduced.

Real-SPM synthetic geometry tests passed (launcher exit 0), and changed-file MATLAB 2018a static parsing passed. Dispatch and GUI callback assertions passed, including full-run stopping with failFast=false and restored controls. The subsequent naming regression stalled after Starting Coregistration and was terminated; native Code Analyzer was not reached. Neither is reported as passing. The combined launcher returned 1 after this deliberate test-process termination. Earlier startup stalls and a corrected harness parser conflict are preserved; this is not yet a complete final launcher result. Current status and exact logs are in tasks/20261015-mikey-registration-qc.md and validation/20261015-registration-qc/.

These are heuristic gates rather than proof of successful scientific registration. Symmetric left/right errors and subtle local failures may escape; unusual FOV/contrast/masks may be rejected. Physical GUI operation remains unverified because Computer Use initialization timed out.


## 2026-10-16: remaining legacy-path checks completed

This follow-up completes the previously pending legacy routing and native Code Analyzer checks. The fresh isolated MATLAB attempt was blocked before test entry by License Manager Error -8; the existing licensed MATLAB instance was used after the user enabled its local AutomationServer. The interface was restored to off and the original MIKey window/session was preserved.

After refreshing cached MIKey/test functions, the exact retained six-image dataset passed with unchanged source hashes, uninstrumented legacy routing passed, and the original GUI-dispatch-to-legacy-routing order passed. Native Code Analyzer passed 38 files with a malformed-code negative control; syntax IDs SYNER/EOLPAR must be checked rather than relying only on PARSE. New phase/path messages were observed at runtime. The GUI component source is unchanged. Full evidence: tasks/20261016-legacy-routing.md and validation/20261016-legacy-routing/final-result.json.

The historical terminated process's original stall remains unassigned; the exact input and order no longer reproduce it. The new startup license error must not be asserted as the old process's proven cause. Expected blank-image failure-injection stderr is retained alongside passing final assertions. These fixtures use COPY-ONLY SPM transformation jobs, not a real-acquisition registration-quality experiment.


## 2026-10-16 real SPM demo Steps 6/7

Completed real SPM12 estimation/reslicing on demo run-01 (480 frames) in an independent copy. Original geometry produced a blank Step 6 result and stopped; added combined initial no-overlap/center-distance gate now rejects it before estimation. After explicit test-only center initialization, Steps 6/7 and all grid checks passed; overlays were inspected. Script/GUI injected Step 6/7 cache failures stop later stages and restore controls. All 26 original inputs and 11 initialized-copy voxel payloads have matching SHA-256 evidence; MIKey.m unchanged; original GUI preserved and AutomationServer restored disabled. Only run-01 was actually estimated. See [full report](../runs/20261016-demo-real-spm/RUN_REPORT.md) for metrics, images, commands and limits.


## 2026-10-16 server runtime path/state repair

After the real-SPM registration validation, server logs exposed a separate Current-Folder/path failure in Step 3 and stale GUI state after missing class methods. The original package now pins its root, checks key runtime paths/methods before GUI work, cleans state without class cleanup calls, restores cwd, and preserves original exceptions if metadata also fails. Step 3 cleanup no longer changes cwd. GUI layout remains unchanged. Three modified/new MATLAB files passed MATLAB-2018a parsing and native R2018a syntax checks with a detected malformed negative control. New headless/GUI regressions were supplied but NOT RUN: no local MATLAB process is available and prior fresh startup failed License Error -8. No remote fieldmap estimate was run in this repair. See [server recovery](SERVER_RUNTIME_RECOVERY.md) and [validation report](../runs/20261016-runtime-path/RUN_REPORT.md). Source release integrity verified for 223 source files.


## 2026-10-19: complete selected-step validation audit

All 50 public parameters now share a conditional usage map across validation, batch controls, preflight, prerequisite checks and metadata. Unused values are preserved and ignored; active errors are aggregated. Step 1 and Steps 2-10 of the unchanged generic configuration pass despite later atlas values. GUI construction and user configuration are byte-identical.

Executed: 448 inactive field/type cases, all 17 single-stage routes, active type checks for every field, PC/choice/import/metadata tests, and representative real-SPM synthetic Steps 1/2/8/10/11/12/13. Native Code Analyzer and MATLAB-2018a parsing passed on 20 audited MATLAB files, with a detected malformed negative control. Two old test assumptions (empty Step 12 prerequisites and a pre-BIDS filename assertion) were corrected and rerun; initial failures remain recorded. No server research dataset or GUI interaction test was run. See [full run report](../runs/20261019-scoped-validation/RUN_REPORT.md) and [deployment guide](SCOPED_VALIDATION_UPDATE.md).
