#include <stdio.h>

char *convolution(char *path);

int main(int argc, char *argv[])
{   
    for (int i = 1; i < argc; i++)
        printf("%d: %s\n", i, convolution(argv[i]));
}
