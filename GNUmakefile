# GNU Makefile for Daphne

# <https://innolitics.com/articles/make-delete-on-error/>
.DELETE_ON_ERROR:

# TODO: <https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone>
# TODO: Branch coverage: <https://stackoverflow.com/a/14523575/1124489>
# TODO: make commit to run lint, coverage, and check before making a commit.

FC       := gfortran
FFLAGS   := -cpp -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f95 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface -Wunused --coverage -ffree-line-length-132 -fimplicit-none
FPPFLAGS := 
OBIN     := tests
OFLAG    := -o $(OBIN)
ORUN     := ./$(OBIN)
SRC      := daphne.F90 tests.F90
SRC_FPP  := $(patsubst %.F90, %.f90,$(SRC))

# gfortran, ELF90, g95 -std=F, ifort, ifx, flang-7, sunf95 (Oracle), FL32 (Microsoft Fortran PowerStation 4.0)
# ELF90 is second as it is hard to satisfy.
# `g95 -std=F` is third as it is also hard to satisfy.
.PHONY: check
check: ## Compile Daphne and run tests in many compilers
	make gfortran
	make clean
	make elf90
	make clean
	make g95
	make clean
	make ifort
	make clean
	make ifx
	make clean
	make flang-7
	make clean
	make sunf95
	make clean
	make openf95
	make clean
	make fl32
	make clean
	make absoft
	make clean
	make ifl
	make clean
	make cvf
	make clean
	make ftn95
	make clean
	@echo Tests on all compilers ran successfully.

.PHONY: checkone
checkone: tests
	$(ORUN)
	@echo Tests on $(FC) ran successfully.

# The reason why ELF90 has the test command is because ELF90 can't return a non-zero exit code. So instead I check for an error file, which, if present, indicates an error.
.PHONY: elf90
elf90: ## Compile Daphne and run tests for ELF90
	make checkone FC='wine elf90' FFLAGS='-npause -fullwarn' OBIN='tests.exe' OFLAG='-out tests.exe' ORUN='wine tests.exe && test ! -f error.log' FPPFLAGS='-D__ELF90__ -D__DP__' SRC='daphne.f90 tests.f90'

# To run in DOSBox as of 2022-10-16, you need to copy the following to the same directory as tests.exe:
# /home/ben/.wine/drive_c/ELF9040/Bin/dosstyle.dll
# /home/ben/.wine/drive_c/ELF9040/Bin/tnt.exe
# /home/ben/.wine/drive_c/ELF9040/Bin/vmm.exp
.PHONY: elf90_dos
elf90_dos: ## Compile Daphne for ELF90 in DOS
	make tests FC='wine elf90' FFLAGS='-npause -fullwarn -nwin' OBIN='tests.exe' OFLAG='-out tests.exe' ORUN='wine tests.exe && test ! -f error.log' FPPFLAGS='-D__ELF90__ -D__DP__' SRC='daphne.f90 tests.f90'

# g95 and openf95 won't produce executables due to obsolete dependencies, but they will compile. That is why those compilers use `make tests` and not `make checkone`: `make tests` won't run the executable.
.PHONY: g95
g95: ## Compile Daphne and run tests for g95 -std=F
	make tests FC='g95' FFLAGS='-std=F -S' OFLAG='' FPPFLAGS='-D__F__' SRC='daphne.f90 tests.f90'

.PHONY: gfortran
gfortran: ## Compile Daphne and run tests for gfortran
	make checkone

.PHONY: ifort
ifort: ## Compile Daphne and run tests for ifort
	make checkone FC=ifort FFLAGS='-fpp -warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f90 -debug full -diag-error-limit=1'

.PHONY: ifx
ifx: ## Compile Daphne and run tests for ifx
	make checkone FC=ifx FFLAGS='-fpp -warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1'

.PHONY: flang-7
flang-7: ## Compile Daphne and run tests for flang-7
	make checkone FC=flang-7 FFLAGS='-cpp -D__DP__ -g -Wdeprecated'

.PHONY: sunf95
sunf95: ## Compile Daphne and run tests for sunf95
	make checkone FC=sunf95 FFLAGS='-fpp -g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all -U'

# lfortran -c --cpp -D__DP__ -D__F__ daphne.F90 tests.F90
# lfortran daphne.o tests.o
# The second step is necessary because linking doesn't work in one step for some reason: <https://fortran-lang.discourse.group/t/lfortran-minimum-viable-product-mvp/1922/10>
.PHONY: lfortran
lfortran: ## Compile Daphne and run tests for lfortran
	make tests FC=lfortran FFLAGS='-c --cpp -D__DP__ -D__F__'
	lfortran daphne.o tests.o
	make checkone

# See comment above about g95 for why this is `make tests` and not `make checkone`.
.PHONY: openf95
openf95: ## Compile Daphne and run tests for openf95
	make tests FC=openf95 FFLAGS='-c -D__DP__ -fullwarn -Wuninitialized'

.PHONY: fl32
fl32: ## Compile Daphne and run tests for fl32
	make checkone FC='wine fl32' FFLAGS='/4L132 /4Yb /4Yd /WX /4Yf' OBIN='tests.exe' OFLAG='/Fetests.exe' ORUN='wine tests.exe' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'

.PHONY: absoft
absoft: ## Compile Daphne and run tests for absoft
	make checkone FC='wine f95' FFLAGS='-en -ea -Rb -Rc -Rs -Rp' OBIN='tests.exe' OFLAG='-o tests.exe' ORUN='wine tests.exe' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'

# Using the ifl preprocessor causes Wine to crash. `FFLAGS='/Qfpp /D__DP__'`
# /d1 or /d2 seem to cause ifl to crash.
# Using /CV (or /4Yb or /C as those enable /CV) causes an "** Address Error **" at runtime.
.PHONY: ifl
ifl: ## Compile Daphne and run tests for ifl
	make checkone FC='wine ifl' FFLAGS='/CA /CB /CS /CU /4Yd /4Ys' OBIN='tests.exe' OFLAG='/Fetests.exe' ORUN='wine tests.exe' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'

# Using the cvf preprocessor causes Wine to crash. /fpp:"__DP__"
.PHONY: cvf
cvf: ## Compile Daphne and run tests for cvf
	make checkone FC='wine f90' FFLAGS='/check:all /stand:f90 /warn:all' OBIN='tests.exe' OFLAG='/exe:tests.exe' ORUN='wine tests.exe' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'

.PHONY: ftn95
ftn95: $(SRC_FPP) ## Compile Daphne and run tests for ftn95
	#make tests FC='wine ftn95' FFLAGS='/link /checkmate /iso /restrict_syntax /implicit_none /errorlog' OBIN='tests.exe' OFLAG='' ORUN='wine tests.EXE' FPPFLAGS='-D__DP__' SRC='daphne.f90 tests.f90'
	gfortran -E '-D__DP__' daphne.F90 | grep -v '^#' > daphne.f95
	gfortran -E '-D__DP__' tests.F90 | grep -v '^#' > tests.f95
	wine ftn95 /checkmate /iso /restrict_syntax /errorlog daphne.f95
	wine ftn95 /link /checkmate /iso /restrict_syntax /errorlog tests.f95
	mv daphne.f95 daphne.f90
	mv tests.f95 tests.f90
	wine tests.EXE
	@echo Tests on ftn95 ran successfully.

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm -rfv *.cmdx *.cmod *.d *.dbg *.ERR error.log *.exe *.EXE *.f90 *.f95 fail *.FPI *.fpl *.FPT *.gcda *.gcno *.gcov html-cov/ *.ilm *.info *.lib *.map *.mod *.MOD modtable.txt *.o *.obj *.pc *.pcl *.s *.stb tests

# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
# FPT spacing warnings are suppressed because ELP90 wants `in out` to have a space, but FPT doesn't like that. FPT prints a message that errors have been suppressed. That's somewhat annoying. Using `%"no warnings for spacing"` instead doesn't have that message. I prefer having cleaner output. I used that approach for a while until I ran into another problem that FPT doesn't like and I had to disable that message too.
# 3437: FPT seems to think that (for example) `rel_tol_set = 10.0_wp*EPSILON(1.0_wp)` is a "Mixed real or complex sizes in expression - loss of precision", but it's not. `epsilon` returns the same kind as its argument. This sort of problem seems better detected by the other compilers, so I'm okay with disabling this message.
lint: $(SRC_FPP) $(SRC) ## Run linters on Daphne
	$(foreach source_file,$(SRC_FPP),echo ; echo $(source_file):; flint lint --flintrc /home/ben/.local/share/flint/fortran.yaml $(source_file);)
	-icode-wrapper.py $(SRC_FPP)
	rm -fv *.FPT *.FPI *.fpl
	fpt $(SRC) %"suppress error 2185 3425 3437"

.PHONY: stats
stats: ## Get some statistics for Daphne
	cloc $(SRC) --by-percent c

tests: $(SRC)
	#./preal_checks.py tests.F90
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
	@echo Assertion fails properly.

# <https://www.thapaliya.com/en/writings/well-documented-makefiles/>
# This should not be the first target. Place at the end.
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
