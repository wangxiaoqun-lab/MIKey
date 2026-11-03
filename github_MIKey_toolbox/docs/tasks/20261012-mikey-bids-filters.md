# MIKey session/task/run 独立筛选与可选网络模板

用户补充：固定文件名的网络模板不是必需，用户可以指定自己的模板；GUI 和脚本都需要独立 session、task、run 筛选。

实现：

- `groupNetworkPath` 与 GUI 的 Group Network 输入/浏览控件共用；留空时按 Network/Use Custom 选择，显式路径优先。不再要求旧 final_network 文件名。
- GUI 的 Ses/Task/Run 与脚本的 sessionFilter/taskFilter/runFilter：精确值、通配符、逗号列表和 none。
- 统一枚举 subject/session 作用范围，BOLD 按完整 task/run entity 过滤，衍生结果保留 session 层级。
- session 缺少 T2w 时可复用 subject 根目录 T2w；task/run 不过滤配套解剖和 fieldmap。
- 群组回归读取被选中原始扫描对应的结果文件，避免混入未选结果。
- 群组/拼接输出按 session/task/run 范围隔离；拼接保留单 subject/session 范围。
- 个体差异校正先在每个 subject 内平均所选 runs/sessions，跨真实 subject 计算，避免 session 充当独立样本。
- 分区并行开关默认 false；修复单次迭代绘图的重复 X 数据与退化坐标范围。

验证：旧无 session 流程回归、真实 GUI 离屏创建、多 subject/session/task/run 合成 NIfTI、用户网络的分区 15/16、选中群组结果与生物学样本计数；详见 ../VALIDATION.md 更新章节。

所有数据测试均在临时目录，不修改研究数据或附带 demo 数据，不创建 Git 提交。
