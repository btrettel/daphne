# Daphne: Data Analysis for the PHysical sciences aNd Engineering

Status: under development; almost nothing works yet

Daphne is (will be) a Fortran library for rigorous data analysis in the physical sciences. Dimensional analysis will prevent many potential bugs, and uncertainty propagation will reveal the limits of what can be understood from the data. Daphne prioritizes correctness over speed, so this library is not intended for HPC.

Target features for first significant version:

- testing
- reading CSV files
- dimensional analysis
- first-order uncertainty propagation without covariance
- 2D plotting
- regression

Next steps:

- Add to Daphne's preal type a member variable for whether the value was set, in order to catch uninitialized preals. This is .false. by default and set to .true. when a constructor is used. It will be checked by the same verification procedure used for the flag.
- Get Daphne to compile with LFortran by adding preprocessor directives.
- Add optional file and line arguments for `is_close_wp` and add an associated preprocessor macro to automatically include the file and line number.
- Make generic `is_close` with different functions for different types of reals.
- Make `~=` operator for different types of reals with default tolerances.
    - <https://www.reddit.com/r/fortran/comments/ixnj5p/best_practices_for_comparing_reals/>
    - <http://www.lahey.com/float.htm
        - > A better technique is to compare the absolute value of the difference of two numbers with an appropriate epsilon to get relations like approximately equal, definitely greater than, etc.
        - Make `~>` and `~<` operators for definitely greater than and definitely less than.
- Tests for propagation of flags. If mathematical operation is performed, flag must be propagated to output.
- Add tests for boundary of `is_close_wp`. <https://jasonrudolph.com/blog/2008/07/01/testing-anti-patterns-overspecification/>
- Switch `validate_preal` to work with both scalars and arrays
- Make `assert_flag` have different scalar and array versions. Set `preal%flag = .true.` for all array elements when condition is not met.
- Test that the output array has the same dimensions as the input arrays.
- Test that operations fail if the arrays don't have the same dimensions.
- Add fail2.F90 to test `assert` failure.
- Add fail3.F90 to test `check_flag` failure.
- Increase branch coverage.
- Figure out why FPT didn't like the function passing example you made.
    - /home/ben/archives/dated/2022/10/2022-10-11/function_argument/function_argument_elf90.f90
- Alphabetize `use`, `public`, `private`, and `type` statements. In each procedure section, alphabetize the procedures.
- How can the `intent` be indicated if I pass in a function into a procedure and use an `interface` block to make the function explicit and not `external`? `intent` statement?
- Make array operators work in 2D arrays.
- Add tests for 2D arrays.
- Add `all_close_wp` function. <https://stdlib.fortran-lang.org/page/specs/stdlib_math.html#all_close-function>
- Add exponentiation operator.
- <https://en.wikipedia.org/wiki/Augmented_assignment>
    - This is convenient and can prevent bugs from typing the variable name in in correctly.
- <https://en.wikipedia.org/wiki/Increment_and_decrement_operators>
- Dimensional homogeneity enforced for length, mass, and time.
- First-order uncertainty propagation for uncorrelated variables.

Later:

- Linear regression considering uncertainties for uncorrelated variables.
- Add correlation for uncertainty propagation and regression.
- Property testing for code
- Mutation testing for code
    - Getting started: Pick a random line. Change one thing about this line.
- Fuzz testing for inputs
    - <https://blog.trailofbits.com/2018/12/31/fuzzing-like-its-1989/>
    - <https://www.sqlite.org/testing.html#sql_fuzz_using_the_american_fuzzy_lop_fuzzer>

## Philosophy

Previously, I used Python with the [Pint](https://github.com/hgrecco/pint) package for dimensional analysis and the [uncertainties](https://github.com/lebigot/uncertainties) package for uncertainty propagation.

The integration of Pint, uncertainties, and numpy isn't as well supported as I'd like ([1](https://github.com/hgrecco/pint/issues/918), [2](https://github.com/xarray-contrib/pint-xarray/issues/3), [3](https://github.com/lebigot/uncertainties/issues/86)). To my knowledge, there are no libraries that do both dimensional analysis and uncertainty propagation. If both are desired, it seems logical to write a single library to cleanly handle both. Fortran is a natural choice here due to the native support of arrays.

Another significant advantage of Fortran is stability. When coding with Python, [I'm unsure whether my code will still work in 10 years due to evolving APIs and external dependencies which may become unsupported](https://www.nature.com/articles/d41586-020-02462-7):

> Counter-intuitively, many challenge participants found that code written in older languages was actually the easiest to reuse. Newer languages’ rapidly evolving APIs and reliance on third-party libraries make them vulnerable to breaking.

Consequently, I am avoiding languages with relatively rapid changes like Python. I am also avoiding external dependencies, instead preferring my own implementation whenever possible. Implementing everything on my own also has the advantage of improving my understanding of how various planned components of Daphne work.

Initially, I thought that static typing would mean that I'd get a compile-time check on the dimensions. Actually, though, my planned implementation using operator overloading wouldn't provide that. [There is a Fortran implementation of dimensional analysis providing compile-time checks](https://gitlab.com/everythingfunctional/quaff), but the process is much more complex than I'd prefer. Since speed isn't a factor here, I'm okay with a run-time check.

## Portability notes

Portability is a major concern of mine when writing Daphne. As stated earlier, one goal is for Daphne to still be usable in 30 years. I can not predict which compilers will be supported then, so regularly compile on multiple compilers to identify code that is not portable. I am writing to a subset of the Fortran 2003 standard, as coverage of more recent standards can be spotty as of 2022.

### Compilers Daphne has been tested with

- gfortran 9.4.0
- ifort 2021.6.0
- ifx 2022.1.0
- flang-7 7.0.1
- Oracle Developer Studio 12.6 Fortran Compiler, version 8.8
- Silverfrost Fortran (FTN95) Personal Edition 8.90 (Win32 in Wine)

### Compilers Daphne doesn't work in yet

- LFortran 0.16.0 (LFortran lacks some Fortran 90 features Daphne uses)
