#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/pi05_parallel_20261002_105333_w2.exit"' EXIT
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

printf "START config=01 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/move_from_board_to_board_duff \
--json-path demo_envs/move_from_board_to_board_duff/demos/motionplanning/move_from_board_to_board_duff_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}board_duff_train${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD > "logs/pi05_parallel_20261002_105333_config01.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config01.log" || true)" != 1 ]; then echo "Incomplete result for config 01" >&2; exit 3; fi
printf "DONE config=01 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=03 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/move_from_board_to_board_vanish \
--json-path demo_envs/move_from_board_to_board_vanish/demos/motionplanning/move_from_board_to_board_vanish_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}board_vanish_train${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD > "logs/pi05_parallel_20261002_105333_config03.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config03.log" || true)" != 1 ]; then echo "Incomplete result for config 03" >&2; exit 3; fi
printf "DONE config=03 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=05 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/close_fridge/ \
--json-path demo_envs/close_fridge/demos/motionplanning/close_fridge_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}close_fridge_train${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE > "logs/pi05_parallel_20261002_105333_config05.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config05.log" || true)" != 1 ]; then echo "Incomplete result for config 05" >&2; exit 3; fi
printf "DONE config=05 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=14 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/move_from_board_to_board_nestle \
--json-path demo_envs/move_from_board_to_board_nestle/demos/motionplanning/move_from_board_to_board_nestle_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_nestle_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD > "logs/pi05_parallel_20261002_105333_config14.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config14.log" || true)" != 1 ]; then echo "Incomplete result for config 14" >&2; exit 3; fi
printf "DONE config=14 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=18 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/open_showcase/ \
--json-path demo_envs/open_showcase/demos/motionplanning/open_showcase_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}open_showcase_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC > "logs/pi05_parallel_20261002_105333_config18.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config18.log" || true)" != 1 ]; then echo "Incomplete result for config 18" >&2; exit 3; fi
printf "DONE config=18 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=23 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_nivea_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_nivea_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/pi05_parallel_20261002_105333_config23.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config23.log" || true)" != 1 ]; then echo "Incomplete result for config 23" >&2; exit 3; fi
printf "DONE config=23 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=25 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardDuffContEnv \
--scene-dir demo_envs/test_unseen_scenes_move_from_board_to_board_duff \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_duff_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config25.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config25.log" || true)" != 1 ]; then echo "Incomplete result for config 25" >&2; exit 3; fi
printf "DONE config=25 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=29 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e CloseDoorFridgeContEnv \
--scene-dir demo_envs/close_fridge/ \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_fridge_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config29.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config29.log" || true)" != 1 ]; then echo "Incomplete result for config 29" >&2; exit 3; fi
printf "DONE config=29 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=33 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorSlamContEnv \
--scene-dir demo_envs/test_unseen_scenes_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_slam_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config33.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config33.log" || true)" != 1 ]; then echo "Incomplete result for config 33" >&2; exit 3; fi
printf "DONE config=33 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=36 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContStarsEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_stars_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config36.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config36.log" || true)" != 1 ]; then echo "Incomplete result for config 36" >&2; exit 3; fi
printf "DONE config=36 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=40 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorDuffContEnv \
--scene-dir demo_envs/test_unseen_items_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_duff_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config40.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config40.log" || true)" != 1 ]; then echo "Incomplete result for config 40" >&2; exit 3; fi
printf "DONE config=40 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
