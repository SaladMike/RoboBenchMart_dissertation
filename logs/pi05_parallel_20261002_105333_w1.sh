#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/pi05_parallel_20261002_105333_w1.exit"' EXIT
source /root/miniconda3/etc/profile.d/conda.sh
conda activate dsynth
set -u
export MS_ASSET_DIR=/root/autodl-tmp/robobenchmart-cache/maniskill
export VK_ICD_FILENAMES=/etc/vulkan/icd.d/nvidia_icd.json
export XDG_RUNTIME_DIR=/root/autodl-tmp/robobenchmart-cache/xdg-runtime
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"
export NO_PROXY=localhost,127.0.0.1,::1
export no_proxy="$NO_PROXY"
export PYTHONUNBUFFERED=1
MODEL=pi05
EVAL_SCRIPT=scripts/eval_policy_client.py
RUN_TS=pi05_parallel_20261002_105333
SUBDIR_PREFIX="${MODEL}_"
SUBDIR_SUFFIX="_${RUN_TS}"
NUM_TRAJ=30
NET_PARAMS="--host=127.0.0.1 --port=8000"
EVAL_PARAMS_BOARD="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FRIDGE="--max-horizon 500 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_SHOWC="--max-horizon 1000 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FLOOR="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_BASKET="--max-horizon 600 --num-traj ${NUM_TRAJ} --save-video"

printf "START config=07 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/close_showcase/ \
--json-path demo_envs/close_showcase/demos/motionplanning/close_showcase_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}close_showcase_train${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC > "logs/pi05_parallel_20261002_105333_config07.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config07.log" || true)" != 1 ]; then echo "Incomplete result for config 07" >&2; exit 3; fi
printf "DONE config=07 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=12 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_stars_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}basket_stars_train${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/pi05_parallel_20261002_105333_config12.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config12.log" || true)" != 1 ]; then echo "Incomplete result for config 12" >&2; exit 3; fi
printf "DONE config=12 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=13 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/move_from_board_to_board_duff \
--json-path demo_envs/move_from_board_to_board_duff/demos/motionplanning/move_from_board_to_board_duff_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_duff_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD > "logs/pi05_parallel_20261002_105333_config13.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config13.log" || true)" != 1 ]; then echo "Incomplete result for config 13" >&2; exit 3; fi
printf "DONE config=13 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=17 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/close_fridge/ \
--json-path demo_envs/close_fridge/demos/motionplanning/close_fridge_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_fridge_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE > "logs/pi05_parallel_20261002_105333_config17.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config17.log" || true)" != 1 ]; then echo "Incomplete result for config 17" >&2; exit 3; fi
printf "DONE config=17 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=21 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_from_floor/ \
--json-path demo_envs/pick_from_floor/demos/motionplanning/pick_from_floor_slam_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_slam_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR > "logs/pi05_parallel_20261002_105333_config21.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config21.log" || true)" != 1 ]; then echo "Incomplete result for config 21" >&2; exit 3; fi
printf "DONE config=21 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=31 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e CloseDoorShowcaseContEnv \
--scene-dir demo_envs/close_showcase// \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_showcase_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config31.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config31.log" || true)" != 1 ]; then echo "Incomplete result for config 31" >&2; exit 3; fi
printf "DONE config=31 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=32 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorBeansContEnv \
--scene-dir demo_envs/test_unseen_scenes_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_beans_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config32.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config32.log" || true)" != 1 ]; then echo "Incomplete result for config 32" >&2; exit 3; fi
printf "DONE config=32 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=34 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContFantaEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_fanta_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config34.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config34.log" || true)" != 1 ]; then echo "Incomplete result for config 34" >&2; exit 3; fi
printf "DONE config=34 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=39 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorFantaContEnv \
--scene-dir demo_envs/test_unseen_items_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_fanta_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config39.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config39.log" || true)" != 1 ]; then echo "Incomplete result for config 39" >&2; exit 3; fi
printf "DONE config=39 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=42 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContSlamEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_slam_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config42.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config42.log" || true)" != 1 ]; then echo "Incomplete result for config 42" >&2; exit 3; fi
printf "DONE config=42 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
