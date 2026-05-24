"""Smoke test: single and multi write/read pairs."""

import cocotb
from cocotb.triggers import Timer

from axi_tb_utils import make_axi_master, reset_dut, start_clock, write_read_check


@cocotb.test()
async def test_smoke(dut):
    start_clock(dut)
    await reset_dut(dut)
    master = make_axi_master(dut)

    await write_read_check(master, 0x0000, b"\xde\xad\xbe\xef")
    await write_read_check(master, 0x0010, b"\x11\x22\x33\x44")
    await write_read_check(master, 0x0020, b"\xaa\xbb\xcc\xdd")

    await Timer(100, units="ns")
    dut._log.info("smoke test passed")
