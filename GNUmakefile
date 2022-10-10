# GNU Makefile for Daphne

# <https://innolitics.com/articles/make-delete-on-error/>
.DELETE_ON_ERROR:

# TODO: Convert source to C or C++ and compile that way as a portability test. Try multiple converters if possible.
# TODO: <https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone>
# TODO: <http://fortranwiki.org/fortran/show/Debugging+tools>
# TODO: <https://github.com/MetOffice/stylist>

FC       := gfortran
FFLAGS   := -cpp -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f95 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface -Wunused --coverage -ffree-line-length-72
FPPFLAGS := 
OBIN     := tests
OFLAG    := -o $(OBIN)
ORUN     := ./$(OBIN)
SRC      := daphne.F90 tests.f90
SRC_FPP  := $(patsubst %.F90, %.f90,$(SRC))

.PHONY: check
check: tests ## Compile Daphne and run tests
	$(ORUN)
	@echo Tests on $(FC) ran successfully.

# ELF90, gfortran, ifort, ifx, flang-7, sunf95 (Oracle), FL32 (Microsoft Fortran PowerStation 4.0)
# The reason why ELF90 has the test command is because ELF90 can't return a non-zero exit code. So instead I check for an error file, which, if present, indicates an error.
# ELF90 is first as it is the hardest to satisfy.
# TODO: open64, `open64_flags := -c -Ddouble_precision -fullwarn -col80 -Wuninitialized`
.PHONY: checkport
checkport: ## Run tests in many compilers
	make check FC='wine elf90' FFLAGS='-npause' OBIN='tests.exe' OFLAG='-out tests.exe' ORUN='wine tests.exe && test ! -f error.log' FPPFLAGS='-D__ELF90__ -D__DP__' SRC='daphne.f90 tests.f90'
	make clean
	make tests FC='g95' FFLAGS='-std=F -S' OFLAG='' FPPFLAGS='-D__PURE__=pure' SRC='daphne.f90 tests.f90'
	make clean
	make check
	make clean
	make check FC=ifort FFLAGS='-fpp -warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f90 -debug full -diag-error-limit=1'
	make clean
	make check FC=ifx FFLAGS='-fpp -warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1'
	make clean
	make check FC=flang-7 FFLAGS='-cpp -D__DP__ -g -Wdeprecated'
	make clean
	make check FC=sunf95 FFLAGS='-fpp -g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all -U'
	make clean
	make check FC='wine fl32' FFLAGS='/4L72 /4Yb /4Yd /WX /4Yf /4Ys' OBIN='tests.exe' OFLAG='/Fetests.exe' ORUN='wine tests.exe' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'
	make clean
	@echo Tests on all compilers ran successfully.

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm -rfv daphne.f90 tests *.gcda *.gcno *.cmdx *.cmod *.ilm *.stb *.dbg *.o *.mod *.exe *.obj *.fpl *.FPT modtable.txt *.map *.exe *.mod *.obj *.lib *.s error.log

# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
# FPT spacing warnings are suppressed because ELP90 wants `in out` to have a space, but FPT doesn't like that. I could also do `fpt $(SRC) %"suppress error 2185"`, but FPT prints a message that errors have been suppressed, and this does not. I prefer having cleaner output.
lint: clean $(SRC_FPP) ## Run linters on Daphne
	$(foreach source_file,$(SRC_FPP),echo ; echo $(source_file):; flint lint --flintrc /home/ben/.local/share/flint/fortran.yaml $(source_file);)
	-icode-wrapper.py $(SRC_FPP)
	fpt $(SRC_FPP) %"no warnings for spacing"

.PHONY: stats
stats: ## Get some statistics for Daphne
	cloc $(SRC) --by-percent c

tests: $(SRC)
	$(FC) $(OFLAG) $(FFLAGS) $(SRC)

%.f90: %.F90
	gfortran -E $(FPPFLAGS) $< | grep -v '^#' > $@

# <https://www.thapaliya.com/en/writings/well-documented-makefiles/>
# This should not be the first target. Place at the end.
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
