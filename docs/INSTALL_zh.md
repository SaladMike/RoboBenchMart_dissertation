# RoboBenchMart 环境安装命令

适用目录：`/root/autodl-tmp/RoboBenchMart_dissertation`。
以下命令在同一个 Bash 终端中按顺序执行；某一步报错时先停下检查，不要继续运行后续步骤。
本文配置场景生成、ManiSkill 仿真和运动规划环境。Octo、Pi0、Pi05 的模型服务需按项目 README 另建环境。

下载方式：pip 使用清华 PyPI 镜像，Conda 使用清华 main 镜像，APT 使用机器已有的软件源。这些命令通过 `env -u` 临时移除代理变量，不修改 VPN 或其他终端。RoboCasa 和 Hugging Face 资产保留当前代理访问原站，见第 4 节。

## 0. 初次检查记录

以下记录对应 2026-09-16 初次配置时的状态，不代表后续安装进度；当前状态请通过第 5 节检查确认。

- GPU：NVIDIA RTX 4090 24 GB，驱动 570.124.04，`nvidia-smi` 显示支持 CUDA 12.8。
- 已安装 `libvulkan1`、`vulkan-tools`，`vulkaninfo --summary` 能识别 RTX 4090。
- 已创建 Conda 环境 `dsynth`，路径为 `/root/miniconda3/envs/dsynth`，Python 3.10.21。
- PyTorch 下载已停止；该环境目前只有 pip、setuptools、wheel 等基础工具，项目依赖和资产尚未安装。
- 本文命令尚未完成端到端运行验证。请以第 5、6 节的实际检查结果为准。

## 1. 激活环境

当前机器直接执行，无需再次创建环境：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
python --version
which python
```

预期 Python 为 3.10，解释器路径为 `/root/miniconda3/envs/dsynth/bin/python`。

仅在其他机器或环境不存在时，先执行：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    conda create -n dsynth python=3.10 pip -y \
    --override-channels -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
conda activate dsynth
```

## 2. 检查系统依赖

```bash
nvidia-smi
vulkaninfo --summary
df -h /root /root/autodl-tmp
```

当前服务器没有桌面，`DISPLAY` 未设置的提示不代表 GPU 不可用；重点看 Vulkan 输出是否包含 NVIDIA GPU。后续先使用无界面测试。

仅在系统缺少 Vulkan 时安装，当前机器可跳过：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy apt-get update
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    apt-get install -y libvulkan1 vulkan-tools libgl1 libegl1
```

以下从清华 PyPI 镜像安装 PyTorch 2.6.0。在当前 Linux x86_64 机器上，该版本的 PyPI 包依赖 CUDA 12.4 运行库，无需另外安装完整 CUDA Toolkit，也无需升级当前 NVIDIA 驱动。

## 3. 安装 Python 依赖

先配置本次终端的缓存目录，减少系统盘上的下载临时文件：

```bash
mkdir -p /root/autodl-tmp/tmp /root/autodl-tmp/robobenchmart-cache/pip
export TMPDIR=/root/autodl-tmp/tmp
export PIP_CACHE_DIR=/root/autodl-tmp/robobenchmart-cache/pip
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    python -m pip install --upgrade pip wheel 'setuptools<81' \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --timeout 120 --retries 10
```

`setuptools<81` 保留旧依赖可能使用的 `pkg_resources` 接口。

先安装固定版本的 GPU PyTorch：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    python -m pip install torch==2.6.0 torchvision==0.21.0 \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --timeout 120 --retries 10
```

再安装项目依赖。显式固定 PyTorch，避免解析依赖时换成其他 CUDA 版本；NumPy 1.26.4 满足 `mplib==0.2.1` 的 `numpy<2` 要求：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    python -m pip install -r requirements.txt \
    'torch==2.6.0' 'torchvision==0.21.0' \
    'numpy==1.26.4' 'mani_skill==3.0.1' \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --timeout 120 --retries 10
```

按照项目 README，最后单独安装运动规划库：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    python -m pip install mplib==0.2.1 \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --timeout 120 --retries 10
```

**已知版本声明冲突：** ManiSkill 3.0.1 的包元数据要求 `mplib==0.1.1`，但 RoboBenchMart README 指定 `mplib==0.2.1`。因此这里遵循项目要求分两步安装；最后一步可能显示依赖冲突提示，`pip check` 也会报告这项冲突。不要把 `mplib==0.2.1` 合并到上一条安装命令中，否则解析器会直接拒绝安装。这一组合的运行兼容性仍需通过后面的项目测试确认，不能将该警告当作验证成功。

## 4. 下载必需资产

以下资产下载不是 pip 安装，不能添加清华 PyPI 的 `-i` 参数。这里保留当前 VPN 代理访问原站；前面的 `env -u` 只影响对应命令，不会关闭这些下载使用的代理。清华 PyPI 换源不会加速资产下载，实际速度取决于原站和节点。

将 ManiSkill 资产放到数据盘，并将设置保存到当前 Conda 环境：

```bash
mkdir -p /root/autodl-tmp/robobenchmart-cache/maniskill
conda env config vars set -n dsynth \
  MS_ASSET_DIR=/root/autodl-tmp/robobenchmart-cache/maniskill
conda deactivate
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
```

下载 RoboCasa 资产。如果命令询问是否下载，输入 `y`：

```bash
python -m mani_skill.utils.download_asset RoboCasa
```

当前代理包含 SOCKS 配置，Hugging Face 使用的 HTTPX 需要额外安装 SOCKS 支持，否则会报 `Using SOCKS proxy, but the 'socksio' package is not installed`。在 `dsynth` 环境中执行一次：

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u ALL_PROXY \
    -u http_proxy -u https_proxy -u all_proxy \
    python -m pip install 'httpx[socks]' \
    -i https://pypi.tuna.tsinghua.edu.cn/simple \
    --timeout 120 --retries 10
```

这条命令通过清华源直连补齐依赖，不会清除后续下载使用的代理。用 `python -c 'import socksio, httpx; c = httpx.Client(); c.close(); print("SOCKS support OK")'` 检查依赖和客户端初始化；该检查不发起网络请求。参见 [HTTPX SOCKS 代理说明](https://www.python-httpx.org/advanced/proxies/#socks)。

下载 RoboBenchMart 商品和场景资产。查询时约 2.4 GB，不包含上面的 RoboCasa 下载：

```bash
hf download emb-ai/RoboBenchMart_assets \
  --repo-type dataset \
  --local-dir /root/autodl-tmp/RoboBenchMart_dissertation/assets \
  --max-workers 4
```

下载中断后可重跑同一条 `hf download` 命令。不要改变目标目录；项目配置使用 `assets/`，其中应包含 `preprocessed/` 子目录。

## 5. 检查依赖、CUDA 和无界面仿真

查看安装版本及依赖声明：

```bash
python -m pip show torch torchvision mani_skill sapien mplib numpy trimesh
python -m pip check
```

`pip check` 可能因第 3 节所述的 `mplib` 声明冲突返回非零；其他冲突需要另外处理。

检查 GPU 和项目模块导入：

```bash
python - <<'PY'
import torch
import torchvision
import mani_skill
import sapien
import mplib
import scene_synthesizer
import dsynth.envs
import dsynth.robots

print("PyTorch:", torch.__version__)
print("CUDA runtime:", torch.version.cuda)
print("CUDA available:", torch.cuda.is_available())
assert torch.cuda.is_available(), "PyTorch cannot access CUDA"
print("GPU:", torch.cuda.get_device_name(0))
x = torch.ones(8, device="cuda")
assert x.sum().item() == 8
print("Imports and CUDA check passed")
PY
```

运行一次短的无界面 GPU 仿真和相机检查。首次运行可能提示下载机器人资产：

```bash
python - <<'PY'
import gymnasium as gym
import mani_skill.envs
import torch

env = gym.make(
    "PickCube-v1",
    num_envs=1,
    obs_mode="rgbd",
    render_mode="rgb_array",
    sim_backend="gpu",
)
try:
    obs, info = env.reset(seed=0)
    for _ in range(10):
        obs, reward, terminated, truncated, info = env.step(env.action_space.sample())
    frame = torch.as_tensor(env.render())
    print("Rendered frame:", tuple(frame.shape))
    assert frame.numel() > 0
    assert frame.float().std().item() > 0, "Rendered image is uniform"
    print("GPU simulation and rendering check passed")
finally:
    env.close()
PY
```

## 6. 生成并测试项目示例场景

先完成第 4、5 节，确保资产已下载、检查已通过。以下两项任务分开启动：确认场景生成成功后，再启动仿真。`nohup` 可在断开 SSH 后继续运行，但不能在服务器关机后继续运行。

先激活环境并在后台生成场景：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
mkdir -p logs
nohup python -u scripts/generate_scene_continuous.py ds_continuous=small_scene \
  > logs/generate_scene.log 2>&1 < /dev/null &
echo $! > logs/generate_scene.pid
```

查看生成进度：

```bash
tail -n 50 -f /root/autodl-tmp/RoboBenchMart_dissertation/logs/generate_scene.log
```

按 `Ctrl+C` 只退出日志查看，不会停止后台任务。确认日志显示 `Done`，且没有生成失败或异常，再启动无界面仿真并保存视频：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
mkdir -p logs
nohup python -u scripts/show_env_in_sim.py generated_envs/ds_small_scene/ \
  -s 42 --episode_length 10 --video \
  > logs/show_env.log 2>&1 < /dev/null &
echo $! > logs/show_env.pid
```

```bash
tail -n 50 -f /root/autodl-tmp/RoboBenchMart_dissertation/logs/show_env.log
```

不加 `--gui`，适合当前无桌面的服务器。首次下载提示无法在 `nohup` 中交互输入；若日志提示缺少资产，应先在前台完成下载再重试。

如果需要更长的视频，用下面的命令替代上面的 10 步仿真命令。脚本已改为让视频分段长度跟随 `--episode_length`，不会再每 10 步切一个短片。以当前固定的 30 FPS 保存，900 步约为 30 秒，1800 步约为 60 秒；实际计算耗时可能更长。运行的是随机动作，并非训练好的策略。

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
mkdir -p logs
nohup python -u scripts/show_env_in_sim.py generated_envs/ds_small_scene/ \
  -s 42 --episode_length 900 --video \
  > logs/show_env_900.log 2>&1 < /dev/null &
echo $! > logs/show_env_900.pid
```

```bash
tail -n 50 -f /root/autodl-tmp/RoboBenchMart_dissertation/logs/show_env_900.log
```

若场景生成在 `generated_envs/ds_small_scene_nohup/`，请将上面命令的输入目录替换为该目录；视频仍保存在所选场景目录下。完整视频需要等录制结束、写盘完成后再查看。已运行的旧进程不会自动使用脚本的新设置。

运行后的输出位置：

| 内容 | 路径 |
| --- | --- |
| 生成的场景 | `/root/autodl-tmp/RoboBenchMart_dissertation/generated_envs/ds_small_scene/` |
| 视频和录制输出 | `/root/autodl-tmp/RoboBenchMart_dissertation/generated_envs/ds_small_scene/videos_seed=[42]_shader=default_sensor_shader=minimal/` |
| 场景生成日志 | `/root/autodl-tmp/RoboBenchMart_dissertation/logs/generate_scene.log` |
| 仿真日志 | `/root/autodl-tmp/RoboBenchMart_dissertation/logs/show_env.log` |

视频目录对应上面的 `-s 42` 和默认 shader 参数，具体文件名由录制器生成，日志也会打印 `Video path`。目录名包含方括号，在 shell 中使用完整路径时请加引号。

已有 `ds_small_scene/` 时，在生成命令中加上 `ds_continuous.output_dir=generated_envs/ds_small_scene_check`，并把仿真命令中的场景路径一起改为 `generated_envs/ds_small_scene_check/`。不要同时启动多个任务写同一个输出目录。重跑上述命令会覆盖对应日志，需保留旧日志时先改日志文件名。

### 整个商店的全景视频

`--overview` 使用 1280x720 的高处俯视相机，按商店尺寸自动取景并环绕一周。录制期间隐藏屋顶、外墙和吊灯模型，保留货架、商品、地板与机器人；这些显示调整不修改场景资产。此模式固定场景状态，只移动相机，不执行机器人随机动作。

先确认前面的依赖、资产和场景已准备好，再执行：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
mkdir -p logs
nohup python -u scripts/show_env_in_sim.py generated_envs/ds_small_scene/ \
  -s 42 --overview --episode_length 900 --video \
  > logs/overview.log 2>&1 < /dev/null &
echo $! > logs/overview.pid
```

```bash
tail -n 50 -f /root/autodl-tmp/RoboBenchMart_dissertation/logs/overview.log
```

此模式中 `--episode_length` 表示输出帧数：900 帧为 30 秒，1800 帧为 60 秒，均按 30 FPS 播放。相机每次环绕一周，因此增加帧数也会使环绕更慢。不要搭配 `--gui` 或多个并行环境。

视频输出目录：`/root/autodl-tmp/RoboBenchMart_dissertation/generated_envs/ds_small_scene/overview_seed=42/`。文件名为 `overview_日期_时间_微秒.mp4`，每次录制使用新文件名。日志出现 `Overview saved:` 后，文件才完整写入。

若使用 `ds_small_scene_nohup/` 场景，把输入路径一起替换，视频会保存到 `generated_envs/ds_small_scene_nohup/overview_seed=42/`。

验证成功后，在前台记录实际依赖版本，这条命令无需 `nohup`：

```bash
python -m pip freeze > requirements.installed.txt
```

## 7. 可选演示数据

与第 4 节相同，以下 Hugging Face 下载保留当前代理，不使用清华 PyPI 源。

仅在需要训练场景或对应评估数据时，启动后台下载：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
mkdir -p logs
nohup hf download emb-ai/RoboBenchMart_demo_envs \
  --repo-type dataset --local-dir demo_envs --max-workers 4 \
  > logs/download_demo_envs.log 2>&1 < /dev/null &
echo $! > logs/download_demo_envs.pid
```

```bash
tail -n 50 -f /root/autodl-tmp/RoboBenchMart_dissertation/logs/download_demo_envs.log
```

原始运动规划轨迹约 50 GB，基础环境安装不需要这一步。确认空间足够后再执行：

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
mkdir -p logs
df -h /root/autodl-tmp
```

检查空间后再单独执行：

```bash
nohup hf download emb-ai/RoboBenchMart_demo_envs_mp \
  --repo-type dataset --local-dir demo_envs --max-workers 4 \
  > logs/download_demo_envs_mp.log 2>&1 < /dev/null &
echo $! > logs/download_demo_envs_mp.pid
```

```bash
tail -n 50 -f /root/autodl-tmp/RoboBenchMart_dissertation/logs/download_demo_envs_mp.log
```

两类演示数据均保存到 `/root/autodl-tmp/RoboBenchMart_dissertation/demo_envs/`，与项目 README 一致。按需选择，若两类都下载，请依次执行，避免同时写入同一目录。下载中断后可重跑对应命令。

后台任务的 PID 保存在 `logs/` 下对应的 `.pid` 文件中。`nohup` 启动成功只表示进程已提交；是否执行成功仍需查看日志和输出文件。

## 8. 下次进入项目

```bash
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
cd /root/autodl-tmp/RoboBenchMart_dissertation
```

`MS_ASSET_DIR` 已通过第 4 节保存到环境，激活后自动生效。

## 参考

- [项目安装说明](../README.md#installation)
- [清华 PyPI 镜像使用说明](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/)
- [清华 Anaconda 镜像使用说明](https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/)
- [PyTorch 官方历史版本安装命令](https://pytorch.org/get-started/previous-versions/#v260)
- [ManiSkill 安装与 Vulkan 排错](https://maniskill.readthedocs.io/en/latest/user_guide/getting_started/installation.html)
- [RoboBenchMart 资产](https://huggingface.co/datasets/emb-ai/RoboBenchMart_assets)
