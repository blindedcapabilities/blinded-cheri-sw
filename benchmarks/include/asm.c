#include "asm.h"

extern inline void _cmovn(int if_mov, int* src_addr, int* dst_addr, int len);

extern inline void _oswapn(int if_swap, int* op1_addr, int* op2_addr, int len);
