module ALU_EXT(clk, src1, src0, func, dst_EX_DM, ov, zr, neg);
	// Encoding of func[2:0] is as follows: //
	// 000 ==> MUL   Multiplicación de enteros con signo
	// 001 ==> UMUL  Multiplicación de enteros sin signo
	// 010 ==> ADDF  Suma de punto flotante
	// 011 ==> SUBF  Resta de punto flotante
	// 100 ==> MULF  Multiplicación de punto flotante
	// 101 ==> ITF   Conversión de entero a punto flotante
	// 110 ==> FTI   Conversión de punto flotante a entero
	// 111 ==> undefined
	
	`include "common_params.inc"
    
	input clk;
	input [31:0] src1, src0;
	input [2:0] func;				// selects function to perform
	output reg [31:0] dst_EX_DM;
	output ov, zr, neg;

	reg [31:0] ifadd_OUT, ifmul_OUT, iftoi_OUT, iitof_OUT, iimul_OUT;

	// CORRECCIÓN 1: Cambiar reg por wire para OUT
	wire [31:0] OUT;
	
	// modulo de suma
	FP_adder ifadd(
		.A(src1),
		.B(func==SUBF ? {~src0[31], src0[30:0]} : src0),	// flip second operand if doing A - B = A + (-B)
		.out(ifadd_OUT)
	);
   
	// modulo multiplicacion
	FP_mul ifmul(
		.A(src1),
		.B(src0),
		.OUT(ifmul_OUT)
	);
	
	// modulo conversor de flotante a entero con signo con 32 bits
	float_to_signed_int iftoi(
		.FP_val(src1),
		.signed_int_val(iftoi_OUT)
	);
	
	// modulo conversion de entero a punto flotante con 32 bits
	signed_int_to_float iitof(
		.signed_int_val(src1),
		.FP_val(iitof_OUT)
	);

	// multiplicacion de enteros de 16bits x 16bits, tambien adicionamos los signos
	int_mul_16by16 iimul(
		.A(src1[15:0]),		// CORRECCIÓN 2: Usar solo 16 bits
		.B(src0[15:0]),		// CORRECCIÓN 2: Usar solo 16 bits
		.sign(~func[0]),	// 0 ==> MUL 1 ==> UMUL
		.OUT(iimul_OUT)
	);
	
	// Multiplexor principal
	assign OUT = (func==MUL || func==UMUL) ? iimul_OUT :
				 (func==ADDF || func==SUBF) ? ifadd_OUT :
				 (func==MULF) ? ifmul_OUT :
				 (func==ITF) ? iitof_OUT :
				 (func==FTI) ? iftoi_OUT :
				 32'hDEADDEAD;  // undefined behavior

	// Banderas
	assign ov = 1'b0;  // Nunca hay overflow
	
	// CORRECCIÓN 3: Eliminar línea duplicada y corregir comentarios
	// bandera de zero: zr = 0 (no es cero), zr = 1 (es cero)
	assign zr = (func==MUL || func==UMUL || func==FTI) ? |OUT : |OUT[30:0];
	
	// bandera de negativo: neg = 0 (positivo), neg = 1 (negativo)
	assign neg = (func==UMUL) ? 1'b0 : OUT[31];
	
	// registro de salida
	always @(posedge clk)
		dst_EX_DM <= OUT;   // salida de la operacion
endmodule