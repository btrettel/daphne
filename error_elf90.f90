! error_elf90.f90 - error-checking procedures for ELF90
! =====================================================
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
    ! This version works in the ELF90 compiler. The ELF90 compiler
    ! can only write to stdout or a file, and can only have an exit
    ! code of zero. Since I normally want to write error messages to
    ! stderr and have non-zero exit codes in the case of issues, I'm
    ! maintaining a parallel version of the check procedures for
    ! ELF90.
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
        stop
    end subroutine error_stop
    
    subroutine error_print(msg) !
        ! Prints error message.
        character(len=*), intent(in) :: msg
        integer, parameter :: error_unit = 0
        integer :: i
        
        ! ELF90 will compile if `write(unit=error_unit, fmt=*) msg`
        ! is used by itself, but the following error will appear at
        ! runtime:
        ! > No file connected to unit (see "Input/Output" in the
        ! > Essential Lahey Fortran 90 Reference).
        ! So as far as I can tell, ELF90 can only write to stdout. So
        ! I write error messages to stdout and an error log file.
        ! Since ELF90 can't have non-zero exit codes, the error log
        ! is how I tell whether the tests succeeded or failed.
        
        open(unit=error_unit, file="error.log", &
                status="replace", iostat=i, position="append")
        if (i /= 0) then
            write(unit=*, fmt=*) "Can't open error log."
            stop
        end if
        write(unit=*, fmt=*) msg
        write(unit=error_unit, fmt=*) msg
        close(error_unit)
        return
    end subroutine error_print
end module error
