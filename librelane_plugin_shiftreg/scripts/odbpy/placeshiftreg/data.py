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
        self.clkbuf = None

        self.clk_ratio = 13
        self.width = width
        self.depth = depth
        self.bits = [[None] * depth for _ in range(width)]
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].genblk1\\\[(\d+)\\\].genblk1.sreg_dff')
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

        self.tiehi = [[None] * depth for _ in range(width)]
        regex = re.compile(r'.*genblk1\\\[(\d+)\\\].genblk1\\\[(\d+)\\\].sreg_high')
        for instance in instances:
            m = regex.match(instance.getName())
            if m:
                w = int(m.group(1))
                d = int(m.group(2))
                self.tiehi[w][d] = instance

        self.fills = []
        regex = re.compile(r'.*.sreg_fill_to_be_removed.*')
        for instance in instances:
            if 'sreg_fill_to_be_removed' in instance.getName():
                self.fills.append(instance)

        self.mode = 'remove_fills' if self.fills else 'place'

        #self.clkbufs = [[None] * (depth // self.clk_ratio) for _ in range(width)]
        #regex = re.compile(r'.*genblk1\\\[(\d+)\\\].genblk3\\\[(\d+)\\\].sreg_clkbuf')
        #for instance in instances:
        #    m = regex.match(instance.getName())
        #    if m:
        #        w = int(m.group(1))
        #        d = int(m.group(2))
        #        self.clkbufs[w][d] = instance

        # tapcells
        self.taps = []
        for instance in instances:
            if instance.getMaster().getName() == 'sky130_fd_sc_hd__tapvpwrvgnd_1':
                self.taps.append(instance)

    def place(self, rows: List[Row], start_row: int = 0):
        if self.mode == 'remove_fills':
            self.replace_fills()
            return 0

        print('start')
        lib = self.db.getLibs()[0]
        chip = self.db.getChip()
        block = chip.getBlock()
        dff_master = self.bits[0][0].getMaster()
        dly_master = lib.findMaster('sg13g2_dlygate4sd3_1')
        dly_master = lib.findMaster('sg13g2_fill_1')

        print('create')
        #for w in range(self.width):
        #    for d in range(self.depth-1):
        #        prev = self.bits[w][d]
        #        next = self.bits[w][d+1]
        #        inst = odb.dbInst.create(block, dly_master, f'dly_{w}_{d}')
        #        self.dly[w][d] = inst
        #        continue
#
        #        q = prev.findITerm('Q')
        #        d = next.findITerm('D')
        #        a = inst.findITerm('A')
        #        x = inst.findITerm('X')
        #        q.disconnect()
        #        net0 = odb.dbNet.create(block, f'net0_{w}_{d}')
        #        net1 = odb.dbNet.create(block, f'net1_{w}_{d}')
        #        q.connect(net0)
        #        a.connect(net0)
        #        d.connect(net1)
        #        x.connect(net1)
        #inst.setLocation(*inst.getLocation())
        #inst.setOrient(inst.getOrient())
        #inst.setPlacementStatus(inst.getPlacementStatus())

        print('nets')
        #for iterm in inst.getITerms():
        #    print(iterm.getName())
        #    print(iterm.getMTerm().getName())
        #    net = iterm.getNet()
        #    if net:
        #        print(net.getName())
        #        # Match by pin name
        #        new_iterm = new_inst.findITerm(iterm.getMTerm().getName())
        #        if new_iterm:
        #            new_iterm.connect(net)


        # 4320


        min_width = 480
        hi_width  = self.tiehi[0][0].getMaster().getWidth() # 
        ff_width  = self.bits[0][0].getMaster().getWidth() # 7360
        dly_width = 4320 #self.dly[0][0].getMaster().getWidth() # 3680
        clkbuf_width = 6240 #self.clkbufs[0][0].getMaster().getWidth() # 6240
        r = start_row
        for row in rows:
            row.add_tap_cells(self.taps)

        row_max = 202080 - 2880 * 2

        for w in range(self.width):
            clock_buffer = 0
            clk_buf_idx = 0
            tie_high_idx = 0
            for d in range(self.depth):
                print(r)
                # place tiehi
                if self.tiehi[w][d]:
                    hi_width  = self.tiehi[w][d].getMaster().getWidth()
                    if r > 0 and rows[r-1].width + hi_width >= row_max: 
                        rows[r-1].place(self.tiehi[w][d], fixed=True)
                    elif rows[r].width + hi_width >= row_max: 
                        r += 1
                        rows[r].place(self.tiehi[w][d], fixed=True)
                    else:
                        rows[r].place(self.tiehi[w][d], fixed=True)
            
                # place flipflop
                ff_width  = self.bits[w][d].getMaster().getWidth()
                if rows[r].width + ff_width >= row_max: 
                    r += 1
                rows[r].place(self.bits[w][d], fixed=True)

                # place delay placeholders
                #if d != self.depth-1:
                #    if rows[r].width + dly_width + tap_width >= row_max: 
                #        r += 1
                #    for i in range(9):
                #        inst = odb.dbInst.create(block, dly_master, f'sreg_fill_to_be_removed_{w}_{d}_{i}')
                #        rows[r].place(inst, fixed=True)


                # place delay
                if d != self.depth-1:
                    dly_width2  = self.dly[w][d].getMaster().getWidth()
                    if rows[r].width + dly_width >= row_max: 
                        r += 1
                    rows[r].place(self.dly[w][d], fixed=True)
                    # placeholders
                    for i in range((dly_width - dly_width2) // min_width):
                        inst = odb.dbInst.create(block, dly_master, f'sreg_fill_to_be_removed_{w}_{d}_{i}')
                        rows[r].place(inst, fixed=True)

                # place clock buffer
                clock_buffer += 1
                if clock_buffer == self.clk_ratio:# and clk_buf_idx < len(self.clkbufs[w]):
                    clock_buffer = 0
                if clock_buffer == self.clk_ratio//2:# and clk_buf_idx < len(self.clkbufs[w]):
                    if rows[r].width + clkbuf_width >= row_max: 
                        r += 1
                    # placeholders
                    for i in range(clkbuf_width // min_width):
                        inst = odb.dbInst.create(block, dly_master, f'sreg_fill_to_be_removed_clk_{w}_{d}_{i}')
                        rows[r].place(inst, fixed=True)
                   # rows[r].place(None, fixed=True)
                #    rows[r].place(self.clkbufs[w][clk_buf_idx], fixed=True)
                    #rows[r].x += clkbuf_width
                    #rows[r].since_last_tap += clkbuf_width
                    clk_buf_idx += 1


                # 158240: end
                # 2760: start
                # 1380: endcap size
                # 480: tapcell size

        return r + 1
    
    def replace_fills(self):
        lib = self.db.getLibs()[0]
        chip = self.db.getChip()
        block = chip.getBlock()
        dly_master = lib.findMaster('sg13g2_dlygate4sd3_1')

        for fill in self.fills:
            odb.dbInst.destroy(fill)

        for w in range(self.width):
            for d in range(self.depth-1):
                dly = self.dly[w][d]
                prev = self.bits[w][d]
                next = self.bits[w][d+1]
                inst = odb.dbInst.create(block, dly_master, f'dly2_{w}_{d}')
                q = prev.findITerm('Q')
                d = next.findITerm('D')
                a = inst.findITerm('A')
                x = inst.findITerm('X')
                #q.disconnect()
                #d.disconnect()
                net0 = q.getNet()#odb.dbNet.create(block, f'net0_{w}_{d}')
                net1 = d.getNet()#odb.dbNet.create(block, f'net1_{w}_{d}')
                #q.connect(net0)
                a.connect(net0)
                #d.connect(net1)
                x.connect(net1)
                inst.setOrient(dly.getOrient())
                inst.setLocation(*dly.getLocation())
                inst.setPlacementStatus(dly.getPlacementStatus())
                odb.dbInst.destroy(dly)


    def replace_all(self):
        print('replace')
        return
        for a in self.dly:
            for b in a:
                self.replace(b)


    def replace(self, inst):
        name = inst.getName()
        print(f'replace {name}')

        # Get the database and library
        db = self.db
        chip = db.getChip()
        block = chip.getBlock()

        lib = None
        for lib in db.getLibs():
            master_cell = lib.findMaster('sg13g2_dlygate4sd3_1')
            if master_cell:
                break
        if not master_cell:
            print('didnt find cell')

        # Create new instance
        new_inst = odb.dbInst.create(block, master_cell, name + "_new")

        # Copy placement
        new_inst.setLocation(*inst.getLocation())
        new_inst.setOrient(inst.getOrient())
        new_inst.setPlacementStatus(inst.getPlacementStatus())

        # Reconnect nets
        for iterm in inst.getITerms():
            net = iterm.getNet()
            if net:
                # Match by pin name
                new_iterm = new_inst.findITerm(iterm.getMTerm().getName())
                if new_iterm:
                    new_iterm.connect(net)

        # Delete old instance
        odb.dbInst.destroy(inst)

        # Rename new instance
        new_inst.rename(name)
        print(f'replaced')
