/*
 *  Oblivious matrix multiplication is the same as non-oblivious matrix multiplication.
 */
 #include <stdio.h>
 #include <stdlib.h>
 #include <assert.h>
 #include "riscv-common/tlsf.h"
 #include "riscv-common/encoding.h"
 #include "../include/asm.h"
 #include "../include/misc.h"
 #include "coremark.h"
 int ee_printf(const char *fmt, ...);
 #define __blinded [[clang::annotate_type("blinded")]]
 
 static int A_nrow = (1<<6);
 static int A_ncol = (1<<6);
 static int B_nrow = (1<<6);
 static int B_ncol = (1<<6);
 
 void __attribute__((noinline)) MatrixMult(int* A, int* B, int* C){
     int C_nrow = A_nrow;
     int C_ncol = B_ncol;
     assert (A_ncol == B_nrow);
     for(int i = 0; i < C_nrow; i++){
         for(int j = 0; j < C_ncol; j++){
             for(int k = 0; k < A_ncol; k++){
                 C[i*C_ncol + j] += A[i * A_ncol + k] * B[k * B_ncol + j];
             }
         }
     }
 }
 
 void InitMatrix(int* mat, int nrow, int ncol){
     for(int i = 0; i < nrow * ncol; i++)
         mat[i] = rand() % 9 + 1;
 }
 
 void PrintMatrix(int* mat, int nrow, int ncol){
     for(int i = 0; i < nrow; i++){
        for(int j = 0; j < ncol; j++)
           printf("%d, ", mat[i*ncol+j]);
        printf("\n");
     }
 }
 
 int main(){
 
     int C_nrow = A_nrow;
     int C_ncol = B_ncol;

     ee_printf("Could you please write: %llu\n");
     //assert(A_ncol == B_nrow);
     CORE_TICKS start_time_value, end_time_value;
 
     int* A = (int*) malloc(sizeof(int) * A_nrow * A_ncol);
     InitMatrix(A, A_nrow, A_ncol);
 
     int* B = (int*) malloc(sizeof(int) * B_nrow * B_ncol);
     InitMatrix(B, B_nrow, B_ncol);
 
     int* C = (int*) malloc(sizeof(int) * C_nrow * C_ncol);
     
     start_time_value = read_csr(mcycle);
     MatrixMult(A, B, C);
     end_time_value= read_csr(mcycle);
 
     ee_printf("Mean time: %llu\n", end_time_value-start_time_value);
     //ee_printf("Variance: %llu\n", variance);
 
     ee_printf("Matrix A is:\n");
     //PrintMatrix(A, A_nrow, A_ncol);
 
     ee_printf("Matrix B is:\n");
     //PrintMatrix(B, B_nrow, B_ncol);
 
     ee_printf("Matrix C is:\n");
     //PrintMatrix(C, C_nrow, C_ncol);
 
     free(A);
     free(B);
     free(C);
 
     return 0;
 }
 