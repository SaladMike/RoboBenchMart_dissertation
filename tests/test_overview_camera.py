import unittest

import numpy as np

from scripts.show_env_in_sim import overview_camera_pose


class OverviewCameraTests(unittest.TestCase):
    def test_whole_room_stays_in_frame_throughout_orbit(self):
        tan_y = np.tan(np.deg2rad(60) / 2)
        tan_x = tan_y * 1280 / 720
        for size in ([12, 10, 2.7], [30, 5, 4], [5, 30, 4], [4, 4, 8]):
            corners = np.array([
                [x, y, z, 1]
                for x in (0, size[0])
                for y in (0, size[1])
                for z in (0, size[2])
            ])
            for frame in range(32):
                with self.subTest(size=size, frame=frame):
                    pose = overview_camera_pose(size, frame, 32).sp
                    local = corners @ np.linalg.inv(pose.to_transformation_matrix()).T
                    depth = local[:, 0]
                    self.assertTrue(np.all(depth > 0.1))
                    occupancy = np.maximum(
                        np.abs(local[:, 1]) / depth / tan_x,
                        np.abs(local[:, 2]) / depth / tan_y,
                    )
                    self.assertLess(occupancy.max(), 1)
                    self.assertGreater(occupancy.max(), 0.65)
                    self.assertGreater(pose.p[2], size[2])

    def test_orbit_moves_and_returns_to_start(self):
        start = overview_camera_pose([12, 10, 2.7], 0, 900).sp.p
        quarter = overview_camera_pose([12, 10, 2.7], 225, 900).sp.p
        end = overview_camera_pose([12, 10, 2.7], 900, 900).sp.p
        self.assertGreater(np.linalg.norm(start - quarter), 1)
        np.testing.assert_allclose(start, end, atol=1e-5)


if __name__ == '__main__':
    unittest.main()
