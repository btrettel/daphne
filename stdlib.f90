module stdlib
    implicit none
    public stderr_unit
    
    ! Not fully portable as a portable approach requires Fortran 2003.
    ! <https://stackoverflow.com/a/8508757/1124489>
    integer, parameter :: stderr_unit = 0
contains
    subroutine check(condition)
        ! <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>
        ! TODO: Add (optional) file and line numbers to this.
        ! TODO: Allow the message to vary.
        logical, intent(in) :: condition
        
        if (.not. condition) then
            write(stderr_unit,*) "Assertion failed."
            stop 1
        end if
    end subroutine check
end module stdlib
