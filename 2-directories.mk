# You want to have separate directories for sources, includes and build files?
# It gets more complicated and this makefile contains a lot of not-to-dos,
# but it's required to understand the next one, which is undoubtedly better.

# Nothing new on the variable front
CC	=gcc	# this still should totally be ?=
SRCDIR 	=src
OBJDIR	=build
INCDIR	=inc
EXE	=spaceinvaders
# Note: it's funny how I omitted the spaces to close the gaps in the shell
# output - and screw up readability...

SRC 	=$(wildcard $(SRCDIR)/*.c)
DEP	=$(SRC:%.c=%.d)
OBJ	=$(SRC:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
INC	=-I./$(INCDIR)/	# Your includes are in a separate directory, tell gcc!
# Note: we have to be explicit about our paths. It is a bad idea to include
# paths in the pattern substitution functions like this.

# The += is nice for people doing `CFLAGS=whatever make`
CFLAGS	+=-std=c99 ${INC} -Wall -Wextra -Wpedantic -Werror -O3 -D_GNU_SOURCE
LDFLAGS	+=-lncurses -lpthread -lSDL2

# The VPATH variable is a list of directories. They are searched, whenever a
# prerequisite isn't found in the current directory. See line 21:
# 	* build/%.o: %.c -> the % might, e.g., be `main`
# 	* main.c isn't found in the current directory
# 	* since $(SRCDIR) is part of VPATH, make searches it and finds main.c!
# Multiple directories are interspersed with colons (:)
VPATH 	=$(SRCDIR)

.PHONY: all clean debug

# All is historically the first target, so that `make all` or just `make`
# builds whatever is supposed to be the output of your project.
all: $(OBJ) $(EXE)

# Let `make debug` be exactly like `make`, but with debug symbols added
debug: CFLAGS += -g
debug: $(EXE)

# | separates normal (left of it) from order-only prerequisites (right of it).
# Order-only prerequisites are completed (there rules are executed), but they
# don't serve as a dependency for the target.
# Thus we make sure that the object directory is created before any object
# file, but no object file depends on the object directory (which would lead to
# all object files being rebuild each time we invoke make).
$(OBJ): | $(OBJDIR)

# This is standard and correctly uses the automatic variables $@ and $^.
$(EXE): $(OBJ)
	$(CC) -o $@ $^ $(LDFLAGS)

# Nothing new here either
-include $(DEP)

# Use sed to rename the `%.o:` in dependency files to `$(OBJDIR)/%.o`.
# Get the name by patsubst'ing $(SRCDIR)/% to $(OBJDIR)/% in the prerequisite.
%.d: %.c
	$(CC) -MM ${INC} $*.c > $*.d
	sed -i -e 's|.*:|$(patsubst $(SRCDIR)/%,$(OBJDIR)/%,$*).o:|' $*.d
# Note: don't have dependency files in the source directory! Makes life easier.

# We build files outside the build directory, so make can't use implicit rules.
# There is a reason the `rules of makefiles` forbid this!
build/%.o: %.c
	$(CC) -c $(CFLAGS) -o $@ $<

# Standard again, though `rm $(OBJ)` is superfluous
clean:
	-rm $(EXE) $(OBJ) $(DEP)
	-rm -r $(OBJDIR)

# This finally creates the object directory
$(OBJDIR):
	mkdir $@

# Final note: as all this criticism implies, there's a better makefile to come!
