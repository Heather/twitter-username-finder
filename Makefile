RACO=raco
XFLAGS=--gui -v
SRCDIR=.
SRC=finder.rkt
INSTALL   ?= install
MKDIR     ?= $(INSTALL) -d
BINDIR    ?= $(PREFIX)/bin
DESTDIR   ?=

Serene:	$(SRCDIR)
	cd $^ && $(RACO) exe ${XFLAGS} $(SRC)
    
.PHONY: clean rebuild

rebuild: clean | Serene

clean:
	rm -f *.exe
    rm -f *.bak

install:
	$(MKDIR) $(DESTDIR)$(BINDIR)
	$(INSTALL) finder$(EXE) $(DESTDIR)$(BINDIR)/
