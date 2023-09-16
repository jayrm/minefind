FBC := fbc

ifeq ($(OS),Windows_NT)
EXEEXT := .exe
else
EXEEXT := .exe
endif

MAIN := mine

SRCS := $(MAIN).bas
SRCS += common.inc
SRCS += gfx.inc
SRCS += clock.inc
SRCS += gui.inc
SRCS += grid.inc

COMBINED := minefind

FBCFLAGS := -e

.phony: all
all: $(MAIN)$(EXEEXT) $(COMBINED).exe mk.bat 

$(MAIN).exe: $(SRCS)
	$(FBC) $(FBCFLAGS) $< -x $@

combine$(EXEEXT): tools/combine.bas
	$(FBC) $(FBCFLAGS) $< -x $@

$(COMBINED).bas: $(SRCS) combine$(EXEEXT)
	./combine$(EXEEXT) -y -i $< -o $@  

$(COMBINED)$(EXEEXT): $(COMBINED).bas
	$(FBC) $(FBCFLAGS) $< -x $@

mk.bat: $(SRCS) makefile tools/combine.bas
	@echo Making $@
	@echo $(FBC) $(FBCFLAGS) $(MAIN).bas -x $(MAIN).exe > $@
	@echo $(FBC) $(FBCFLAGS) tools/combine.bas -x combine.exe >> $@
	@echo combine.exe -y -i $(MAIN).bas -o $(COMBINED).bas >> $@
	@echo $(FBC) $(COMBINED).bas -x $(COMBINED).exe >> $@

.phony: clean
clean:
	rm -rf $(MAIN).exe $(COMBINED).exe $(COMBINED).bas 