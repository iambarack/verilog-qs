# Ring FIFO

`ring_fifo.sv` implements a synchronous, parameterized ring buffer using a
ready/valid interface.

## Interface

- `in_valid` and `in_data`: request to enqueue an item.
- `in_ready`: the FIFO can accept an item this cycle.
- `out_valid` and `out_data`: an item is available to dequeue.
- `out_ready`: the consumer accepts an item this cycle.
- `rst`: synchronous, active-high reset.

An enqueue occurs when `in_valid && in_ready`; a dequeue occurs when
`out_valid && out_ready`. The FIFO permits an enqueue and dequeue in the same
cycle, including while full. The implementation supports depths that are not
powers of two.

## Example simulation

With Icarus Verilog:

```text
iverilog -g2012 -o ring_fifo_tb.vvp ring_fifo.sv ring_fifo_tb.sv
vvp ring_fifo_tb.vvp
```
