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

#define __blinded [[clang::annotate_type("blinded")]]

static int N = 1 << 8;
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
    CORE_TICKS total_time; 
#ifdef BLINDED
    int* arr = (int*) blinded_malloc(sizeof(int) * N * B);
#else
    int* arr = (int*) malloc(sizeof(int) * N * B);  
#endif

    for(int i = 0; i < N*B; i++)
        arr[i] = i;

    srand(seed);

    start_time_value = read_csr(mcycle);
    BinarySearch(arr, val);
    end_time_value= read_csr(mcycle); 
    total_time=end_time_value-start_time_value;

    free(arr);

    return total_time;
}
