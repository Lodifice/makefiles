# This is one of the first makefiles you'll probably use.
# A good idea for every makefile is following these rules:
# 	http://make.mad-scientist.net/papers/rules-of-makefiles/

# Never type a string twice, use variables for everything.
CC = gcc
CFLAGS = -Wall
LDFLAGS = -lm
EXE = sincos
# NOTE: don't override variables like CC!
# Users could call make like that: CC=clang make
# Better use the conditional assignment operator: CC ?= gcc

# Scan your working directory for files using wildcards.
# Otherwise, you'd have to edit your makefile everytime you add/remove sources
SRC = $(wildcard *.c)
DEP = $(SRC:%.c=%.d)
OBJ = $(SRC:%.c=%.o)

# The first target. It's also build if you just type `make`.
# Use $@, which contains the target's name. Less repetition + you make sure,
# that the rule for your target really builds a corresponding file!
$(EXE): $(OBJ) $(DEP)
	$(CC) -o $@ $(OBJ) $(LDFLAGS)
# Note: it is superfluous to list the dependency files (*.d) as prerequisites.
# Then you can replace $(OBJ) by $^ which contains all prerequisites.

# Include the dependency files in your makefile. These are make rules that, for
# every object file, list the source file and header files it depends on.
-include $(DEP)

# Pattern rule to build a dependency file with the help of a C compiler.
%.d: %.c Makefile
	$(CC) -MM $(CFLAGS) $*.c > $*.d
# Note: listing the makefile as a prerequisite is gimmicky and not needed.
# Also, better use $@ and $< (first prerequisite) instead of referring to the
# matched pattern with $*!

# Declare `clean` as a phony target. Make will not care about prerequisites and
# just execute the associated rule!
.PHONY: clean
clean:
	rm -f $(EXE) $(OBJ) $(DEP)
