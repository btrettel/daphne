# Daphne: Data Analysis for the PHysical sciences aNd Engineering

Status: under development; almost nothing works yet

Daphne is (will be) a Fortran library for rigorous data analysis in the physical sciences. Dimensional analysis will prevent many potential bugs, and uncertainty propagation will reveal the limits of what can be understood from the data. Daphne prioritizes correctness over speed, so this library is not intended for HPC.

Next steps:

- Switch to preprocessor.
    - Add (optional) file and line numbers to `check`.
    - `__CHECK(` expands to `check(file="__FILE__", line="__LINE__"`
        - This is perhaps the most important reason to use the preprocessor. I don't think it's possible otherwise to get the line numbers.
    - Compile each file individually.
    - Add preprocessor directive to get Git revision number so you can put it in the output.
- Move `logical_test`, `real_comparison_test`, and `tests_end` to tests.f90.
- Make array operators work in 2D arrays.
- Add tests for 2D arrays.
- Add `all_close_wp` function. <https://stdlib.fortran-lang.org/page/specs/stdlib_math.html#all_close-function>
- Dimensional homogeneity enforced for length, mass, and time.
- First-order uncertainty propagation for uncorrelated variables.

Later:

- Regression considering uncertainties for uncorrelated variables.
- Add correlation for uncertainty propagation and regression.

## Philosophy

Previously, I used Python with the [Pint](https://github.com/hgrecco/pint) package for dimensional analysis and the [uncertainties](https://github.com/lebigot/uncertainties) package for uncertainty propagation.

The integration of Pint, uncertainties, and numpy isn't as well supported as I'd like ([1](https://github.com/hgrecco/pint/issues/918), [2](https://github.com/xarray-contrib/pint-xarray/issues/3), [3](https://github.com/lebigot/uncertainties/issues/86)). To my knowledge, there are no libraries that do both dimensional analysis and uncertainty propagation. If both are desired, it seems logical to write a single library to cleanly handle both. Fortran is a natural choice here due to the native support of arrays.

Another significant advantage of Fortran is stability. When coding with Python, [I'm unsure whether my code will still work in 10 years due to evolving APIs and external dependencies which may become unsupported](https://www.nature.com/articles/d41586-020-02462-7):

> Counter-intuitively, many challenge participants found that code written in older languages was actually the easiest to reuse. Newer languages’ rapidly evolving APIs and reliance on third-party libraries make them vulnerable to breaking.

Consequently, I am avoiding languages with relatively rapid changes like Python. I am also avoiding external dependencies, instead preferring my own implementation whenever possible. Implementing everything on my own also has the advantage of improving my understanding of how various planned components of Daphne work.

There is one simple test for longevity: Can the code be run unmodified on an old compiler? If so, then the APIs and dependencies are stable over a long time frame. I test this by compiling Daphne on Microsoft Fortran PowerStation 4.0 from 1995. If Daphne compiles and runs using both an up-to-date compiler and a 20-30 year old compiler, then it probably will still compile and run in 20-30 years.

Initially, I thought that static typing would mean that I'd get a compile-time check on the dimensions. Actually, though, my planned implementation using operator overloading wouldn't provide that. [There is a Fortran implementation of dimensional analysis providing compile-time checks](https://gitlab.com/everythingfunctional/quaff), but the process is much more complex than I'd prefer. Since speed isn't a factor here, I'm okay with a run-time check.

## Portability notes

Portability is a major concern of mine when writing Daphne. As stated earlier, one goal is for Daphne to still be usable in 30 years. I can not predict which compilers will be supported then, so regularly compile on multiple compilers to identify code that is not portable. I am writing to the Fortran 90 standard, as coverage of even the Fortran 2003 standard can be spotty as of 2022. Targeting Fortran 90 unfortunately leads to some portability concerns in itself.

- The way nonstdlib.f90 writes to stderr is conventional but not standard and may not be fully portable. [A standard way to write to stderr was not available until Fortran 2003](https://stackoverflow.com/a/8508757/1124489), but the Oracle Fortran compiler does not implement this part of the standard. The value of `error_unit` in nonstdlib.f90 may need to change depending on the compiler. The following compilers do not appear to write to stderr based on the default value of `error_unit` (0) in nonstdlib.f90:
    - Microsoft Fortran PowerStation 4.0 (The documentation does not mention any way to write to stderr, so this compiler may not be able to.)

### Compilers Daphne has been tested with

- gfortran 9.4.0
- ifort 2021.6.0
- ifx 2022.1.0
- flang-7 7.0.1
- Oracle Developer Studio 12.6 Fortran Compiler, version 8.8
- Microsoft Fortran PowerStation 4.0a
- Essential Lahey Fortran 90 4.00b
