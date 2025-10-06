# Floating Point Adder Components

This folder contains the implementation of a 32-bit single-cycle floating-point adder that follows the IEEE 754 Standard. The implementation consists of three main modules:

## FP_adder Module

The main module that implements a 32-bit single-cycle floating-point adder. It follows the IEEE 754 Standard format:
- 1-bit sign
- 8-bit exponent
- 23-bit mantissa

Format: `seee_eeee_emmm_mmmm_mmmm_mmmm_mmmm_mmmm`

The floating point number is represented as:
```
FP num = (-1)^S * 2^(E-127) * {|E.M}
```
When |E = 0, the exponent is denormalized to -126.

### Key Features:
- Handles special cases like NaN, positive/negative infinity
- Supports denormalized numbers
- Implements proper rounding and normalization
- Handles internal overflow conditions

## Supporting Modules

### left_shifter Module
A barrel shifter that performs left shifts on 24-bit inputs:
- Input: 24-bit operand and 5-bit shift amount
- Output: 24-bit shifted result
- Implements shifts in stages (1,2,4,8,16 bits) for efficiency
- Used in the normalization process of floating-point addition

### right_shifter Module
A barrel shifter that performs right shifts on 24-bit inputs:
- Input: 24-bit operand and 5-bit shift amount
- Output: 24-bit shifted result
- Implements shifts in stages (1,2,4,8,16 bits) for efficiency
- Used for aligning mantissas before addition

## Operation Flow

1. **Exponent Comparison**:
   - Compare exponents of both numbers
   - Determine which number needs to be shifted
   - Calculate shift amount

2. **Mantissa Alignment**:
   - Use right_shifter to align the mantissa of the smaller number
   - Handle special cases for very large differences

3. **Addition**:
   - Perform 2's complement addition of aligned mantissas
   - Handle internal overflow conditions

4. **Normalization**:
   - Use left_shifter to normalize the result
   - Adjust exponent based on normalization shift
   - Handle special cases (overflow, underflow)

5. **Final Result**:
   - Combine sign, adjusted exponent, and normalized mantissa
   - Handle special values (NaN, infinity)

## Usage

To use this floating-point adder in your design:

1. Include all three modules in your project:
   - `FP_adder.sv`
   - `left_shifter.sv`
   - `right_shifter.sv`

2. Instantiate the FP_adder module with appropriate connections:
```verilog
FP_adder fp_add_inst (
    .A(input_a),     // First 32-bit floating point number
    .B(input_b),     // Second 32-bit floating point number
    .out(sum_out)    // 32-bit floating point result
);
```

## Limitations

- Single precision only (32-bit)
- No support for double precision
- Single cycle implementation (not pipelined)