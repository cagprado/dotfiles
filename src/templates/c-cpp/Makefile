# Basic makefile for C++ programs, easily extendable to C programs.
# Some conventions are assumed:
#   *.hpp         : C++ headers (all inside include/)
#   *.cpp         : C++ code (all inside src/)
#   main_????.cpp : generates bynary file ???? (all assumed targets)

# DEFINE VARIABLES ##########################################################
# programs
SHELL             := /bin/sh
CC                := gcc
CXX               := g++
LD                := ld
MV                := mv -f
RM                := rm -f
INSTALL           := install

# paths
BUILDDIR          := $(dir $(lastword $(MAKEFILE_LIST)))
INCDIR            := $(BUILDDIR)include
SRCDIR            := $(BUILDDIR)src
DEPDIR            := $(BUILDDIR).d

# compiler/linker flags
DEPFLAGS           = -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td
CPPFLAGS          := $(CPPFLAGS) -Wall -Wno-misleading-indentation -std=c++11 -I$(INCDIR)
CFLAGS            := $(CFLAGS) -g -O2
CXXFLAGS          := $(CXXFLAGS) -g -O4 -fPIC
LDFLAGS           := $(LDFLAGS)

# ROOT specific
CPPFLAGS          += -I$(shell root-config --incdir)
CXXFLAGS          += $(shell root-config --auxcflags)
LDFLAGS           += $(shell root-config --ldflags --libs)

## PYTHIA specific
#CPPFLAGS          += -I$(shell pythia8-config --includedir 2>/dev/null)
#LDFLAGS           += $(shell pythia8-config --ldflags 2>/dev/null) -Wl,-rpath,$(shell pythia8-config --libdir 2>/dev/null)

# target specific
CCSRCS            := $(wildcard $(SRCDIR)/*.c)
CCPRGS            := $(wildcard $(SRCDIR)/main_*.c)
CCOBJS            := $(addsuffix .o,$(basename $(CCSRCS)))
CPPSRCS           := $(wildcard $(SRCDIR)/*.cpp)
CPPPRGS           := $(wildcard $(SRCDIR)/main_*.cpp)
CPPOBJS           := $(addsuffix .o,$(basename $(CPPSRCS)))
TARGETS           := $(patsubst main_%,$(BUILDDIR)%,$(notdir $(basename $(CCPRGS) $(CPPPRGS))))
DEPENDS           := $(patsubst $(SRCDIR)%,$(DEPDIR)%,$(CCOBJS:.o=.d) $(CPPOBJS:.o=.d))

# RULES #####################################################################
all: $(TARGETS)
.PHONY: all

$(TARGETS): $(BUILDDIR)%: $(SRCDIR)/main_%.o
	@echo -e "\e[1mCompiling target '$@'...\e[0m"
	@$(CXX) $(LDFLAGS) -o $@ $^

# .d files are created together with .o files: this makes .d always
#   updated for next run.  (modification time of .d should be before
#   .o, in case of gcc, this is the case)
# .d should not depend on the sources: not necessary since sources
#   changes will force .o to be rebuilt (and in turn, .d to be updated).
# .d files are dependencies of .o files: if user deletes .d, it will
#   be rebuilt.
# .d files have empty rule: make will assume they are always created/
#   updated instead of complaining it can'd do it.
$(CCOBJS): $(SRCDIR)/%.o: $(SRCDIR)/%.c $(DEPDIR)/%.d
	@echo -e "\e[1mCompiling object file '$@'...\e[0m"
	@$(CXX) $(DEPFLAGS) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $<
	@$(MV) $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

$(CPPOBJS): $(SRCDIR)/%.o: $(SRCDIR)/%.cpp $(DEPDIR)/%.d
	@echo -e "\e[1mCompiling object file '$@'...\e[0m"
	@$(CXX) $(DEPFLAGS) $(CPPFLAGS) $(CXXFLAGS) -o $@ -c $<
	@$(MV) $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

$(DEPENDS): ;
.PRECIOUS: %.d

$(DEPDIR)/makedepend: $(BUILDDIR)makedepend.py $(CCPRGR) $(CPPPRGS)
	@echo -e "\e[1mCreating '$(basename $@)' file...\e[0m"
	@$(BUILDDIR)makedepend.py $(CCPRGS) $(CPPPRGS)

# This will clean intermediate files, leaving final targets
cleanbuild:
	@echo -e "\e[1mCleaning intermediate files...\e[0m"
	@$(RM) $(CCOBJS) $(CPPOBJS) $(DEPENDS)
.PHONY: cleanbuild

# This will clean intermediate and target files
clean: cleanbuild
	@echo -e "\e[1mCleaning target files...\e[0m"
	@$(RM) $(TARGETS)
	@$(RM) $(CCOBJS) $(CPPOBJS) $(DEPENDS)
.PHONY: clean

# This will clean everything plus makedepend
cleanall: clean
	@echo -e "\e[1mCleaning makedepend...\e[0m"
	@$(RM) -r $(DEPDIR)
.PHONY: cleanall

# wildcard ensures only to include files that actually exist.
# makedepend should always be built.
-include $(wildcard $(DEPENDS)) $(DEPDIR)/makedepend
