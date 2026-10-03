# Octo 原子任务评测：2026-09-28

这是本次 Octo 原子任务评测的独立记录。每个配置评测 30 个 episode；42 个配置全部完成，最终汇总进程退出码为 `0`。原始逐配置数据见 [success_rates.csv](success_rates.csv)；[episode_outcomes.csv](episode_outcomes.csv) 逐一列出 1,260 段视频与日志中的成功回合编号。

## 本次实验表

单元格为“成功次数/评测次数（成功率）”。同一任务下的商品或门类型按次数合并；`—` 表示门任务没有 Pairing 条件。

| 条件 | Basket | Floor | Board | Open | Close |
| --- | ---: | ---: | ---: | ---: | ---: |
| Seeds | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 1/60 (1.67%) |
| Pose | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 0/60 (0.00%) |
| Layout | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 3/60 (5.00%) |
| Pairing | 0/60 (0.00%) | 0/60 (0.00%) | 0/60 (0.00%) | — | — |

条件与项目脚本的对应关系：`train → Seeds`、`robo → Pose`、`uns → Layout`、`ood → Pairing`。Floor 的 `beans` 任务目标是 *Heinz Beans in a rich tomato sauce*。

全部 1,260 个 episode 中有 4 次成功：`close_showcase_train` 为 1/30，`close_showcase_uns` 为 3/30。这个合计仅用于核对原始数据；不同任务的成功率不宜合成一个模型总分。复合任务不在这次评测范围内。

## 口径与来源

- 评测入口：[`bash/eval_model.sh`](../../bash/eval_model.sh)；场景、种子、episode 上限和成功判定沿用该脚本。完整的 42 配置结果保存在本目录 CSV。
- 运行批次：`octo_parallel_20260928_021558`。前 17 个配置来自串行运行，后 25 个配置由 4 个独立 Octo 服务并行执行；已停止批次中的部分 episode 未计入。
- 本地源 CSV：`logs/octo_parallel_20260928_021558_success_rates.csv`，SHA-256：`aefa60f24b39a786cc05fda02e2cda380936f425288d20796b2c6bb630ac1c69`。CSV 中的 `source_log` 指向本仓库已上传的原始日志；[log_manifest.csv](log_manifest.csv) 记录全部来源日志、运行脚本和退出码文件的路径与 SHA-256。
- 模型来自 `emb-ai/RoboBenchMart_octo`，下载清单记录的修订为 `f3c8de450fc08fb5737d32442a2b1e6ab2993244`，checkpoint 目录为 `1000000`；服务使用 1 帧观测历史和 50 步动作块。

**结果范围：**本次每配置评测 30 次，使用上述公开权重和本地评测代码；相关客户端和服务修复已随 2026-10-02 的结果提交。本表仅记录这一批次的原子任务结果。

## 本轮原始结果与核验

这次补交了 42 个完整配置目录中的 **1,260 段 MP4、42 个 HDF5、42 个 JSON**，共 1,344 个文件、833,587,734 字节。[artifact_manifest.csv](artifact_manifest.csv) 提供每个文件的路径、大小与 SHA-256。MP4/HDF5 存于 Git LFS；克隆后运行 `git lfs pull`。中断批次留下的不足 30 段的临时目录、单回合探针和烟雾测试不计入本轮正式结果，也不在本清单中。

最终 42 配置来自三段串行日志的前 17 个完整配置和 25 份并行逐配置日志。串行日志的 `Results:` 行依配置顺序对应 CSV 行；并行日志各有一行 `Results:`。每行列出的成功视频编号都存在于该配置目录。[episode_outcomes.csv](episode_outcomes.csv) 将这些编号映射到 1,260 个 MP4，合计 4 次成功。42 个 JSON 的 `episodes` 均为空、42 个 HDF5 各 800 字节；逐回合成败来自日志而非这些容器文件，视频尚未独立人工重判。四个并行工作进程、最终汇总器与合并批次退出码均为 `0`；早期串行批次有中断记录，但纳入 CSV 的前 17 个配置均有完整结果。

文件哈希可用与 [π₀.₅ 结果页](../pi05-2026-10-02/README.md)相同的 Python 校验命令，把清单路径换为本目录的 `artifact_manifest.csv` 和 `log_manifest.csv`。两模型与旧论文的详细对照见[论文仓库文档](https://github.com/SaladMike/robobenchmart-dissertation/blob/main/docs/EXPERIMENT_REPLACEMENT_zh.md)。
