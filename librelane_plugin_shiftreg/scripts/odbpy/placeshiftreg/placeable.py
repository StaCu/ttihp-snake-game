# -*- coding: utf8 -*-
# SPDX-License-Identifier: Apache-2.0
# Copyright ©2020-2022, The American University in Cairo
import os
import re
import sys
import yaml
from odb import dbInst as Instance
from typing import List, Dict, Union, TextIO, Optional

from .row import Row


def dbInst__repr__(self):
    return f"<dbInst {self.getMaster().getName()} {self.getName()}>"


Instance.__repr__ = dbInst__repr__



class Placeable(object):

    class Sieve(object):
        def __init__(
            self,
            variable: str,
            groups: List[str] = [],
            group_rx_order=None,
            custom_behavior=None,
        ):
            self.variable = variable
            self.groups = groups
            self.groups_rx_order = group_rx_order or list(range(1, len(groups) + 1))
            self.custom_behavior = custom_behavior

    def place(self, row_list: List[Row], start_row: int = 0) -> int:
        """
        Returns the index of the row after the current one
        """
        raise Exception("Method unimplemented.")

    def represent(self, tab_level: int = -1, file: TextIO = sys.stderr):
        for variable in self.__dict__:
            print(variable, file=file)

    @staticmethod
    def represent_instance(
        name: str, instance: Instance, tab_level: int, file: TextIO = sys.stderr
    ):
        """
        Writes textual representation of an instance to `file`.
        """
        if name != "":
            name += " "
        print("%s%s%s" % ("".join(["  "] * tab_level), name, instance), file=file)

    ri = represent_instance

    @staticmethod
    def represent_array(
        name: str,
        array: List["Representable"],
        tab_level: int,
        file: TextIO = sys.stderr,
        header: Optional[str] = None,
    ):
        """
        Writes textual representation of a list of 'representables' to `file`.

        A representable is an Instance, a Placeable or a list of representables.
        It's a recursive type definition.
        """
        if name != "":
            print("%s%s" % ("".join(["  "] * tab_level), name), file=file)
        tab_level += 1
        for i, instance in enumerate(array):
            if header is not None:
                print("%s%s %i" % ("".join(["  "] * tab_level), header, i), file=file)

            if isinstance(instance, list):
                Placeable.represent_array("", instance, tab_level, file)
            elif isinstance(instance, Placeable):
                instance.represent(tab_level, file)
            else:
                Placeable.represent_instance("", instance, tab_level, file)

        tab_level -= 1

    ra = represent_array


Representable = Union[Instance, "Placeable", List["Representable"]]


class DataError(Exception):
    pass
