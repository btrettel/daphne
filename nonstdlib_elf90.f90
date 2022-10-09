! nonstdlib.f90 - Fortran 90 implementations of Fortran stdlib
! ============================================================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-10-05
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

module nonstdlib
    ! Summary
    ! -------
    ! 
    ! These are independent implementations of some procedures from
    ! the [Fortran stdlib](https://github.com/fortran-lang/stdlib)
    ! to avoid external dependencies (to improve longevity) and work
    ! in Fortran 90 (as the Fortran stdlib requires Fortran 2008 at a
    ! mininum).
    ! 
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare parameters
    ! 3. Declare procedures
    
    implicit none
    private
    public :: check
    public :: error_stop
    
    ! Not fully portable as a portable approach requires Fortran 2003.
    ! <https://stackoverflow.com/a/8508757/1124489>
    ! But the Oracle compiler doesn't have this as of 2022-10-01! So
    ! I'm using the non-portable approach.
    integer, public, parameter :: error_unit = 0
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
        return
    end subroutine check
    
    subroutine error_stop(msg) !
        ! Stops execution and prints error message.
        character(len=*), intent(in) :: msg
        integer :: i
        
        open(unit=error_unit, file="error.log", &
                status="replace", iostat=i, position="append")
        if (i /= 0) then
            write(unit=*, fmt=*) "Can't open error log."
            stop
        end if
        write(unit=*, fmt=*) msg
        write(unit=error_unit, fmt=*) msg
        close(error_unit)
        stop
    end subroutine error_stop
end module nonstdlib
