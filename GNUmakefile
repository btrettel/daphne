# # $File$
# 
# Summary: GNU Makefile for Daphne
# Author: Ben Trettel (<http://trettel.us/>)
# Last updated: $Date$
# Revision: $Revision$
# Project: [Daphne](https://github.com/btrettel/daphne)
# License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

# <https://innolitics.com/articles/make-delete-on-error/>
.DELETE_ON_ERROR:

# TODO: <https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone>
# TODO: make commit to run lint, coverage, and check before making a commit.
# TODO: https://github.com/MetOffice/stylist
# TODO: Convert to fixed format with findent, run through SPAG.

FC          := gfortran
FFLAGS      := -cpp -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f2003 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-logical=true -finit-derived -Wimplicit-interface -Wunused --coverage -ffree-line-length-132 -fimplicit-none
FPPFLAGS    := 
OBIN        := tests
OFLAG       := -o $(OBIN)
ORUN        := ./$(OBIN)
SRC         := daphne.F90 tests.F90
SRC_FPP     := $(patsubst %.F90, %.f90,$(SRC))
SRC_ALL     := daphne.F90 tests.F90 fail.F90
SRC_ALL_FPP := $(patsubst %.F90, %.f90,$(SRC_ALL))

# FTN95 is second as it is hard to satisfy.
.PHONY: check
check: ## Compile Daphne and run tests in many compilers
	make gfortran
	make clean
	make ftn95
	make clean
	make ifort
	make clean
	make ifx
	make clean
	make flang-7
	make clean
	make sunf95
	make clean
	@echo "\033[0;32mTests on all compilers ran successfully.\033[0m"

.PHONY: checkone
checkone: tests
	$(ORUN)
	@echo "\033[0;32mTests on $(FC) ran successfully.\033[0m"

.PHONY: gfortran
gfortran: ## Compile Daphne and run tests for gfortran
	make checkone

# TODO: `-init=` to help detect uninitialized variables. Ideally `logical`s will be set to `.true.` so that flags are by default on, which would return an error if `check_flag` were run.
.PHONY: ifort
ifort: ## Compile Daphne and run tests for ifort
	make checkone FC=ifort FFLAGS='-fpp -warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f2003 -debug full -diag-error-limit=1'

.PHONY: ifx
ifx: ## Compile Daphne and run tests for ifx
	make checkone FC=ifx FFLAGS='-fpp -warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f2003 -debug full -diag-error-limit=1'

.PHONY: flang-7
flang-7: ## Compile Daphne and run tests for flang-7
	make checkone FC=flang-7 FFLAGS='-cpp -D__DP__ -g -Wdeprecated'

.PHONY: sunf95
sunf95: ## Compile Daphne and run tests for sunf95
	make checkone FC=sunf95 FFLAGS='-fpp -g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all -U'

# lfortran -c --cpp -D__DP__ daphne.F90 tests.F90
# lfortran daphne.o tests.o
# The second step is necessary because linking doesn't work in one step for some reason: <https://fortran-lang.discourse.group/t/lfortran-minimum-viable-product-mvp/1922/10>
.PHONY: lfortran
lfortran: ## Compile Daphne and run tests for lfortran
	make tests FC=lfortran FFLAGS='-c --cpp -D__DP__'
	lfortran daphne.o tests.o
	make checkone

.PHONY: ftn95
ftn95: $(SRC_FPP) ## Compile Daphne and run tests for ftn95
	#make tests FC='wine ftn95' FFLAGS='/link /checkmate /iso /restrict_syntax /implicit_none /errorlog' OBIN='tests.exe' OFLAG='' ORUN='wine tests.EXE' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'
	gfortran -E -D__DP__ -D__FTN95__ daphne.F90 | grep -v '^#' > daphne.f95
	gfortran -E -D__DP__ -D__FTN95__ tests.F90 | grep -v '^#' > tests.f95
	wine ftn95 /checkmate /iso /restrict_syntax /errorlog daphne.f95
	wine ftn95 /link /checkmate /iso /restrict_syntax /errorlog tests.f95
	mv daphne.f95 daphne.f90
	mv tests.f95 tests.f90
	wine tests.EXE
	@echo "\033[0;32mTests on ftn95 ran successfully.\033[0m"

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm -rfv *.cmdx *.cmod *.d *.dbg *.ERR error.log *.exe *.EXE *.f90 *.f95 fail *.FPI *.fpl *.FPT *.gcda *.gcno *.gcov html-cov/ *.ilm *.info *.lib *.map *.mod *.MOD modtable.txt *.o *.obj *.pc *.pcl *.s *.stb tests

# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
# 3437: FPT seems to think that (for example) `rel_tol_set = 10.0_wp*EPSILON(1.0_wp)` is a "Mixed real or complex sizes in expression - loss of precision", but it's not. `epsilon` returns the same kind as its argument. This sort of problem seems better detected by the other compilers, so I'm okay with disabling this message.
# FPT has false positives for `use, intrinsic :: iso_fortran_env, only: error_unit` (it says "Non-standard Fortran intrinsic(s) used as local identifier(s)" and "Unused sub-programs encountered"). So I disabled those messages.
# 2022-11-26: iCode-CNES has issues with pure procedures. So I've removed the pure keyword for the time being.
lint: $(SRC_ALL_FPP) $(SRC_ALL) ## Run linters on Daphne
	$(foreach source_file,$(SRC_ALL_FPP),echo ; echo $(source_file):; flint lint --flintrc /home/ben/.local/share/flint/f90.yaml $(source_file);)
	-icode-wrapper.py $(SRC_ALL_FPP)
	rm -fv *.FPT *.FPI *.fpl
	fpt $(SRC_ALL) %"suppress error 1271 1867 2449 3425 3437"

.PHONY: stats
stats: ## Get some statistics for Daphne
	cloc $(SRC) --by-percent c

tests: $(SRC)
	./preal_checks.py tests.F90 fail.F90
	$(FC) $(OFLAG) $(FFLAGS) $(SRC)

%.f90: %.F90 header.F90
	gfortran -E $(FPPFLAGS) $< | grep -v '^#' > $@

.PHONY: coverage
coverage:
	make gfortran
	lcov --directory . --capture --output-file lcov_1.info
	rm -v *.gcda *.gcno tests
	make fail
	lcov --directory . --capture --output-file lcov_2.info
	lcov --add-tracefile lcov_1.info --add-tracefile lcov_2.info --output-file lcov.info
	genhtml -t "Daphne" -o html-cov ./lcov.info

fail:
	make tests FFLAGS='-cpp -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f95 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface --coverage -ffree-line-length-132 -fimplicit-none' SRC='daphne.F90 fail.F90' OFLAG='-o fail'
	if ./fail; then echo Assertion does not fail properly. ; exit 1; fi
	@echo "\033[0;32mAssertion fails properly.\033[0m"

# <https://www.thapaliya.com/en/writings/well-documented-makefiles/>
# This should not be the first target. Place at the end.
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
