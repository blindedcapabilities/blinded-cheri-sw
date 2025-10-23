
#include <stdio.h>
#include <stdlib.h>



__attribute__ ((optnone))
int main(int argc, char *argv[]) {
    int  x[100];
    x[5] = 0xfb;
    if (x[5] == 0xfa)
        return(0xfb);
    return 1;
}