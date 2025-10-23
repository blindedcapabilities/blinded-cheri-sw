#include <stdio.h>
#include <stdlib.h>
#include "../include/asm.h"

static int N = 1 << 16;
static int seed = 0;
#define __blinded [[clang::annotate_type("blinded")]]

// Find the index and value of the largest element in array arr
void __attribute__((noinline)) FindMax(int arr[], int* max_idx, int* max_val){
    for (int i = 0; i < N; i++){
        int __blinded larger = (arr[i] > *max_val);
        _cmov(larger, i, max_idx);
        _cmov(larger, arr[i], max_val);
    }
}


int main(){
    srand(seed);
    int* arr = (int*) blinded_malloc(sizeof(int) * N);
    for(int i = 0; i < N; i++){
        arr[i] = rand() % (N * 4);
    }

    int __blinded max_idx = 0;
    int __blinded max_val = 0;
    FindMax(arr, &max_idx, &max_val);
    //printf("The largest element is found at idx = %d, value = %d\n", max_idx, max_val);
    free(arr);

    return 0;
}

