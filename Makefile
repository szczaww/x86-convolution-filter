EXEFILE = main
OBJECTS = main.o convolution.o
CCFMT = -m64
NASMFMT = -f elf64
CCOPT = 
NASMOPT = -w+all

CC = g++
CFLAGS = -c -g -Wall -Wextra
LDFLAGS = -lGL -lSDL2 -lSDL2_image

%.o: %.cpp
	$(CC) $(CCFMT) $(CFLAGS) -o $@ $<

%.o: %.s
	nasm $(NASMFMT) $(NASMOPT) -o $@ $<

$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFMT) -o $@ $^ $(LDFLAGS)
	
clean:
	rm -f *.o *.lst $(EXEFILE)
