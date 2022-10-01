# Daphne: Data Analysis for the PHysical sciences aNd Engineering

Status: under development; almost nothing works yet

Daphne is (will be) a Fortran library for rigorous data analysis in the physical sciences. Dimensional analysis will prevent many potential bugs, and uncertainty propagation will reveal the limits of what can be understood from the data. Daphne prioritizes correctness over speed, so this library is not intended for HPC.

Initial goal:

- Code header:
    - Outline the code with a numbered table of contents, using the same numbers later in the code in each section.
    - Data dictionary: list variable names, descriptions, and physical units in header.
- Create stdlib-like is_close_wp function? <https://stdlib.fortran-lang.org/page/specs/stdlib_math.html#is_close-function>
- Set up test framework.
    - <https://www.cs.princeton.edu/~bwk/testing.html>
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

Initially, I thought that static typing would mean that I'd get a compile-time check on the dimensions. My planned implementation using operator overloading wouldn't provide that, actually. [There is a Fortran implementation of dimensional analysis providing compile-time checks](https://gitlab.com/everythingfunctional/quaff), but the process is much more complex than I'd prefer. Since speed isn't a factor here, I'm okay with a run-time check.

## Portability notes

Portability is a major concern of mine when writing Daphne. One goal is for Daphne to still be usable in 30 years. I can not predict which compilers will be supported then, so regularly compiler on multiple compilers to identify code that is not portable. I am writing to the Fortran 2003 standard, but coverage of even Fortran 2003 standards can be spotty as of 2022.

- The way nonstdlib.f90 writes to stderr is conventional but not standard and may not be fully portable, as [a standard way to write to stderr was not available until Fortran 2003](https://stackoverflow.com/a/8508757/1124489), but the Oracle Fortran compiler does not implement this part of the standard. The value of `error_unit` in nonstdlib.f90 may need to change depending on the compiler.
