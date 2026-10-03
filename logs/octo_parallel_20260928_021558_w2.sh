#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/octo_parallel_20260928_021558_w2.exit"' EXIT
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

# Required: --model {octo|pi0|pi05}
MODEL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model)
      MODEL="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$MODEL" ]]; then
  echo "Error: --model is required (octo|pi0|pi05)" >&2
  exit 1
fi

if [[ "$MODEL" != "octo" && "$MODEL" != "pi0" && "$MODEL" != "pi05" ]]; then
  echo "Error: --model must be one of: octo, pi0, pi05" >&2
  exit 1
fi

EVAL_SCRIPT="scripts/eval_policy_client.py"

RUN_TS=$(date +%Y%m%d_%H%M%S)
SUBDIR_PREFIX="${MODEL}_"
SUBDIR_SUFFIX="_${RUN_TS}"

NUM_TRAJ=30

NET_PARAMS="--host=127.0.0.1 --port=8002"
EVAL_PARAMS_BOARD="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FRIDGE="--max-horizon 500 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_SHOWC="--max-horizon 1000 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FLOOR="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_BASKET="--max-horizon 600 --num-traj ${NUM_TRAJ} --save-video"

#TRAIN
# =========================================================
# move_from_board_to_board
# =========================================================
printf "START config=25 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardDuffContEnv \
--scene-dir demo_envs/test_unseen_scenes_move_from_board_to_board_duff \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_duff_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/octo_parallel_20260928_021558_config25.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config25.log" || true)" != 1 ]; then echo "Incomplete result for config 25" >&2; exit 3; fi
printf "DONE config=25 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=28 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e OpenDoorFridgeContEnv \
--scene-dir demo_envs/open_fridge/ \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}open_fridge_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE --start-seed 42000 > "logs/octo_parallel_20260928_021558_config28.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config28.log" || true)" != 1 ]; then echo "Incomplete result for config 28" >&2; exit 3; fi
printf "DONE config=28 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=29 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e CloseDoorFridgeContEnv \
--scene-dir demo_envs/close_fridge/ \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_fridge_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FRIDGE --start-seed 42000 > "logs/octo_parallel_20260928_021558_config29.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config29.log" || true)" != 1 ]; then echo "Incomplete result for config 29" >&2; exit 3; fi
printf "DONE config=29 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=30 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e OpenDoorShowcaseContEnv \
--scene-dir demo_envs/open_showcase/ \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}open_showcase_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC --start-seed 42000 > "logs/octo_parallel_20260928_021558_config30.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config30.log" || true)" != 1 ]; then echo "Incomplete result for config 30" >&2; exit 3; fi
printf "DONE config=30 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=33 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorSlamContEnv \
--scene-dir demo_envs/test_unseen_scenes_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_slam_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/octo_parallel_20260928_021558_config33.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config33.log" || true)" != 1 ]; then echo "Incomplete result for config 33" >&2; exit 3; fi
printf "DONE config=33 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=35 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContNiveaEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_nivea_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/octo_parallel_20260928_021558_config35.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config35.log" || true)" != 1 ]; then echo "Incomplete result for config 35" >&2; exit 3; fi
printf "DONE config=35 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=40 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorDuffContEnv \
--scene-dir demo_envs/test_unseen_items_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_duff_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/octo_parallel_20260928_021558_config40.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config40.log" || true)" != 1 ]; then echo "Incomplete result for config 40" >&2; exit 3; fi
printf "DONE config=40 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
