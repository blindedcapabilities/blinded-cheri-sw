/*
 *  Binary search SCAN_ORAM version
 */ 

 /* this file is included from OISA benchmark git@github.com:cwfletcher/oisa.git */ 
 
#include <stdio.h>
#include <stdlib.h>
#include "riscv-common/tlsf.h"
#include "riscv-common/encoding.h"
#include "../include/asm.h"
#include "../include/misc.h"
#include "coremark.h"

int ee_printf(const char *fmt, ...);

#define __blinded [[clang::annotate_type("blinded")]]

static int N = 1 << 4;
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


__attribute__ ((optnone))
int main(){
    int B = 1;
    int val = rand() % (2*N);
    int __blinded arr[N * B];
    for(int i = 0; i < N*B; i++)
        arr[i] = i + 2;

    BinarySearch(arr, val);

    return 1;
}
 