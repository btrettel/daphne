include std.mk

# TODO: Convert source to C or C++ and compile that way as a portability test. Try multiple converters if possible.
# TODO: Add depreciated and obsoleted things in book appendix to linter
# TODO: https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone
# TODO: POSIX Makefile

FC     := gfortran
FFLAGS := -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f95 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface -Wunused --coverage

tests: clean tests.f90 daphne.f90 ## Compile Daphne and run tests
	$(call assert-not-null,FC)
	$(call assert-not-null,FFLAGS)
	$(FC) $(FFLAGS) -o tests daphne.f90 stdlib.f90 tests.f90
	./tests

# gfortran, ifort, ifx, flang-7, f90 (Oracle)
.PHONY: portability
portability: ## Run tests in many compilers
	make tests
	make tests FC=ifort FFLAGS='-warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1'
	make tests FC=ifx FFLAGS='-warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1'
	make tests FC=flang-7 FFLAGS='-g -Wdeprecated'
	make tests FC=f90 FFLAGS='-g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all'

.PHONY: stats
stats: ## Get some statistics for Daphne
	cloc *.f90 --by-percent c

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm --force --verbose tests *.gcda *.gcno *.cmdx *.cmod *.ilm *.stb *.dbg *.o *.mod

# Removed: <https://pypi.org/project/fortran-linter/>, `-fortran-linter --syntax-only tests.f90`
# <https://pypi.org/project/flinter/> (TODO: Make this have appropriate exit codes.)
# <https://github.com/cnescatlab/i-CodeCNES> (Can enforce intent in subroutines with F90.INST.Intent. TODO: Make recognize `implicit none (type, external)` and have appropriate exit codes.)
# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
# TODO: flang-7 --analyze
# gfortran -E daphne.f90 | grep -v '^#' > tmp/daphne.f90
lint: tests.f90 ## Run linters on Daphne
	@mkdir -p tmp/
	flint lint --flintrc /home/ben/.local/share/flint/fortran.yaml daphne.f90 tests.f90 stdlib.f90
	-icode-wrapper.py tests.f90 daphne.f90 stdlib.f90
	rm --recursive --verbose tmp/
