EXEFILE = main
OBJECTS = main.o convolution.o
CCFMT =
NASMFMT = -f elf64
CCOPT = -fPIE -no-pie
NASMOPT = -w+all

CC = g++
CFLAGS = -c -g -Wall -Wextra -fPIE -no-pie
LDFLAGS = -lGL -lSDL2 -lSDL2_image -fPIE -no-pie

%.o: %.cpp
	$(CC) $(CCFMT) $(CFLAGS) -o $@ $<

%.o: %.s
	nasm $(NASMFMT) $(NASMOPT) -o $@ $<

$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFMT) -o $@ $^ $(LDFLAGS)
	
clean:
	rm -f *.o *.lst $(EXEFILE)
