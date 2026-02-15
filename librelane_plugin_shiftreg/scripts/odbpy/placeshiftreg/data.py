import re
from .row import Row
from .placeable import Placeable

from odb import dbInst as Instance

from typing import Callable, List, Dict, Union


class Shiftreg(Placeable):
    def __init__(self, instances: List[Instance], width: int, depth: int):
        self.clkbuf = None

        self.width = width
        self.depth = depth
        self.bits = [[None] * depth for _ in range(width)]
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].genblk1\\\[(\d+)\\\].sreg_dff')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                w = int(m.group(1))
                d = int(m.group(2))
                self.bits[w][d] = instance

        self.dly = [[None] * (depth-1) for _ in range(width)]
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].genblk2\\\[(\d+)\\\].sreg_dly')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                w = int(m.group(1))
                d = int(m.group(2))
                self.dly[w][d] = instance

        self.clkbufs = [[None] * (depth // 25) for _ in range(width)]
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].genblk3\\\[(\d+)\\\].sreg_clkbuf')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                w = int(m.group(1))
                d = int(m.group(2))
                self.clkbufs[w][d] = instance

        # tapcells
        self.taps = []
        for instance in instances:
            if instance.getMaster().getName() == 'sky130_fd_sc_hd__tapvpwrvgnd_1':
                self.taps.append(instance)

    def place(self, rows: List[Row], start_row: int = 0):
        min_width = 460
        ff_width  = self.bits[0][0].getMaster().getWidth()
        dly_width = self.dly[0][0].getMaster().getWidth()
        clkbuf_width = self.clkbufs[0][0].getMaster().getWidth()
        r = start_row
        for row in rows:
            row.add_tap_cells(self.taps)

        for w in range(self.width):
            clock_buffer = 0
            clk_buf_idx = 0
            for d in range(self.depth):
                # place flipflop
                if rows[r].width + ff_width >= 158240 - 1380 - 1380 - 2760: 
                    r += 1
                rows[r].place(self.bits[w][d], fixed=True)

                rows[r].x += min_width

                # place delay
                if d != self.depth-1:
                    if rows[r].width + dly_width >= 158240 - 1380 - 1380 - 2760: 
                        r += 1
                    rows[r].place(self.dly[w][d], fixed=True)

                # place clock buffer
                clock_buffer += 1
                if clock_buffer == 25:
                    clock_buffer = 0
                    if rows[r].width + clkbuf_width >= 158240 - 1380 - 1380 - 2760: 
                        r += 1
                    rows[r].place(self.clkbufs[w][clk_buf_idx], fixed=True)
                    clk_buf_idx += 1


                # 158240: end
                # 2760: start
                # 1380: endcap size
                # 0460: tapcell size

        return r + 1