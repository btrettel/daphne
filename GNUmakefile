# GNU Makefile for Daphne

# <https://innolitics.com/articles/make-delete-on-error/>
.DELETE_ON_ERROR:

# TODO: Convert source to C or C++ and compile that way as a portability test. Try multiple converters if possible.
# TODO: https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone
# TODO: Try compiling with the Fortran Standard Library instead of your own nonstdlib.f90.

FC       := gfortran
FFLAGS   := -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f2003 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface -Wunused --coverage -ffree-line-length-72
OBIN     := tests
OFLAG    := -o $(OBIN)
ORUN     := ./$(OBIN)
SRC      := $(shell find ./ -maxdepth 1 -type f -name "*.f90")
SPAG_SRC := $(patsubst %.f90, tmp/%.f90,$(SRC))
SPAG_SMB := $(patsubst %.f90, SPAGged/%.smb,$(SRC))

.PHONY: check
check: tests ## Compile Daphne and run tests
	$(ORUN)

# gfortran, ifort, ifx, flang-7, f90 (Oracle)
.PHONY: checkport
checkport: ## Run tests in many compilers
	make check
	make clean
	make check FC=ifort FFLAGS='-warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f03 -debug full -diag-error-limit=1'
	make clean
	make check FC=ifx FFLAGS='-warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f03 -debug full -diag-error-limit=1'
	make clean
	make check FC=flang-7 FFLAGS='-g -Wdeprecated'
	make clean
	make check FC=f90 FFLAGS='-g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all -U'
	make clean

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm -rfv tests *.gcda *.gcno *.cmdx *.cmod *.ilm *.stb *.dbg *.o *.mod *.exe *.obj *.fpl *.FPT

# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
lint: clean $(SRC) ## Run linters on Daphne
	$(foreach source_file,$(SRC),flint lint --flintrc /home/ben/.local/share/flint/fortran.yaml $(source_file);)
	-icode-wrapper.py $(SRC)
	fpt $(SRC)

.PHONY: stats
stats: ## Get some statistics for Daphne
	cloc $(SRC) --by-percent c

tests: $(SRC)
	$(FC) $(OFLAG) $(FFLAGS) $(SRC)

# <https://www.thapaliya.com/en/writings/well-documented-makefiles/>
# This should not be the first target. Place at the end.
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
