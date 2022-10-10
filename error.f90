! error.f90 - error-checking procedures
! =====================================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-10-10
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

module error
    ! Summary
    ! -------
    ! 
    ! Here are some error-checking related procedures, partly inspired
    ! by the [Fortran stdlib](https://github.com/fortran-lang/stdlib).
    ! I am not using the Fortran stdlib to avoid external
    ! dependencies (to improve longevity) and work in Fortran 90 (as
    ! the Fortran stdlib requires Fortran 2008 at a minimum).
    ! 
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare public procedures and operators
    ! 3. Declare procedures
    
    implicit none
    private
    
    ! 2. Declare public procedures and operators
    ! ------------------------------------------
    
    public :: check
    public :: error_stop
    public :: error_print
contains
    ! 3. Declare procedures
    ! ---------------------
    
    subroutine check(condition, msg) !
        ! Implementation of an assertion subroutine. Unlike in the
        ! stdlib, the message is required here.
        ! <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>
        ! TODO: Add (optional) file and line numbers to this.
        logical, intent(in) :: condition
        character(len=*), intent(in) :: msg
        
        if (.not. condition) then
            call error_stop(msg)
            
!            if (present(msg)) then
!                call error_stop(msg)
!            else
!                call error_stop("Check failed.")
!            end if
        end if
        return
    end subroutine check
    
    subroutine error_stop(msg) !
        ! Stops execution and prints error message.
        character(len=*), intent(in) :: msg
        
        call error_print(msg)
        stop 1
    end subroutine error_stop
    
    subroutine error_print(msg) !
        ! Prints error message.
        character(len=*), intent(in) :: msg
        ! Not fully portable as a portable approach requires Fortran
        ! 2003. <https://stackoverflow.com/a/8508757/1124489>
        ! But the Oracle compiler doesn't have this as of
        ! 2022-10-01! So I'm using the non-portable approach.
        integer, parameter :: error_unit = 0
        
        write(unit=error_unit, fmt=*) msg
        return
    end subroutine error_print
end module error
