import sapien
import sys
import json
import gymnasium as gym
import torch
from tqdm import tqdm
import argparse
import os
from pathlib import Path
import time 
import hydra
from datetime import datetime
import imageio.v2 as imageio
import numpy as np

import mani_skill.envs
from mani_skill.sensors.camera import Camera, CameraConfig
from mani_skill.utils import sapien_utils
from mani_skill.utils.wrappers import RecordEpisode

import sys 
sys.path.append('.')
from dsynth.envs import *
from dsynth.robots import *

def parse_args():
    parser = argparse.ArgumentParser(
        description="Использование: python script.py <путь_к_JSON_файлу> <путь_к_assets> <style id (0-11)> [mapping_file]"
    )
    parser.add_argument("scene_dir", help="Путь к директории с JSON конфигом сцены")
    parser.add_argument("-e", "--env-id", type=str, default="DarkstoreContinuousBaseEnv", help=f"Environment to run")
    parser.add_argument("-r", "--robot-uids", type=str, default="ds_fetch_basket", help=f"Robot id")
    parser.add_argument("-n", "--num-envs", type=int, default=1, help=f"Number of scenes")
    parser.add_argument("-s", "--seed", type=int, nargs='+', default=0)
    parser.add_argument('--shader',
                        default='default',
                        const='default',
                        nargs='?',
                        choices=['rt', 'rt-fast', 'rt-med', 'default', 'minimal'],)
    parser.add_argument('--sensor_shader',
                        default='minimal',
                        const='minimal',
                        nargs='?',
                        choices=['rt', 'rt-fast', 'rt-med', 'default', 'minimal'],)
    parser.add_argument('--gui',
                        action='store_true',
                        default=False)
    parser.add_argument('--episode_length', type=int, default=10)
    parser.add_argument('--overview', action='store_true',
                        help='Record an elevated orbit of the whole store without stepping physics')
    parser.add_argument('--video',
                        action='store_true',
                        default=False)

    args = parser.parse_args()
    if args.episode_length < 1:
        parser.error('--episode_length must be positive')
    if args.overview and (args.gui or args.num_envs != 1 or not args.video):
        parser.error('--overview requires --video, --num-envs 1, and no --gui')

    return args

def overview_camera_pose(size, frame, total_frames):
    size = np.asarray(size, dtype=float)
    center = size / 2
    elevation = np.deg2rad(65)
    angle = 2 * np.pi * frame / total_frames - np.pi / 2
    direction = np.array([
        np.cos(elevation) * np.cos(angle),
        np.cos(elevation) * np.sin(angle),
        np.sin(elevation),
    ])
    right = np.array([-np.sin(angle), np.cos(angle), 0])
    up = np.cross(direction, right)
    corners = np.array([
        [x, y, z] for x in (-1, 1) for y in (-1, 1) for z in (-1, 1)
    ]) * (size / 2 + 0.2)
    tan_y = np.tan(np.deg2rad(60) / 2)
    tan_x = tan_y * 1280 / 720
    # Fit every room corner in the perspective frustum, with a small border.
    depth_offsets = corners @ direction
    distance = max(
        np.max(np.abs(corners @ right) / tan_x + depth_offsets),
        np.max(np.abs(corners @ up) / tan_y + depth_offsets),
    ) * 1.08
    return sapien_utils.look_at(center + distance * direction, center)


def record_overview(env, args):
    base_env = env.unwrapped
    builder = base_env.scene_builder
    size = np.array([builder.x_size[0], builder.y_size[0], builder.height[0]])
    fov = np.deg2rad(60)

    # Hide only render components; retain the room geometry and collision state.
    hidden_actors = []
    for data in builder.scene_data:
        for name, fixture in data['fixtures'].items():
            if name.startswith(('ceiling', 'wall')) and hasattr(fixture, 'actor'):
                hidden_actors.append(fixture.actor)
    hidden_actors.extend(base_env.actors['fixtures']['lamps'].values())
    for actor in hidden_actors:
        for entity in actor._objs:
            body = entity.find_component_by_type(sapien.render.RenderBodyComponent)
            if body is not None:
                body.visibility = 0

    camera = Camera(CameraConfig(
        uid='overview', pose=overview_camera_pose(size, 0, args.episode_length),
        width=1280, height=720, fov=fov, near=0.1,
        far=max(100, np.linalg.norm(size) * 10), shader_pack=args.shader,
    ), base_env.scene)
    base_env.scene.human_render_cameras = {'overview': camera}
    seeds = args.seed if isinstance(args.seed, list) else [args.seed]
    seed_label = '_'.join(map(str, seeds))
    output_dir = Path(args.scene_dir) / f'overview_seed={seed_label}'
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / datetime.now().strftime('overview_%Y%m%d_%H%M%S_%f.mp4')
    print('Overview video:', output_path.resolve(), flush=True)
    print(f'Room size: {size.tolist()}, frames: {args.episode_length}, FPS: 30', flush=True)

    # Stream frames to the encoder instead of retaining the whole video in RAM.
    with imageio.get_writer(str(output_path), fps=30, codec='libx264', quality=8) as writer:
        for frame_index in tqdm(range(args.episode_length), desc='Overview'):
            camera.camera.set_local_pose(
                overview_camera_pose(size, frame_index, args.episode_length).sp
            )
            frame = base_env.render_rgb_array(camera_name='overview')
            if isinstance(frame, torch.Tensor):
                frame = frame.cpu().numpy()
            if frame.ndim == 4:
                frame = frame[0]
            writer.append_data(frame)
    print('Overview saved:', output_path.resolve(), flush=True)

def main(args):

    scene_dir = Path(args.scene_dir)
    gui = args.gui
    parallel_in_single_scene = args.num_envs > 1 and gui
    env = gym.make(args.env_id, 
                   robot_uids=args.robot_uids, 
                   config_dir_path = args.scene_dir,
                   num_envs=args.num_envs, 
                   viewer_camera_configs={'shader_pack': args.shader}, 
                    human_render_camera_configs={'shader_pack': args.shader},
                    sensor_configs={'shader_pack': args.sensor_shader},
                   render_mode="human" if gui else "rgb_array", 
                #    render_mode="rgb_array", 
                   control_mode=None,
                   enable_shadow=True,
                   sim_config={'spacing': 20},
                   obs_mode='none' if gui or args.overview else "rgbd",
                   sim_backend='cpu' if args.overview else 'auto',
                   parallel_in_single_scene = parallel_in_single_scene,
                   )

    if args.overview:
        try:
            env.reset(seed=args.seed, options={'reconfigure': True})
            record_overview(env, args)
        finally:
            env.close()
        return

    new_traj_name = time.strftime("%Y%m%d_%H%M%S")
    video_path = scene_dir / f"./videos_seed={args.seed}_shader={args.shader}_sensor_shader={args.sensor_shader}"
    env = RecordEpisode(
        env,
        output_dir=video_path,
        trajectory_name=new_traj_name,
        save_video=args.video,
        video_fps=30,
        avoid_overwriting_video=True,
        max_steps_per_video=args.episode_length
    )

    print("Video path:", video_path)
    print("Trajectoty name:", new_traj_name)

    env.reset(seed=args.seed, options={'reconfigure': True})

    if gui:
        viewer = env.render()
        if isinstance(viewer, sapien.utils.Viewer):
            viewer.paused = True
        # env.render()


    for i in tqdm(range(args.episode_length)):
        action = torch.from_numpy(env.action_space.sample())
        # action = torch.zeros_like(torch.from_numpy(env.action_space.sample()))
        obs, reward, terminated, truncated, info = env.step(action)
        print(info)
        if gui:
            env.render()

    # render wait
    if gui:
        viewer = env.render()
        while True:
            if viewer.closed:
                exit()
            if viewer.window.key_down("c"):
                break
            env.render()
        

    env.close()


if __name__ == '__main__':
    args = parse_args()
    main(args)
