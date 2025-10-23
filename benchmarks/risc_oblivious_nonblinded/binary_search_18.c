/*
 *  Binary search SCAN_ORAM version
 */ 

 #include <stdio.h>
 #include <stdlib.h>
 #include "riscv-common/tlsf.h"
 #include "riscv-common/encoding.h"
 #include "../include/asm.h"
 #include "../include/misc.h"
 #include "coremark.h"
 
 int ee_printf(const char *fmt, ...);
 
 
 static int N = 1 << 18;
 static int seed = 0;
 static int zero = 0;
 
 
 int __attribute__((noinline)) BinarySearch(int* arr, int x){
   int answer = -1;
   for(int i = 0; i < N; i++){
       int match = (arr[i] == x);
       _cmov(match, i, &answer);
   }
 
   return answer;
 }
 
 
 
 int main(){
     int B = 1;
     int val = rand() % (2*N);
     CORE_TICKS start_time_value, end_time_value;
     CORE_TICKS total_time[1000]; 
     int* arr = (int*) malloc(sizeof(int) * N * B);
     for(int i = 0; i < N*B; i++)
         arr[i] = i;
 
     start_time();  
     BinarySearch(arr, val);
     stop_time();  
 
     //ee_printf("Total time (secs): %llu", total_time);
     srand(seed);
     for (size_t j =0; j < 1000; j++) {
       start_time_value = read_csr(mcycle);
       BinarySearch(arr, val);
       end_time_value= read_csr(mcycle); 
       total_time[j]=end_time_value-start_time_value;
     }
 
     // Compute mean and variance
     CORE_TICKS sum = 0;
     for (int i = 0; i < 1000; i++) {
         sum += total_time[i];
     }
 
 
     CORE_TICKS mean = sum / 1000;
 
     CORE_TICKS var_accum = 0;
     for (int i = 0; i < 1000; i++) {
       CORE_TICKS diff = total_time[i] - mean;
       var_accum += (diff * diff);
     }
     CORE_TICKS variance = var_accum / 1000;
 
     ee_printf("Mean time: %llu\n", mean);
     ee_printf("Variance: %llu\n", variance);
 
 
     free(arr);
 
     return 0;
 }
 