module stdlib
    implicit none
contains
    subroutine check(condition)
        ! <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>
        ! TODO: Add (optional) file and line numbers to this.
        ! TODO: Allow the message to vary.
        logical, intent(in) :: condition
        
        if (.not. condition) then
            write(0,*) "Assertion failed."
            stop 1
        end if
    end subroutine check
end module stdlib
