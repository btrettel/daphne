# GNU Makefile for Daphne

# <https://innolitics.com/articles/make-delete-on-error/>
.DELETE_ON_ERROR:

# TODO: Convert source to C or C++ and compile that way as a portability test. Try multiple converters if possible.
# TODO: Add depreciated and obsoleted things in book appendix to linter
# TODO: https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone

FC      := gfortran
FFLAGS  := -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f95 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface -Wunused --coverage -ffree-line-length-72
OBIN    := tests
OFLAG   := -o $(OBIN)
ORUN    := ./$(OBIN)
SOURCES := daphne.f90 stdlib.f90 tests.f90

.PHONY: check
check: tests ## Compile Daphne and run tests
	$(ORUN)

# gfortran, ifort, ifx, flang-7, f90 (Oracle), FL32 (Microsoft Fortran PowerStation 4.0)
.PHONY: checkport
checkport: ## Run tests in many compilers
	make check
	make clean
	make check FC=ifort FFLAGS='-warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1'
	make clean
	make check FC=ifx FFLAGS='-warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1'
	make clean
	make check FC=flang-7 FFLAGS='-g -Wdeprecated'
	make clean
	make check FC=f90 FFLAGS='-g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all'
	make clean
	make check FC='wine ~/.wine/drive_c/MSDEV/BIN/FL32.EXE' FFLAGS='/4L72 /4Yb /4Yd /WX /4Yf /4Ys' OBIN='tests.exe' OFLAG='/Fetests.exe' ORUN='wine tests.exe'
	make clean

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm -fv tests *.gcda *.gcno *.cmdx *.cmod *.ilm *.stb *.dbg *.o *.mod *.exe *.obj *.fpl

# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
lint: $(SOURCES) ## Run linters on Daphne
	flint lint --flintrc /home/ben/.local/share/flint/fortran.yaml $(SOURCES)
	-icode-wrapper.py $(SOURCES)

.PHONY: stats
stats: ## Get some statistics for Daphne
	cloc $(SOURCES) --by-percent c

tests: $(SOURCES)
	$(FC) $(OFLAG) $(FFLAGS) $(SOURCES)

# <https://www.thapaliya.com/en/writings/well-documented-makefiles/>
# This should not be the first target. Place at the end.
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
