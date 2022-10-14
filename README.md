# Daphne: Data Analysis for the PHysical sciences aNd Engineering

Status: under development; almost nothing works yet

Daphne is (will be) a Fortran library for rigorous data analysis in the physical sciences. Dimensional analysis will prevent many potential bugs, and uncertainty propagation will reveal the limits of what can be understood from the data. Daphne prioritizes correctness over speed, so this library is not intended for HPC.

Next steps:

- Compile with lfortran.
    - Submit bug report for "semantic error: `unit` must be of type, Integer"
- Make `use`, `public`, `private`, and `type` statements alphabetical. In each procedure section, alphabetize the procedures.
- Add multiple tests that are expected to fail.
    - `check(.false., [...])`
    - `error_stop([...])`
- How can the `intent` be indicated if I pass in a function into a procedure and use an `interface` block to make the function explicit and not `external`? `intent` statement?
- `__OUTER:__`, `__MIDDLE:__`, `__INNER:__`, `__OUTER__`, `__MIDDLE__`, `__INNER__`
- Change `check` to `assert` and `CHECK` to `ASSERT`. Change all instances of `check` aside from its subroutine to be `CHECK` to get line numbers. Make `msg` the last argument of `check` to better handle multiple lines?
    - Problem: [All preprocessor macros are limited to one line](https://gcc.gnu.org/onlinedocs/cpp/Newlines-in-Arguments.html). So perhaps the only way around this is to make the message a string variable and not worry about the length.
- Switch to 132 characters per line to be less annoying?
    - This would make the `ASSERT` macro safer as I'd be much less likely to make the line too long.
    - Is FL32 the only one with the 72 character limit? I could turn off the Fortran 90 compliance mode if that really does require 72 characters per line. I'm already getting standards compliance checking from multiple other compilers. Whatever benefit I'm getting from FL32's Fortran 90 mode presumably is small.
    - Check if all compilers can take more than 132 characters. Check even `g95 -std=F`, as that might not enforce the 132 character limit in F.
    - I recall that Intel's documentation says that they limit lines to 132 characters no matter what.
- Create preprocessor header to have `ASSERT` macro, `__PURE__` macro logic, and Git revision number.
- Move `logical_test`, `real_comparison_test`, and `tests_end` to tests.f90 under `contains` for the `program`.
- Make array operators work in 2D arrays.
- Add tests for 2D arrays.
- Add `all_close_wp` function. <https://stdlib.fortran-lang.org/page/specs/stdlib_math.html#all_close-function>
- Add exponentiation operator.
- Dimensional homogeneity enforced for length, mass, and time.
- First-order uncertainty propagation for uncorrelated variables.
- Regression testing

Later:

- Linear regression considering uncertainties for uncorrelated variables.
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

- The way `error_print` writes to stderr is conventional but not standard and may not be fully portable. [A standard way to write to stderr was not available until Fortran 2003](https://stackoverflow.com/a/8508757/1124489), but the Oracle Fortran compiler does not implement this part of the standard. The value of `error_unit` in `error_print` may need to change depending on the compiler. The following compilers do not appear to write to stderr based on the default value of `error_unit` (0) in `error_print`:
    - Microsoft Fortran PowerStation 4.0 (The documentation does not mention any way to write to stderr, so this compiler may not be able to.)
