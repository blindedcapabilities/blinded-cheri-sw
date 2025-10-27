// See LICENSE for license details.



/*
* Include tlsf allocator, integrate with FPGA UART for exit and printf
* @author Merve Gulmez 
* @copyright © Ericsson AB 2025
* 
* SPDX-License-Identifier: Apache License, Version 2.0
*/

#include <stdint.h>
#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <limits.h>
#include <sys/signal.h>
#ifdef FPGA
#include "uart_16550.h"
#endif
#include "util.h"

#ifdef TLSF
#include "tlsf.h"
tlsf_t tlsf;
#endif
extern volatile uint64_t tohost;
extern volatile uint64_t fromhost;

#if __CHERI__
#include <cheri_init_globals.h>
#include <cheriintrin.h>

void
_start_purecap(void) {
  cheri_init_globals_3(__builtin_cheri_global_data_get(),
      __builtin_cheri_program_counter_get(),
      __builtin_cheri_global_data_get());
}
#endif

int main(int, char **);
int ee_printf(const char *fmt, ...);

__attribute((optnone, noinline))
void _exit(int status) {
  while (1) {
    tohost = status;
  }
#ifdef FPGA
  ee_printf("Exit code %d", status);
  while (1) {
    __asm__ volatile("ebreak");
  }
#endif 
}
#ifdef TLSF
int _sbrk() { return -1; }
int _kill(int pid, int sig) { return -1; }
int _getpid() { return -1; }
int _read(int file, char *ptr, int len) { return -1; }
int _lseek(int file, int ptr, int dir) { return -1; }
int _close(int file) { return -1; }
int _write(int file, char *ptr, int len) { return -1; }
int _isatty(int file) { return 0; }
int _fstat(int file, struct stat *st) { return -1; }
#endif

#ifdef TLSF

void *malloc(size_t size);
void *malloc(size_t size)
{
    void *ptr;
#ifdef CHERI
    size_t rounded_len = __builtin_cheri_round_representable_length(size);
#endif

#ifdef CHERI
    ptr = tlsf_malloc(tlsf, rounded_len);
    ptr = __builtin_cheri_bounds_set(ptr, rounded_len);
    //explicit_bzero(ptr, rounded_len);
#else
    ptr = tlsf_malloc(tlsf, size);
#endif

    return ptr;
}


#ifdef CHERI
void* blinded_malloc(size_t size)
{
   void *ptr = tlsf_malloc(tlsf, size); 
   ptr = __builtin_cheri_perms_and(ptr, ~CHERI_PERM_BLINDED); 
   return ptr; 
}
#endif

static unsigned char global_heap[0x4000];

void free(void *ptr);
void free(void *ptr)
{
#ifdef CHERI
    ptr = __builtin_cheri_address_set(tlsf, __builtin_cheri_address_get(ptr));
#endif
    tlsf_free(tlsf, ptr);
}

/* it will run before the main() function*/
/* static uint8_t __attribute__((aligned(0x1000))) app_heap_address[200000]; 
*/
__attribute__((optnone))
int libtlsf_init()
{
    size_t  app_heap_size = 0x4000; 
    size_t uxAddress;
    uintptr_t app_heap_address = (uintptr_t)global_heap;
    tlsf = tlsf_create_with_pool((void *)app_heap_address, app_heap_size);
   return 1;        
}
#endif 

#ifdef SPEC 
void init_caps();
#endif 

extern void handle_trap(unsigned long mcause, unsigned long mepc);

__attribute__((optnone))
void handle_trap(unsigned long mcause, unsigned long mepc) {

#ifdef FPGA
  ee_printf("Unexpected trap %lu @pc=0x%lx\n", mcause, mepc);
#endif
  _exit(-1);
}

void _init(int cid, int nc)
{
#ifdef FPGA
  uart0_init(); 
#endif 

#ifdef TLSF
  libtlsf_init(); 
#endif
  // only single-threaded programs should ever get here.
#ifndef SPEC 
  int ret = main(0, 0);
  _exit(ret);
#endif 

#ifdef SPEC 
  init_caps();
  _exit(1);
#endif 

}
