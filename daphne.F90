! daphne.F90 - module for uncertain dimensioned variables
! =======================================================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-10-05
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

#ifndef __PURE__
#define __PURE__
#define __NOTPURE__
#endif

module daphne
    ! Summary
    ! -------
    ! 
    ! Daphne is a Fortran library for rigorous data analysis in the
    ! physical sciences. Dimensional analysis will prevent many
    ! potential bugs, and uncertainty propagation will reveal the
    ! limits of what can be understood from the data. Daphne
    ! prioritizes correctness over speed, so this library is not
    ! intended for HPC.
    ! 
    ! To use Daphne, create a variable of type `preal`:
    ! 
    !     type(preal) :: x
    ! 
    ! Then initialize the variable with dimensions and
    ! uncertainties. For example, to initialize a normally
    ! distributed variable:
    ! 
    !     x = N(1.5_wp, 0.1_wp)
    ! 
    ! A preprocessor is required for daphne.F90.
    ! 
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare public procedures and operators
    ! 3. Declare parameters
    ! 4. Declare variables
    ! 5. Initialize variables
    ! 6. Declare operators
    ! 7. Testing procedures
    ! 8. Constructors
    ! 9. Operator functions
    ! 9a. preal scalars
    ! 9b. preal arrays
    
    ! 1. Set modules and other boilerplate
    ! ------------------------------------
    
    implicit none
    private
    
    ! 2. Declare public procedures and operators
    ! ------------------------------------------
    
    public :: check
    public :: error_stop
    public :: error_print
    public :: is_close_wp
    public :: logical_test
    public :: real_comparison_test
    public :: tests_end
    public :: N
    private :: validate_preal
    private :: validate_preal_array
    private :: padd
    private :: psubtract
    private :: pmultiply
    private :: pdivide
    private :: padd_array
    private :: psubtract_array
    private :: pmultiply_array
    private :: pdivide_array
    public :: operator(+)
    public :: operator(-)
    public :: operator(*)
    public :: operator(/)
    
    ! 3. Declare parameters
    ! ---------------------
    
    ! `wp` stands for "working precision" in case I want to change
    ! the precision later.
#ifndef __DP__
    integer, public, parameter :: wp = selected_real_kind(33, 4931)
#else
    integer, public, parameter :: wp = selected_real_kind(15, 307)
#endif
    
    ! Kind number for integer used to count preals.
    !integer, parameter :: intk = selected_int_kind(4)
    
    ! 4. Declare variables
    ! --------------------
    
    ! number of preals, used as the dimension of the covariance matrix
    !integer(kind=intk) :: number_of_preals = 0
    
    ! covariance matrix
    ! real(kind=wp), allocatable, dimension(:,:) :: covariance
    
    ! 5. Declare preal type
    ! ---------------------
    
    type, public :: preal
        ! The preal_id is the index of this variable in the covariance
        ! matrix.
        !integer(kind=intk) :: preal_id
        
        real(kind=wp) :: mean
        real(kind=wp) :: stdev
        
        ! Why have logical variables for whether the `lower_bound`
        ! and `upper_bound` are set if `lower_bound` is set to
        ! `-huge(1._wp)` when `lower_bound_set == .false.` and
        ! `upper_bound` is set to `huge(1._wp)` when
        ! `upper_bound_set == .false.`? That is, if the bound
        ! variables are set to the limits of the real type anyway,
        ! why not simply check against those bounds anyway? The
        ! bounds aren't simply checked against; they are
        ! *propagated*. For example, if `x%lower_bound = -1._wp`, and
        ! `y = 2._wp * x`, then `y%lower_bound = -2._wp`. The interval
        ! arithmetic should be disabled when it is not needed.
!        logical :: lower_bound_set
!        real(kind=wp) :: lower_bound
!        logical :: upper_bound_set
!        real(kind=wp) :: upper_bound
    end type preal
    
    ! 6. Declare operators
    ! --------------------
    
    ! TODO: Declare assignment operator to check if bounds of preal
    ! to be assigned to are different than the bounds of the preal
    ! being assigned from. In other words, if the bounds of the
    ! preal on the left-hand-side are different from the bounds of
    ! preal on the right-hand-side. Pick the more restrictive bounds.
    
    interface operator (+) !
        ! Overload the + operator so that it works for preals.
        module procedure padd, padd_array
    end interface
    
    interface operator (-) !
        ! Overload the - operator so that it works for preals.
        module procedure psubtract, psubtract_array
    end interface
    
    interface operator (*) !
        ! Overload the * operator so that it works for preals.
        module procedure pmultiply, pmultiply_array
    end interface
    
    interface operator (/) !
        ! Overload the / operator so that it works for preals.
        module procedure pdivide, pdivide_array
    end interface
contains
    ! 7. Testing procedures
    ! ---------------------
    
    __PURE__ subroutine check(condition, msg) !
        ! Implementation of an assertion subroutine. Unlike in the
        ! stdlib, the message is required here.
        ! <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>
        ! TODO: Add (optional) file and line numbers to this.
        logical, intent(in) :: condition
        character(len=*), intent(in) :: msg
        
#ifdef __NOTPURE__
        if (.not. condition) then
            call error_stop(msg)
            
!            if (present(msg)) then
!                call error_stop(msg)
!            else
!                call error_stop("Check failed.")
!            end if
        end if
#endif
        return
    end subroutine check
    
    __PURE__ subroutine error_stop(msg) !
        ! Stops execution and prints error message.
        character(len=*), intent(in) :: msg
        
#ifdef __NOTPURE__
        call error_print(msg)
#ifndef __ELF90__
        stop 1
#else
        stop
#endif
#endif
    end subroutine error_stop
    
    __PURE__ subroutine error_print(msg) !
        ! Prints error message.
        character(len=*), intent(in) :: msg
#ifdef __NOTPURE__
        ! Not fully portable as a portable approach requires Fortran
        ! 2003. <https://stackoverflow.com/a/8508757/1124489>
        ! But the Oracle compiler doesn't have this as of
        ! 2022-10-01! So I'm using the non-portable approach.
        integer, parameter :: error_unit = 0
        
#ifndef __ELF90__
        write(unit=error_unit, fmt=*) msg
#else
        ! ELF90 will compile if `write(unit=error_unit, fmt=*) msg`
        ! is used by itself, but the following error will appear at
        ! runtime:
        ! > No file connected to unit (see "Input/Output" in the
        ! > Essential Lahey Fortran 90 Reference).
        ! So as far as I can tell, ELF90 can only write to stdout. So
        ! I write error messages to stdout and an error log file.
        ! Since ELF90 can't have non-zero exit codes, the error log
        ! is how I tell whether the tests succeeded or failed.
        
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
#endif
#endif
        return
    end subroutine error_print
    
    __PURE__ subroutine validate_preal(preal_in) !
        ! Check that a preal is plausible.
        
        type(preal), intent(in) :: preal_in
        
#ifdef __NOTPURE__
!        call check(preal_in%preal_id > 0_intk, &
!            msg="preal_id not greater than zero.")
        
!        call check(preal_in%preal_id <= number_of_preals, &
!            msg="preal_id not less than or equal to the number of preals.")
        
        call check(preal_in%stdev > 0.0_wp, &
            msg="Standard deviation not greater than zero.")
        
!        if (preal_in%lower_bound_set) then
!            call check(preal_in%mean >= preal_in%lower_bound, &
!                msg="Mean not greater than lower bound.")
!        end if
        
!        if (preal_in%upper_bound_set) then
!            call check(preal_in%mean <= preal_in%upper_bound, &
!                msg="Mean not less than upper bound.")
!        end if
#endif
        return
    end subroutine validate_preal
    
    __PURE__ subroutine validate_preal_array(preal_array_in) !
        ! Check that a preal array is plausible.
        
        type(preal), dimension(:), intent(in) :: preal_array_in
#ifdef __NOTPURE__
        integer :: i
        
        do i = lbound(preal_array_in, dim=1), &
                ubound(preal_array_in, dim=1)
            call validate_preal(preal_array_in(i))
        end do
#endif
        return
    end subroutine validate_preal_array
    
    function is_close_wp(input_real_1, input_real_2, rel_tol, abs_tol) !
        ! Determine whether two reals are close.
        
        real(kind=wp), intent(in) :: input_real_1, input_real_2
        real(kind=wp), intent(in), optional :: rel_tol, abs_tol
        real(kind=wp) :: rel_tol_set, abs_tol_set, tol
        integer :: prec
        logical :: is_close_wp
        
        prec = precision(input_real_1)
        
        if (present(rel_tol)) then
            call check(rel_tol >= 0.0_wp, &
                msg="Set relative tolerance not zero or more.")
            rel_tol_set = rel_tol
        else
            rel_tol_set = 10.0_wp**(-(real(prec, kind=wp) - 2.0_wp))
        end if
        
        if (present(abs_tol)) then
            call check(abs_tol >= 0.0_wp, &
                msg="Set absolute tolerance not zero or more.")
            abs_tol_set = abs_tol
        else
            abs_tol_set = 10.0_wp**(-(real(prec, kind=wp) - 2.0_wp))
        end if
        
        tol = max(rel_tol_set * abs(input_real_1), &
                rel_tol_set * abs(input_real_2), &
                abs_tol_set)
        
        call check(tol > 0.0_wp, &
                    msg="Tolerance not greater than zero.")
        
        if (abs(input_real_1 - input_real_2) < tol) then
            is_close_wp = .true.
        else
            is_close_wp = .false.
        end if
        return
    end function is_close_wp
    
    subroutine logical_test(condition, msg, number_of_failures) !
        ! Check whether test condition is true, increase
        ! number_of_failures if false.
        
        logical, intent(in) :: condition
        character(len=*), intent(in) :: msg
        integer, intent(in out) :: number_of_failures
        
        if (condition) then
            write(unit=*, fmt=*) "pass: "//msg
        else
            call error_print("fail: "//msg)
            number_of_failures = number_of_failures + 1
        end if
        return
    end subroutine logical_test
    
    subroutine real_comparison_test(program_real, expected_real, &
                msg, number_of_failures) !
        ! Check whether two reals are close, increase
        ! number_of_failures if false.
        
        real(kind=wp), intent(in) :: program_real, expected_real
        character(len=*), intent(in) :: msg
        integer, intent(in out) :: number_of_failures
        
        write(unit=*, fmt=*) "  returned:", program_real
        write(unit=*, fmt=*) "  expected:", expected_real
        write(unit=*, fmt=*) "difference:", &
                        abs(program_real - expected_real)
        call logical_test(is_close_wp(program_real, expected_real), &
            msg, &
            number_of_failures)
        return
    end subroutine real_comparison_test
    
    subroutine tests_end(number_of_failures) !
        integer, intent(in) :: number_of_failures
        
        if (number_of_failures > 0) then
            ! TODO: After adding a function to convert integers to
            ! strings, change the next line to use error_print.
            write(unit=*, fmt=*) number_of_failures, "test(s) failed."
            call error_stop("Exiting with error.")
        else
            write(unit=*, fmt=*) "All tests passed."
        end if
        return
    end subroutine tests_end
    
    ! 8. Constructors
    ! ---------------
    
    function N(mean, stdev) result(preal_out) !
        ! Returns a normally distributed preal.
        
        real(kind=wp), intent(in) :: mean, stdev
!        real(kind=wp), intent(in), optional :: lower_bound
        type(preal) :: preal_out
        
        !number_of_preals   = number_of_preals + 1_intk
        !preal_out%preal_id = number_of_preals
        preal_out%mean     = mean
        preal_out%stdev    = stdev
        
!        if (present(lower_bound)) then
!            preal_out%lower_bound_set = .true.
!            preal_out%lower_bound = lower_bound
!        else
!            preal_out%lower_bound_set = .false.
!            !preal_out%lower_bound = -huge(1._wp)
!        end if
        
        call validate_preal(preal_out)
        return
    end function N
    
    ! 9. Operator functions
    ! ---------------------
    
    ! 9a. preal scalars
    ! -----------------
    
    function padd(preal_1, preal_2) result(preal_out) !
        ! Adds two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean + preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
        return
    end function padd
    
    function psubtract(preal_1, preal_2) result(preal_out) !
        ! Subtracts two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean - preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
        return
    end function psubtract
    
    function pmultiply(preal_1, preal_2) result(preal_out) !
        ! Multiplies two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean * preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
        return
    end function pmultiply
    
    function pdivide(preal_1, preal_2) result(preal_out) !
        ! Divides two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean / preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
        return
    end function pdivide
    
    ! 9b. preal arrays
    ! ----------------
    
    function padd_array(preal_array_1, preal_array_2) &
            result(preal_array_out) !
        ! Adds two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer :: i, lower_index, upper_index
        
        ! Check that preal_array_1 and preal_array_1 have the same
        ! dimensions.
        call check(lbound(preal_array_1, dim=1) == &
                    lbound(preal_array_2, dim=1), &
                    msg="padd_array: lower array bound mismatch")
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1), &
                    msg="padd_array: upper array bound mismatch")
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) + preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
        return
    end function padd_array
    
    function psubtract_array(preal_array_1, preal_array_2) &
            result(preal_array_out) !
        ! Subtracts two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer :: i, lower_index, upper_index
        
        ! Check that preal_array_1 and preal_array_1 have the same
        ! dimensions.
        call check(lbound(preal_array_1, dim=1) == &
                    lbound(preal_array_2, dim=1), &
                    msg="psubtract_array: lower array bound mismatch")
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1), &
                    msg="psubtract_array: upper array bound mismatch")
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) - preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
        return
    end function psubtract_array
    
    function pmultiply_array(preal_array_1, preal_array_2) &
            result(preal_array_out) !
        ! Multiplies two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer :: i, lower_index, upper_index
        
        ! Check that preal_array_1 and preal_array_1 have the same
        ! dimensions.
        call check(lbound(preal_array_1, dim=1) == &
                    lbound(preal_array_2, dim=1), &
                    msg="pmultiply_array: lower array bound mismatch")
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1), &
                    msg="pmultiply_array: upper array bound mismatch")
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) * preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
        return
    end function pmultiply_array
    
    function pdivide_array(preal_array_1, preal_array_2) &
            result(preal_array_out) !
        ! Divides two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer :: i, lower_index, upper_index
        
        ! Check that preal_array_1 and preal_array_1 have the same
        ! dimensions.
        call check(lbound(preal_array_1, dim=1) == &
                    lbound(preal_array_2, dim=1), &
                    msg="pdivide_array: lower array bound mismatch")
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1), &
                    msg="pdivide_array: upper array bound mismatch")
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) / preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
        return
    end function pdivide_array
end module daphne
