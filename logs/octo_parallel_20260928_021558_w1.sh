#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/octo_parallel_20260928_021558_w1.exit"' EXIT
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

NET_PARAMS="--host=127.0.0.1 --port=8001"
EVAL_PARAMS_BOARD="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FRIDGE="--max-horizon 500 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_SHOWC="--max-horizon 1000 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FLOOR="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_BASKET="--max-horizon 600 --num-traj ${NUM_TRAJ} --save-video"

#TRAIN
# =========================================================
# move_from_board_to_board
# =========================================================
printf "START config=19 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/close_showcase/ \
--json-path demo_envs/close_showcase/demos/motionplanning/close_showcase_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_showcase_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC > "logs/octo_parallel_20260928_021558_config19.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config19.log" || true)" != 1 ]; then echo "Incomplete result for config 19" >&2; exit 3; fi
printf "DONE config=19 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=21 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_from_floor/ \
--json-path demo_envs/pick_from_floor/demos/motionplanning/pick_from_floor_slam_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_slam_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR > "logs/octo_parallel_20260928_021558_config21.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config21.log" || true)" != 1 ]; then echo "Incomplete result for config 21" >&2; exit 3; fi
printf "DONE config=21 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=32 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorBeansContEnv \
--scene-dir demo_envs/test_unseen_scenes_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_beans_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/octo_parallel_20260928_021558_config32.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config32.log" || true)" != 1 ]; then echo "Incomplete result for config 32" >&2; exit 3; fi
printf "DONE config=32 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=34 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContFantaEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_fanta_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/octo_parallel_20260928_021558_config34.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config34.log" || true)" != 1 ]; then echo "Incomplete result for config 34" >&2; exit 3; fi
printf "DONE config=34 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=39 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickFromFloorFantaContEnv \
--scene-dir demo_envs/test_unseen_items_pick_from_floor \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}floor_fanta_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_FLOOR --start-seed 42000 > "logs/octo_parallel_20260928_021558_config39.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config39.log" || true)" != 1 ]; then echo "Incomplete result for config 39" >&2; exit 3; fi
printf "DONE config=39 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=42 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContSlamEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_slam_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/octo_parallel_20260928_021558_config42.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config42.log" || true)" != 1 ]; then echo "Incomplete result for config 42" >&2; exit 3; fi
printf "DONE config=42 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
