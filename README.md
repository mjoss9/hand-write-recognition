# Hand Write Recognition

## ALU Implementation
This project includes a 16-bit ALU (Arithmetic Logic Unit) that supports multiple operations with integrated pipeline stages and comprehensive status flag handling.

### Supported Operations
| Operation | Function Code | Description |
|-----------|--------------|-------------|
| ADD | 000 | Addition with saturation |
| SUB | 001 | Subtraction with saturation |
| AND | 010 | Logical AND |
| NOR | 011 | Logical NOR |
| SLL | 100 | Shift Left Logical |
| SRL | 101 | Shift Right Logical |
| SRA | 110 | Shift Right Arithmetic |
| LHB | 111 | Load High Byte |

### Features
- 16-bit data path with saturation arithmetic
- Comprehensive status flag system
- Advanced barrel shifter implementation
- Pipeline integration for efficient processing
- Configurable shift operations up to 15 positions
- Two's complement arithmetic support

### Signal Descriptions
#### Input Signals
- `clk`: Clock input for synchronized operations
- `src0`, `src1`: 16-bit input operands
- `shamt`: 4-bit shift amount for shift operations (0-15 positions)
- `func`: 3-bit function select for operation control

#### Output Signals
- `dst`: Immediate combinational result output
- `dst_EX_DM`: Registered (clocked) result for pipeline stages
- Status flags:
  - `ov`: Overflow indicator
  - `zr`: Zero result indicator
  - `neg`: Negative result indicator

### Status Flags Details
1. **Overflow Flag (ov)**
   - Indicates arithmetic overflow in ADD/SUB operations
   - Set when result exceeds 16-bit signed range
   - Triggers saturation logic for result correction

2. **Zero Flag (zr)**
   - Set when all bits of result are 0
   - Implemented using NOR reduction: ~|dst

3. **Negative Flag (neg)**
   - Indicates negative result
   - Based on MSB (dst[15]) of result
   - Used for signed number operations

### Shift Operation Implementation
#### Barrel Shifter Structure
- Four-stage cascaded multiplexer design
- Supports variable shift amounts (0-15 positions)
- Shift stages:
  - Stage 1: 1-bit shift (shamt[0])
  - Stage 2: 2-bit shift (shamt[1])
  - Stage 3: 4-bit shift (shamt[2])
  - Stage 4: 8-bit shift (shamt[3])

#### Shift Types
1. **Logical Left Shift (SLL)**
   - Shifts in zeros from right
   - Used for multiplication by powers of 2

2. **Logical Right Shift (SRL)**
   - Shifts in zeros from left
   - Used for unsigned division by powers of 2

3. **Arithmetic Right Shift (SRA)**
   - Preserves sign bit during right shift
   - Used for signed division by powers of 2

### Implementation Details
1. **Arithmetic Operations**
   - Uses 2's complement for subtraction
   - Implements saturation for overflow handling
   - Saturation limits:
     - Positive overflow: 0x7FFF
     - Negative overflow: 0x8000

2. **Pipeline Integration**
   - Supports Execute (EX) to Data Memory (DM) pipeline stages
   - Registered output (dst_EX_DM) for synchronized operations
   - Immediate output (dst) for branch/jump calculations

3. **Optimization Features**
   - Efficient barrel shifter design
   - Fast carry propagation for arithmetic
   - Minimal latency for status flag generation

