! nonstdlib.f90 - Fortran 95 implementations of Fortran stdlib
! ============================================================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-09-28
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

module nonstdlib
    ! Summary
    ! -------
    ! 
    ! These are independent implementations of some procedures from
    ! the [Fortran stdlib](https://github.com/fortran-lang/stdlib)
    ! to avoid external dependencies (to improve longevity) and work
    ! in Fortran 2003 (as the Fortran stdlib requires Fortran 2008
    ! at a mininum).
    ! 
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare parameters
    ! 3. Declare procedures
    
    implicit none
    private
    public error_unit
    public check
    public error_stop
    
    ! Not fully portable as a portable approach requires Fortran 2003.
    ! <https://stackoverflow.com/a/8508757/1124489>
    ! But the Oracle compiler doesn't have this as of 2022-10-01! So
    ! I'm using the non-portable approach.
    integer, parameter :: error_unit = 0
contains
    subroutine check(condition, msg) !
        ! Implementation of an assertion subroutine.
        ! <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>
        ! TODO: Add (optional) file and line numbers to this.
        ! TODO: Allow the message to vary.
        logical, intent(in) :: condition
        character(len=*), intent(in), optional :: msg
        
        if (.not. condition) then
            if (present(msg)) then
                call error_stop(msg)
            else
                call error_stop("Check failed.")
            end if
        end if
    end subroutine check
    
    subroutine error_stop(msg) !
        ! Stops execution and prints error message.
        character(len=*), intent(in) :: msg
        
        write(error_unit, *) msg
        stop 1
    end subroutine error_stop
end module nonstdlib
