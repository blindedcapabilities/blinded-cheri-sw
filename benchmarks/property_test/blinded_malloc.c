#include <cheric.h>
#include "riscv-common/tlsf.h"

#define __blinded [[clang::annotate_type("blinded")]]
 
__attribute__ ((optnone))
int main(int argc, char *argv[]) {

  char *x = blinded_malloc(100);
  x[5] = 0xfb;
  if (x[5] == 0xfa)
     return(0xfb);
    
  return 1;
} 