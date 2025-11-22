# SPDX-FileCopyrightText: © 2024 Darryl L. Miles
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")
    
    # We are using a verilog testbench, so we just wait for finish
    await Timer(260, unit='ns')

    assert dut.finished.value == 1, f"Verilog Simulation did not finish"
