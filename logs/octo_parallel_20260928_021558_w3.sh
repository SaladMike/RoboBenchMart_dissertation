#!/usr/bin/env bash
set -Ee -o pipefail
cd /root/autodl-tmp/RoboBenchMart_dissertation
trap 'rc=$?; printf "%s\n" "$rc" > "logs/octo_parallel_20260928_021558_w3.exit"' EXIT
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

NET_PARAMS="--host=127.0.0.1 --port=8003"
EVAL_PARAMS_BOARD="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FRIDGE="--max-horizon 500 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_SHOWC="--max-horizon 1000 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_FLOOR="--max-horizon 750 --num-traj ${NUM_TRAJ} --save-video"
EVAL_PARAMS_BASKET="--max-horizon 600 --num-traj ${NUM_TRAJ} --save-video"

#TRAIN
# =========================================================
# move_from_board_to_board
# =========================================================
printf "START config=22 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_fanta_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_fanta_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/octo_parallel_20260928_021558_config22.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config22.log" || true)" != 1 ]; then echo "Incomplete result for config 22" >&2; exit 3; fi
printf "DONE config=22 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=23 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
--scene-dir demo_envs/pick_to_basket \
--json-path demo_envs/pick_to_basket/demos/motionplanning/pick_to_basket_nivea_248traj_4workers.json \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_nivea_robo${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET > "logs/octo_parallel_20260928_021558_config23.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config23.log" || true)" != 1 ]; then echo "Incomplete result for config 23" >&2; exit 3; fi
printf "DONE config=23 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=26 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardNestleContEnv \
--scene-dir demo_envs/test_unseen_scenes_move_from_board_to_board_nestle \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_nestle_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/octo_parallel_20260928_021558_config26.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config26.log" || true)" != 1 ]; then echo "Incomplete result for config 26" >&2; exit 3; fi
printf "DONE config=26 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=31 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e CloseDoorShowcaseContEnv \
--scene-dir demo_envs/close_showcase// \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}close_showcase_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_SHOWC --start-seed 42000 > "logs/octo_parallel_20260928_021558_config31.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config31.log" || true)" != 1 ]; then echo "Incomplete result for config 31" >&2; exit 3; fi
printf "DONE config=31 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=36 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e PickToBasketContStarsEnv \
--scene-dir demo_envs/test_unseen_items_pick_to_basket \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}basket_stars_uns${SUBDIR_SUFFIX} $EVAL_PARAMS_BASKET --start-seed 42000 > "logs/octo_parallel_20260928_021558_config36.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config36.log" || true)" != 1 ]; then echo "Incomplete result for config 36" >&2; exit 3; fi
printf "DONE config=36 at %s\n" "$(date -u +%FT%TZ)"
printf "START config=37 at %s\n" "$(date -u +%FT%TZ)"
python "$EVAL_SCRIPT" $NET_PARAMS \
-e MoveFromBoardToBoardNiveaContEnv \
--scene-dir demo_envs/test_unseen_items_move_from_board_to_board_nivea \
--robot-init-pose-start-seed 10000 --eval-subdir ${SUBDIR_PREFIX}board_nivea_ood${SUBDIR_SUFFIX} $EVAL_PARAMS_BOARD --start-seed 42000 > "logs/octo_parallel_20260928_021558_config37.log" 2>&1
if [ "$(rg -c "Results:" "logs/octo_parallel_20260928_021558_config37.log" || true)" != 1 ]; then echo "Incomplete result for config 37" >&2; exit 3; fi
printf "DONE config=37 at %s\n" "$(date -u +%FT%TZ)"
printf "WORKER_DONE at %s\n" "$(date -u +%FT%TZ)"
