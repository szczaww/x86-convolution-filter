EXEFILE = rev
OBJECTS = rev.o mystrrev.o
CCFMT = -m64
NASMFMT = -f elf64
CCOPT = 
NASMOPT = -w+all

CC = g++
CFLAGS = -c -g -Wall -Wextra
LDFLAGS = -lglut -lGL -lGLU

%.o: %.cpp
	$(CC) $(CCFMT) $(CFLAGS) -o $@ $<

%.o: %.s
	nasm $(NASMFMT) $(NASMOPT) -o $@ $<

$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFMT) -o $@ $^ $(LDFLAGS)
	
clean:
	rm -f *.o *.lst $(EXEFILE)
