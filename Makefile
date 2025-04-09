SRCDIR = src
BUILDDIR = build
EXEFILE = $(BUILDDIR)/app
OBJECTS = $(BUILDDIR)/app.o $(BUILDDIR)/convolution.o
NASMFMT = -f elf64
CCOPT = -fPIE -no-pie
NASMOPT = -w+all
CC = g++
CFLAGS = -c -g -Wall -Wextra -fPIE -no-pie
LDFLAGS = -lGL -lSDL2 -lSDL2_image -fPIE -no-pie

$(shell mkdir -p $(BUILDDIR))

$(BUILDDIR)/%.o: $(SRCDIR)/%.cpp
	$(CC) $(CCFMT) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SRCDIR)/%.s
	nasm $(NASMFMT) $(NASMOPT) -o $@ $<

$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFMT) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(BUILDDIR)/*.o $(EXEFILE)
