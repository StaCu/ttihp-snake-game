import re
from .row import Row

import openroad as ord
import odb
from odb import dbInst as Instance

from typing import Callable, List, Dict, Union


def dbInst__repr__(self):
    return f"<dbInst {self.getMaster().getName()} {self.getName()}>"


Instance.__repr__ = dbInst__repr__


class Shiftreg(object):
    def __init__(self, db, instances: List[Instance], width: int, depth: int):
        self.db = db
        self.clk_ratio = 8
        self.tiehi_ratio = 4
        self.width = width
        self.depth = depth

        # find the different cells belonging to the shiftreg
        self.bits = [[None] * depth for _ in range(width)]
        regex = re.compile(r'.*genblk2\\\[(\d+)\\\].genblk1\\\[(\d+)\\\].genblk1.sreg_dff')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                w = int(m.group(1))
                d = int(m.group(2))
                self.bits[w][d] = instance

        self.dly = [[None] * (depth-1) for _ in range(width)]
        regex = re.compile(r'.*genblk2\\\[(\d+)\\\].genblk2\\\[(\d+)\\\].sreg_dly')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                w = int(m.group(1))
                d = int(m.group(2))
                self.dly[w][d] = instance

        self.tiehi = [None] * depth
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].sreg_high')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                d = int(m.group(1))
                self.tiehi[d] = instance

        self.tiehibuf = [None] * depth
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].sreg_bufhigh')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                d = int(m.group(1))
                self.tiehibuf[d] = instance

        self.fills = []
        regex = re.compile(r'.*.sreg_fill_to_be_removed.*')
        for instance in instances:
            if 'sreg_fill_to_be_removed' in instance.getName():
                self.fills.append(instance)

        self.mode = 'repair' if self.fills else 'place'

    def next_row(self, r: int, direction: int):
        # placement pattern:
        # - start at row 40
        # - go down in pairs of 2 (left to right, right to left, skip 2 rows)
        # - flip at bottom and go up in pairs of 2 (left to right, right to left, skip 2 rows)
        # - when over 40, stop skipping rows
        if direction < 0:
            if r % 2 == 0:
                r -= 1
            else:
                r -= 3
            if r < 0:
                r = 1
                direction = 1
        else:
            if r % 2 == 0 and r < 40:
                r += 3
            else:
                r += 1
        return r, direction

    def place(self, rows: List[Row], start_row: int = 0):
        if self.mode == 'repair':
            self.repair()
            return 0

        # get blueprint for the filler cell we need to instantiate
        lib = self.db.getLibs()[0]
        chip = self.db.getChip()
        block = chip.getBlock()
        dly_master = lib.findMaster('sg13g2_fill_1')

        min_width = 480
        hi_width  = self.tiehi[0].getMaster().getWidth()
        ff_width  = self.bits[0][0].getMaster().getWidth() # 7360
        dly_width = 4320
        clkbuf_width = 6240
        r = start_row
        row_max = 202080 - 2880 * 2

        r = 40
        direction = -1
        clock_buffer = 0
        tie_high = 0
        for d in range(self.depth):
            tie_high += 2
            if tie_high == self.tiehi_ratio:
                tie_high = 0

            # place tiehi
            if tie_high == self.tiehi_ratio//2:
                d2 = d // (self.tiehi_ratio//2)
                if self.tiehi[d2]:
                    # tiehi
                    hi_width  = self.tiehi[d2].getMaster().getWidth()
                    if rows[r].width + hi_width >= row_max:
                        r, direction = self.next_row(r, direction)
                    rows[r].place(self.tiehi[d2], fixed=True)
                    # buf
                    hi_width_buf  = self.tiehibuf[d2].getMaster().getWidth()
                    if rows[r].width + hi_width_buf >= row_max:
                        r, direction = self.next_row(r, direction)
                    rows[r].place(self.tiehibuf[d2], fixed=True)

            for w in range(self.width):
                # place flipflop
                ff_width  = self.bits[w][d].getMaster().getWidth()
                if rows[r].width + ff_width >= row_max: 
                    r, direction = self.next_row(r, direction)
                rows[r].place(self.bits[w][d], fixed=True)

                # place delay
                if d != self.depth-1:
                    dly_width2  = self.dly[w][d].getMaster().getWidth()

                    if rows[r].width + dly_width >= row_max:
                        r, direction = self.next_row(r, direction)

                    # depending of the zig-zag direction, we must place the buffer before or after the fillers
                    # to ensure it is always on their left side.
                    if r % 2 == 0:
                        rows[r].place(self.dly[w][d], fixed=True)
                    # placeholders
                    for i in range((dly_width - dly_width2) // min_width):
                        inst = odb.dbInst.create(block, dly_master, f'sreg_fill_to_be_removed_{w}_{d}_{i}')
                        rows[r].place(inst, fixed=True)
                    if r % 2 == 1:
                        rows[r].place(self.dly[w][d], fixed=True)

            # place clock buffer
            clock_buffer += 2
            if clock_buffer == self.clk_ratio:
                clock_buffer = 0
            if clock_buffer == self.clk_ratio//2:
                if rows[r].width + clkbuf_width >= row_max:
                    r, direction = self.next_row(r, direction)
                # placeholders
                for i in range(clkbuf_width // min_width):
                    inst = odb.dbInst.create(block, dly_master, f'sreg_fill_to_be_removed_clk_{w}_{d}_{i}')
                    rows[r].place(inst, fixed=True)

        return r + 1
    
    def repair(self):
        # get blueprint for the delay gate we need to instantiate
        lib = self.db.getLibs()[0]
        chip = self.db.getChip()
        block = chip.getBlock()
        dly_master = lib.findMaster('sg13g2_dlygate4sd3_1')

        # remove fillers
        for fill in self.fills:
            odb.dbInst.destroy(fill)

        # replace sg13g2_buf_1 with sg13g2_dlygate4sd3_1
        for w in range(self.width):
            for d in range(self.depth-1):
                dly = self.dly[w][d]
                prev = self.bits[w][d]
                next = self.bits[w][d+1]
                # create delay gate
                inst = odb.dbInst.create(block, dly_master, f'dly2_{w}_{d}')

                # connect it to the flipflop before and after
                q = prev.findITerm('Q')
                d = next.findITerm('D')
                a = inst.findITerm('A')
                x = inst.findITerm('X')
                net0 = q.getNet()
                net1 = d.getNet()
                a.connect(net0)
                x.connect(net1)

                # place it in right spot
                inst.setOrient(dly.getOrient())
                inst.setLocation(*dly.getLocation())
                inst.setPlacementStatus(dly.getPlacementStatus())

                # delete old buffer
                odb.dbInst.destroy(dly)
