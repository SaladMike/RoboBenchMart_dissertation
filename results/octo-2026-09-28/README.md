# Octo 原子任务评测：2026-09-28

这是一次独立的复现实验记录，**没有覆盖论文原有结果**。每个配置评测 30 个 episode；42 个配置全部完成，最终汇总进程退出码为 `0`。原始逐配置数据见 [success_rates.csv](success_rates.csv)。

## 本次实验表

单元格为“成功次数/评测次数（成功率）”。同一任务下的商品或门类型按次数合并；`—` 表示门任务没有 Pairing 条件。

| 条件 | Basket | Floor | Board | Open | Close |
| --- | ---: | ---: | ---: | ---: | ---: |
| Seeds | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 1/60 (1.67%) |
| Pose | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 0/60 (0.00%) |
| Layout | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 3/60 (5.00%) |
| Pairing | 0/60 (0.00%) | 0/60 (0.00%) | 0/60 (0.00%) | — | — |

条件与项目脚本的对应关系：`train → Seeds`、`robo → Pose`、`uns → Layout`、`ood → Pairing`。Floor 的 `beans` 任务目标是 *Heinz Beans in a rich tomato sauce*，对应论文逐项表的 Heinz。

全部 1,260 个 episode 中有 4 次成功：`close_showcase_train` 为 1/30，`close_showcase_uns` 为 3/30。这个合计仅用于核对原始数据；不同任务的成功率不宜合成一个模型总分。复合任务不在这次评测范围内。

## 与论文主表对照

下表列出本次成功率与论文主表的百分数；论文每个商品/门类型评测 100 次，本次为 30 次，因此只能比较观察到的比例，不能视作逐次复现。

| 条件 | 任务 | 本次 | 论文 |
| --- | --- | ---: | ---: |
| Pose | Basket | 0.00% (0/90) | 1% |
| Pose | Floor | 0.00% (0/60) | 1% |
| Pose | Board | 0.00% (0/90) | 2% |
| Pose | Open | 0.00% (0/60) | 3% |
| Pose | Close | 0.00% (0/60) | 4% |
| Layout | Basket | 0.00% (0/90) | 2% |
| Layout | Floor | 0.00% (0/60) | 1% |
| Layout | Board | 0.00% (0/90) | 1% |
| Layout | Open | 0.00% (0/60) | 2% |
| Layout | Close | 5.00% (3/60) | 7% |
| Pairing | Basket | 0.00% (0/60) | 0% |
| Pairing | Floor | 0.00% (0/60) | 0% |
| Pairing | Board | 0.00% (0/60) | 0% |

论文的 Seeds 条件只列于逐项表；按其中 12 项等次数合并为 57/1,200（4.75%），本次为 1/360（0.28%）。Pose 同样为论文 24/1,200（2.00%）、本次 0/360；Layout 为论文 27/1,200（2.25%）、本次 3/360（0.83%）。这些合计帮助核对差异，不代替按任务分析。Pairing 两次评测均为零。

## 口径与来源

- 评测入口：[`bash/eval_model.sh`](../../bash/eval_model.sh)；场景、种子、episode 上限和成功判定沿用该脚本。完整的 42 配置结果保存在本目录 CSV。
- 运行批次：`octo_parallel_20260928_021558`。前 17 个配置来自串行运行，后 25 个配置由 4 个独立 Octo 服务并行执行；已停止批次中的部分 episode 未计入。
- 本地源 CSV：`logs/octo_parallel_20260928_021558_success_rates.csv`，SHA-256：`aefa60f24b39a786cc05fda02e2cda380936f425288d20796b2c6bb630ac1c69`。CSV 中的 `source_log` 指向评测机器上的相对路径；本次提交只收录汇总 CSV，没有一并提交该轮的逐次日志或视频。
- 模型来自 `emb-ai/RoboBenchMart_octo`，下载清单记录的修订为 `f3c8de450fc08fb5737d32442a2b1e6ab2993244`，checkpoint 目录为 `1000000`；服务使用 1 帧观测历史和 50 步动作块。
- 论文原值见论文仓库的[主表数据](https://github.com/SaladMike/robobenchmart-dissertation/blob/main/tools/rerun/01_main_results.csv)与[逐项数据](https://github.com/SaladMike/robobenchmart-dissertation/blob/main/tools/rerun/02_per_item.csv)；本报告没有改动论文数据。

**可比性限制：**公开权重附带的 `finetune_config.json` 记录 1,000,000 步、batch 256、历史窗口 1；论文方法部分记录 100,000 步、batch 8、历史观测 2。实际采用的论文 checkpoint 尚未核实。本次每配置 30 次也少于论文的 100 次，且评测所用代码仓库有未提交的本地修复。因此这些数值是本次运行的独立结果，不能直接用于替换论文表格或将差距归因于单一原因。
