# MIKey 无图形脚本与使用文档

日期：2026-10-12（用户时区 Asia/Shanghai）。

用户目标：计算节点通过脚本使用 GUI 的全部参数；从 MATLAB Set Path 开始提供安装、运行与排错说明。

已交付：

- 共用现有计算函数的 `MIKey_run`，默认配置、MAT/JSON 导入和严格校验。
- 全部 GUI 参数统一映射；分区模式由参数替代弹窗。
- 环境检查、逐步前置文件检查、掩膜空间检查、日志、源码 SHA-256 清单及失败报告。
- 修复 GUI 保存/加载不一致、单被试目录展开、平滑参数被忽略、先验网络选项映射、回归默认参数遗漏、TR 回退和组织分割路径/文件名错误。
- 中文 README、旧 readme 入口、完整参数样例、Slurm/PBS 模板。
- MATLAB R2018a + SPM12 合成数据验证，见 ../VALIDATION.md。

未执行研究数据和服务器作业；未创建 Git 仓库、分支或提交；没有改变当前鼠脑 MRI 工作区的已有业务文件。

后续验证范围：真实采集条件下的 fieldmap、时序、配准、噪声评估、分区与组织分割。已根据用户澄清改为可选 groupNetworkPath；可使用 AMCP_temp 内已有网络或用户模板，不要求固定 final_network 文件名。

后续用户要求已纳入：GUI/脚本独立 session/task/run 筛选、session 目录与输出层级、群组输入筛选及 subject 内跨 run/session 平均。验证记录见 ../VALIDATION.md 更新章节。
