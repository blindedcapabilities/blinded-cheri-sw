#include <cheric.h>

#define __blinded [[clang::annotate_type("blinded")]]


int __blinded x[100];

__attribute__ ((optnone))
int main(int argc, char *argv[]) {

  x[5] = 0xfb;
  if (x[5] == 0xfa)
     return(0xfb);
    
  return 1;
} 