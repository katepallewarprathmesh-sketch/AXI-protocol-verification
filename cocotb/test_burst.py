"""Burst write/read tests via cocotbext-axi."""

import cocotb
from cocotb.triggers import Timer

from axi_tb_utils import make_axi_master, reset_dut, start_clock


@cocotb.test()
async def test_burst_incr(dut):
    start_clock(dut)
    await reset_dut(dut)
    master = make_axi_master(dut)

    addr = 0x0100
    data = bytes(range(16))  # 16-byte INCR burst (4 beats @ 32-bit)

    await master.write(addr, data)
    resp = await master.read(addr, len(data))
    assert resp.resp == 0
    assert resp.data == data

    dut._log.info("burst INCR test passed")
    await Timer(50, units="ns")


@cocotb.test()
async def test_burst_dwords(dut):
    start_clock(dut)
    await reset_dut(dut)
    master = make_axi_master(dut)

    await master.write_dword(0x0200, 0xCAFEBABE)
    await master.write_dword(0x0204, 0x12345678)
    val0 = await master.read_dword(0x0200)
    val1 = await master.read_dword(0x0204)
    assert val0 == 0xCAFEBABE
    assert val1 == 0x12345678

    dut._log.info("burst dword test passed")
    await Timer(50, units="ns")
