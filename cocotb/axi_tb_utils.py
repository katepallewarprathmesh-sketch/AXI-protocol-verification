"""Shared helpers for AXI cocotb tests."""

from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotbext.axi import AxiBus, AxiMaster


def start_clock(dut, period_ns: int = 10) -> None:
    cocotb.start_soon(Clock(dut.aclk, period_ns, units="ns").start())


async def reset_dut(dut, cycles: int = 5) -> None:
    dut.aresetn.value = 0
    for _ in range(cycles):
        await RisingEdge(dut.aclk)
    dut.aresetn.value = 1
    await RisingEdge(dut.aclk)
    await Timer(1, units="ns")


def make_axi_master(dut) -> AxiMaster:
    bus = AxiBus.from_prefix(dut, "")
    return AxiMaster(
        bus,
        dut.aclk,
        dut.aresetn,
        reset_active_level=False,
    )


async def write_read_check(
    master: AxiMaster,
    addr: int,
    data: bytes,
) -> None:
    await master.write(addr, data)
    resp = await master.read(addr, len(data))
    assert resp.resp == 0, f"AXI response not OKAY: {resp.resp}"
    assert resp.data == data, (
        f"data mismatch @0x{addr:08x}: expected {data!r}, got {resp.data!r}"
    )
