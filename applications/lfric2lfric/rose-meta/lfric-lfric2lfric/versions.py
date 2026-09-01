import sys

from metomi.rose.upgrade import MacroUpgrade  # noqa: F401

from .version31_32 import *


class UpgradeError(Exception):
    """Exception created when an upgrade fails."""

    def __init__(self, msg):
        self.msg = msg

    def __repr__(self):
        sys.tracebacklimit = 0
        return self.msg

    __str__ = __repr__


"""
Copy this template and complete to add your macro

class vnXX_txxx(MacroUpgrade):
    # Upgrade macro for <TICKET> by <Author>

    BEFORE_TAG = "vnX.X"
    AFTER_TAG = "vnX.X_txxx"

    def upgrade(self, config, meta_config=None):
        # Add settings
        return config, self.reports
"""

class vn32_t581(MacroUpgrade):
    # Upgrade macro for #581 by Christine Johnson

    BEFORE_TAG = "vn3.2"
    AFTER_TAG = "vn3.2_t581"

    def upgrade(self, config, meta_config=None):
        # Add settings

        domain_height = self.get_setting_value(
            config, ["namelist:extrusion", "domain_height"]
        )
        eta_values = self.get_setting_value(
            config, ["namelist:extrusion", "eta_values"]
        )
        method = self.get_setting_value(
            config, ["namelist:extrusion", "method"]
        )
        number_of_layers = self.get_setting_value(
            config, ["namelist:extrusion", "number_of_layers"]
        )
        planet_radius = self.get_setting_value(
            config, ["namelist:extrusion", "planet_radius"]
        )
        stretching_method = self.get_setting_value(
            config, ["namelist:extrusion", "stretching_method"]
        )
        stretching_height = self.get_setting_value(
            config, ["namelist:extrusion", "stretching_height"]
        )
        start_dump_filename = self.get_setting_value(
            config, ["namelist:files", "start_dump_filename"]
        )

        if start_dump_filename != "'lfric2lfric_dump'" :
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "domain_height"],
                domain_height,
            )
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "eta_values"],
                eta_values,
            )
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "method"],
                method,
            )
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "number_of_layers"],
                number_of_layers,
            )     
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "planet_radius"],
                planet_radius,
            )
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "stretching_method"],
                stretching_method,
            )
            self.add_setting(
                config,
                ["namelist:extrusion_dst", "stretching_height"],
                stretching_height,
            ) 

        return config, self.reports
