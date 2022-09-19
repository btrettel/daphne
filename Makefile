include std.mk

# TODO: Add documentation for each target with ## comment on the target line.
# TODO: Convert source to C or C++ and compile that way as a portability test. Try multiple converters if possible.
# TODO: Which line length is most portable? Set up Fortran linters and compilers to be consistent on line length.
# TODO: Add depreciated and obsoleted things in book appendic to linter
# TODO: https://github.com/llvm/llvm-project/tree/main/flang/#building-flang-standalone

# Fortran 2018: -std=f2018
gfortran_flags := -cpp -Og -g -Wall -Wextra -Werror -pedantic-errors -std=f95 -Wconversion -Wconversion-extra -fimplicit-none -fcheck=all -fbacktrace -fmax-errors=1 -fno-unsafe-math-optimizations -ffpe-trap=invalid,zero,overflow,underflow,denormal -finit-real=nan -finit-integer=-2147483647 -finit-derived -Wimplicit-interface -Wunused --coverage
# Descriptions from `gfortran --help=common` or `gfortran --help=warnings` unless otherwise specified:
# 
# -Og: Optimize for debugging experience rather than speed or size.
# -ggdb: Generate debug information in default extended format.
# -Wall: Enable most warning messages.
# -Wextra: Print extra (possibly unwanted) warnings.
# -Werror: Treat all warnings as errors.
# -pedantic-errors: Issue errors needed for strict compliance to the standard.
# -std=f2018: "Specify the standard to which the program is expected to conform" (<https://gcc.gnu.org/onlinedocs/gfortran/Fortran-Dialect-Options.html>)
# -Wconversion and -Wconversion-extra: Warn about implicit type conversions.
# -fimplicit-none: Specify that no implicit typing is allowed, unless overridden by explicit IMPLICIT statements. (<https://gcc.gnu.org/onlinedocs/gfortran/Fortran-Dialect-Options.html>)
# -fcheck=all: Enable all run-time checks. <https://gcc.gnu.org/onlinedocs/gfortran/Code-Gen-Options.html>
# -fbacktrace: Specify that, when a runtime error is encountered or a deadly signal is emitted (segmentation fault, illegal instruction, bus error or floating-point exception), the Fortran runtime library should output a backtrace of the error. (<https://gcc.gnu.org/onlinedocs/gcc-4.5.4/gfortran/Debugging-Options.html>)
# -fmax-errors=1: Maximum number of errors to report.
# -fno-unsafe-math-optimizations: Don't allow math optimizations that may violate IEEE or ISO standards.
# -ffpe-trap=invalid,zero,overflow,underflow,inexact,denormal: Specify a list of floating point exception traps to enable. On most systems, if a floating point exception occurs and the trap for that exception is enabled, a SIGFPE signal will be sent and the program being aborted, producing a core file useful for debugging. (<https://gcc.gnu.org/onlinedocs/gfortran/Debugging-Options.html>)
# inexact seems to lead to compilation errors: "Program received signal SIGFPE: Floating-point exception - erroneous arithmetic operation." As the docs say: "Many, if not most, floating point operations incur loss of precision due to rounding, and hence the ffpe-trap=inexact is likely to be uninteresting in practice." It would be nice to be able to set a threshold that activates this trap.
# -finit-real=snan and -finit-integer=-2147483647: Initializes reals as NaN. This should help catch uninitialized variables as they normally are initialized with values. It's not clear to me they'll do much anything different than regular NaNs based on what I've read (`-fsignaling-nans` is related) (<https://gcc.gnu.org/onlinedocs/gfortran/Code-Gen-Options.html>)
# -finit-derived: components of derived type variables will be initialized according to the other flags
# -Wimplicit-interface: Warn about calls with implicit interface.
# -Wunused: Enable all -Wunused- warnings.

# Not part of runs of Daphne as a library:
# -ftest-coverage: "Create data files needed by "gcov"." (`gfortran --help=common`)

# Based on:
# <https://github.com/firemodels/fds/blob/master/Build/makefile>
# <https://fortran-lang.discourse.group/t/compilation-flags-advice-for-production-and-distribution/2821/2>
# Fortran 2018: -stand:f18
ifort_flags := -fpp -warn errors -check all -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1
# -init:snan,arrays -ftrapuv: Both of these check if variables are [*initialized*](https://www.intel.com/content/www/us/en/developer/articles/technical/detection-of-uninitialized-floating-point-variables-in-intel-fortran.html). Since I'm intentionally *not* initializing variables to avoid the annoying SAVE attribute problem, I'm turning this off. For some reason this doesn't cause a problem with using quad precision but it does cause a problem for double precision.
# -warn errors: "Tells the compiler to change all warning-level messages to error-level messages"
# -warn all: "This option does not set options warn errors or warn stderrors."
# -CB: redundant with --check all

# While ifx is reportedly mostly Fortran 95, it seems to be working fine with the `REAL128` Fortran 2008 feature.
ifx_flags := -fpp -warn errors -warn all -diag-error=remark,warn,error -O0 -g -traceback -fpe0 -fltconsistency -stand:f95 -debug full -diag-error-limit=1
# -check all on 2022-09-13: remark #5415: Feature not yet implemented: Some 'check' options temporarily disabled

flang7_flags := -cpp -Ddouble_precision -g -Wdeprecated

# <https://docs.oracle.com/cd/E19205-01/819-5263/aevdk/index.html>
# <http://www.fortran-2000.com/ArnaudRecipes/CompilerTricks.html#SUN>
oracle_flags := -fpp -g -w4 -errwarn=%all -e -fnonstd -stackvar -ansi -C -fpover -xcheck=%all

lfortran_flags := -c --cpp -Ddouble_precision

open64_flags := -c -Ddouble_precision -fullwarn -col80 -Wuninitialized
# -c is necessary to produce only a .o file. For some reason the compiler fails when linking, probably due to its age making some dependency break.

tests: clean tests.f90 daphne.F90 ## Compile Daphne and run tests
	$(call assert-not-null,gfortran_flags)
	gfortran $(gfortran_flags) -o tests_gfortran daphne.F90 stdlib.f90 tests.f90
	./tests_gfortran
	$(call assert-not-null,ifort_flags)
	ifort $(ifort_flags) -o tests_ifort daphne.F90 stdlib.f90 tests.f90
	./tests_ifort
	ifx $(ifx_flags) -o tests_ifx daphne.F90 stdlib.f90 tests.f90
	./tests_ifx
	flang-7 $(flang7_flags) -o tests_flang7 daphne.F90 stdlib.f90 tests.f90
	./tests_flang7
	/home/ben/bin/developerstudio12.6/bin/f90 $(oracle_flags) -o tests_oracle daphne.F90 stdlib.f90 tests.f90
	./tests_oracle
	#/home/ben/bin/lfortran-0.16.0/bin/lfortran $(lfortran_flags) daphne.F90 tests.f90
	#/home/ben/bin/lfortran-0.16.0/bin/lfortran -o tests_lfortran daphne.o tests.o
	#./tests_lfortran
	openf95 $(open64_flags) -o tests_open64.o daphne.F90 stdlib.f90 tests.f90
	@echo All tests ran successfully.

.PHONY: clean
clean: ## Remove compiled binaries and debugging files
	rm --force --verbose tests_* *.gcda *.gcno *.cmdx *.cmod *.ilm *.stb *.dbg *.o

# Removed: <https://pypi.org/project/fortran-linter/>, `-fortran-linter --syntax-only tests.f90`
# <https://pypi.org/project/flinter/> (TODO: Make this have appropriate exit codes.)
# <https://github.com/cnescatlab/i-CodeCNES> (Can enforce intent in subroutines with F90.INST.Intent. TODO: Make recognize `implicit none (type, external)` and have appropriate exit codes.)
# This needs to be run on Ben Trettel's computer as I am using a custom YAML file for CERFACS flint and wrote a wrapper script to interpret the XML output by i-Code CNES.
# TODO: flang-7 --analyze
lint: tests.f90 ## Run linters on Daphne
	@mkdir -p tmp/
	gfortran -E daphne.F90 | grep -v '^#' > tmp/daphne.f90
	flint lint --flintrc /home/ben/.local/share/flint/fortran.yaml tmp/daphne.f90 tests.f90
	-icode-wrapper.py tests.f90 tmp/daphne.f90
	rm --recursive --verbose tmp/
