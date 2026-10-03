#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/pi05_parallel_20261002_105333_w3.exit"' EXIT
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

printf "START config=02 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/move_from_board_to_board_nestle \
--json-path demo_envs/move_from_board_to_board_nestle/demos/motionplanning/move_from_board_to_board_nestle_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}board_nestle_train${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD > "logs/pi05_parallel_20261002_105333_config02.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config02.log" || true)" != 1 ]; then echo "Incomplete result for config 02" >&2; exit 3; fi
printf "DONE config=02 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=04 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/open_fridge/ \
--json-path demo_envs/open_fridge/demos/motionplanning/open_fridge_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}open_fridge_train${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE > "logs/pi05_parallel_20261002_105333_config04.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config04.log" || true)" != 1 ]; then echo "Incomplete result for config 04" >&2; exit 3; fi
printf "DONE config=04 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=08 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_from_floor/ \
--json-path demo_envs/pick_from_floor/demos/motionplanning/pick_from_floor_beans_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}floor_beans_train${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR > "logs/pi05_parallel_20261002_105333_config08.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config08.log" || true)" != 1 ]; then echo "Incomplete result for config 08" >&2; exit 3; fi
printf "DONE config=08 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=10 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_fanta_248traj_4workers.json \
--eval-subdir ${SUBDIR_PREFIX}basket_fanta_train${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/pi05_parallel_20261002_105333_config10.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config10.log" || true)" != 1 ]; then echo "Incomplete result for config 10" >&2; exit 3; fi
printf "DONE config=10 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=15 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/move_from_board_to_board_vanish \
--json-path demo_envs/move_from_board_to_board_vanish/demos/motionplanning/move_from_board_to_board_vanish_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_vanish_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD > "logs/pi05_parallel_20261002_105333_config15.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config15.log" || true)" != 1 ]; then echo "Incomplete result for config 15" >&2; exit 3; fi
printf "DONE config=15 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=19 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/close_showcase/ \
--json-path demo_envs/close_showcase/demos/motionplanning/close_showcase_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_showcase_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC > "logs/pi05_parallel_20261002_105333_config19.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config19.log" || true)" != 1 ]; then echo "Incomplete result for config 19" >&2; exit 3; fi
printf "DONE config=19 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=22 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_fanta_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_fanta_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/pi05_parallel_20261002_105333_config22.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config22.log" || true)" != 1 ]; then echo "Incomplete result for config 22" >&2; exit 3; fi
printf "DONE config=22 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=26 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardNestleContEnv \
--scene-dir demo_envs/test_unseen_scenes_move_from_board_to_board_nestle \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_nestle_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config26.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config26.log" || true)" != 1 ]; then echo "Incomplete result for config 26" >&2; exit 3; fi
printf "DONE config=26 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=28 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e OpenDoorFridgeContEnv \
--scene-dir demo_envs/open_fridge/ \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}open_fridge_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config28.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config28.log" || true)" != 1 ]; then echo "Incomplete result for config 28" >&2; exit 3; fi
printf "DONE config=28 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=35 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContNiveaEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_nivea_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config35.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config35.log" || true)" != 1 ]; then echo "Incomplete result for config 35" >&2; exit 3; fi
printf "DONE config=35 at %s\n" "$(date -u +%FT%TZ)"

printf "START config=37 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardNiveaContEnv \
--scene-dir demo_envs/test_unseen_items_move_from_board_to_board_nivea \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_nivea_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/pi05_parallel_20261002_105333_config37.log" 2>&1
if [ "$(rg -c "Results:" "logs/pi05_parallel_20261002_105333_config37.log" || true)" != 1 ]; then echo "Incomplete result for config 37" >&2; exit 3; fi
printf "DONE config=37 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
