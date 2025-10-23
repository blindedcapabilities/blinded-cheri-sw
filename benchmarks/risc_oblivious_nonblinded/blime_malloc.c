
#include <stdio.h>
#include <stdlib.h>



__attribute__ ((optnone))
int main(int argc, char *argv[]) {
    void *ptr = malloc(4); 

    printf("can this blinded malloc work: %x\n", ptr);

}
