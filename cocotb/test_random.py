"""Randomized write/read stress test."""

import random

import cocotb
from cocotb.triggers import Timer

from axi_tb_utils import make_axi_master, reset_dut, start_clock


@cocotb.test()
async def test_random(dut):
    start_clock(dut)
    await reset_dut(dut)
    master = make_axi_master(dut)

    rng = random.Random(0xA5A5)
    mem: dict[int, bytes] = {}

    for _ in range(20):
        addr = rng.randrange(0, 0x800) & ~0x3
        length = rng.choice([4, 8, 12, 16])
        data = bytes(rng.getrandbits(8) for _ in range(length))
        await master.write(addr, data)
        mem[addr] = data

    for addr, expected in mem.items():
        resp = await master.read(addr, len(expected))
        assert resp.resp == 0
        assert resp.data == expected, f"mismatch @0x{addr:08x}"

    dut._log.info("random test passed (%d locations)", len(mem))
    await Timer(100, units="ns")
