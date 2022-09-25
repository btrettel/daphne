! nonstdlib.f90
! =============
! 
! These are independent implementations of some procedures from the
! [Fortran Standand Library](https://github.com/fortran-lang/stdlib)
! to avoid external dependencies (to improve longevity) and work in
! Fortran 95 (as the Fortran Standard Library requires Fortran 2008 at
! a mininum).
! 
module nonstdlib
    implicit none
    private
    public error_unit
    public check
    
    ! Not fully portable as a portable approach requires Fortran 2003.
    ! <https://stackoverflow.com/a/8508757/1124489>
    integer, parameter :: error_unit = 0
contains
    subroutine check(condition) !
        ! Implementation of an assertion subroutine.
        ! <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>
        ! TODO: Add (optional) file and line numbers to this.
        ! TODO: Allow the message to vary.
        logical, intent(in) :: condition
        
        if (.not. condition) then
            write(error_unit, *) "Assertion failed."
            stop 1
        end if
    end subroutine check
end module nonstdlib
