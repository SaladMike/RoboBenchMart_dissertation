# π₀.₅ 原子任务完整评测记录（2026-10-02）

本目录记录运行批次 `pi05_parallel_20261002_105333`。固定的 42 个配置各执行 30 次，共 **1,260 次评测，39 次成功**。逐配置次数和原始日志入口见 [success_rates.csv](success_rates.csv)；[episode_outcomes.csv](episode_outcomes.csv) 将 1,260 段视频逐一映射到日志的成功回合编号；[artifact_manifest.csv](artifact_manifest.csv) 对 1,344 个逐配置产物逐一列出路径、字节数和 SHA-256；[log_manifest.csv](log_manifest.csv) 列出批次日志和脚本的 SHA-256。与 Octo 的并列表和旧论文实验对照见[论文仓库的详细文档](https://github.com/SaladMike/robobenchmart-dissertation/blob/main/docs/EXPERIMENT_REPLACEMENT_zh.md)。

## 结果表

单元格为成功次数/回合数（成功率）。每个配置 30 次；Basket/Board 每条件汇总 3 个配置，其余任务每条件汇总 2 个配置；门任务没有 Pairing 条件。

| 条件 | Basket | Floor | Board | Open | Close |
| --- | ---: | ---: | ---: | ---: | ---: |
| Seeds | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 0/60 (0.00%) | 15/60 (25.00%) |
| Pose | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 1/60 (1.67%) | 10/60 (16.67%) |
| Layout | 0/90 (0.00%) | 0/60 (0.00%) | 0/90 (0.00%) | 1/60 (1.67%) | 12/60 (20.00%) |
| Pairing | 0/60 (0.00%) | 0/60 (0.00%) | 0/60 (0.00%) | — | — |

8 个配置出现成功：`close_fridge_train` 8/30、`close_showcase_train` 7/30、`close_fridge_robo` 7/30、`open_showcase_robo` 1/30、`close_showcase_robo` 3/30、`open_fridge_uns` 1/30、`close_fridge_uns` 6/30、`close_showcase_uns` 6/30。其余 34 个配置为 0/30。前三类抓放任务及 Pairing 条件全部为 0。39/1,260 仅用于数量核对，不作为跨任务的模型总分。

## 运行协议与来源

- 上游脚本为 [`bash/eval_model.sh`](../../bash/eval_model.sh)。`train → Seeds`、`robo → Pose`、`uns → Layout`、`ood → Pairing`。`--num-traj 30`；任务最长步数依次为 Board/Floor 750、Basket 600、Fridge 500、Showcase 1,000。保留脚本的场景、种子与成功判定。
- 4 个独立的仿真客户端并行，连接同一个 8000 端口的 OpenPI π₀.₅ 服务。具体配置分配、命令和运行次序由 [`manifest.json`](../../logs/pi05_parallel_20261002_105333_manifest.json) 和 [`w0.sh`](../../logs/pi05_parallel_20261002_105333_w0.sh) 至 [`w3.sh`](../../logs/pi05_parallel_20261002_105333_w3.sh) 记录。各客户端、汇总器、总批次的 `.exit` 均为 `0`，42 份逐配置日志各有一个最终 `Results:`。
- 权重：`emb-ai/RoboBenchMart_pi05`，固定修订 `533ad107347c3568dc2456d1586b665889f0ed18`，本地校验 22 文件、12,430,591,218 字节。场景：`emb-ai/RoboBenchMart_demo_envs`，修订 `3dabfaaf9bdf2ba886264a1160dab68ac7043d00`，466 文件、87,643,138 字节。权重与原始场景下载包不在本提交内。另需项目的资源库 `assets/`。OpenPI 使用 `pi05_eval_rbm`，本地 OpenPI 源码修订 `c23745b5ad24e98f66967ea795a07b2588ed6c79`，且有 RoboBenchMart 适配修改；仅该修订号不足以还原适配代码。
- 本次客户端使用的项目代码修复已作为本次提交的一部分：`dsynth/envs/pick_from_floor.py` 的 ManiSkill 导入、`scripts/eval_policy_client.py` 的语言指令读取、`dsynth/web_utils.py` 的服务连接修复。Octo 另使用 `scripts/octo_server.py` 的每连接策略实例。运行前的代码基线为 `0d162e1d9a816bf4e29a426918f6a89eaddba47c`。

## 原始产物及其边界

- 42 份逐配置日志：[`logs/pi05_parallel_20261002_105333_config01.log`](../../logs/pi05_parallel_20261002_105333_config01.log) 至 `config42.log`，由 [CSV 的 `source_log` 列](success_rates.csv) 逐项指向；另有四份工作进程日志、最终汇总日志、总日志、退出码文件和执行脚本，均列于 [log_manifest.csv](log_manifest.csv)。[权重校验日志](../../logs/pi05_prepare_20261002_091757_verify.log) 与 [服务端日志](../../logs/pi05_server_20261002_104600.log) 也已收录。
- `demo_envs/**/evaluations/*pi05_parallel_20261002_105333*/` 下保存 1,260 段 MP4、42 个 HDF5、42 个 JSON，总计 1,344 文件、653,950,295 字节。MP4/HDF5 通过 Git LFS 发布；克隆后需 `git lfs pull` 才能取得二进制原件。
- 本轮 JSON 内 `episodes` 数组为空，HDF5 文件各仅 800 字节，不应视作保存了逐回合轨迹。42 份逐配置日志的 `Results: [回合编号]` 列表与视频文件名逐一对应；[episode_outcomes.csv](episode_outcomes.csv) 据此标出 1,260 回合的成败，可复算 39 次成功。该索引来自运行日志，不是对视频独立重新判读；仅靠 JSON/HDF5 仍无法得到逐回合成败。
- 这是已发布的微调检查点的**评测**，不是本机重新训练。没有 π₀、SmolVLA 或复合任务的本轮结果。并行仿真的随机数序列不保证与单进程串行运行逐回合一致；两模型使用同一 42 配置脚本，但不是严格配对的逐回合比较。

## 文件校验

在项目根目录执行：

```bash
python - <<'PYCODE'
import csv, hashlib
from pathlib import Path
for manifest in ('results/pi05-2026-10-02/artifact_manifest.csv', 'results/pi05-2026-10-02/log_manifest.csv'):
    with open(manifest, newline='') as stream:
        for row in csv.DictReader(stream):
            path = Path(row['relative_path'])
            assert path.stat().st_size == int(row['size_bytes']), path
            assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], path
    print('OK:', manifest)
PYCODE
```

校验产物清单前须先拉取 LFS 文件。Octo 本轮公开结果见 [`results/octo-2026-09-28`](../octo-2026-09-28/README.md)。
