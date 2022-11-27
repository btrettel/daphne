! # $File$
! 
! Summary: Library for rigorous data analysis in the physical sciences with uncertainty propagation and dimensional analysis.
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: $Date$
! Revision: $Revision$
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

#include "header.F90"

module daphne
    ! Usage
    ! -----
    ! 
    ! To use Daphne, create a variable of type `preal`:
    ! 
    !     type(preal) :: x
    ! 
    ! Then initialize the variable with dimensions and uncertainties. For example, to initialize a normally distributed variable:
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
    ! 6. Declare interfaces
    ! 7. Testing procedures
    ! 8. Constructors
    ! 9. Operator functions
    ! 9a. preal scalars
    ! 9b. preal arrays
    
    ! 1. Set modules and other boilerplate
    ! ------------------------------------
    
#ifndef __FTN95__
    use, intrinsic :: iso_fortran_env, only: error_unit
#endif
    implicit none
    private
    
    ! 2. Declare public procedures and operators
    ! ------------------------------------------
    
    public :: assert
    public :: assert_flag
    public :: check_flag
    public :: error_stop
    public :: error_print
    public :: is_close_wp
    public :: logical_test
    public :: real_equality_test
    public :: real_inequality_test
    public :: tests_end
    public :: N
    public :: operator(+)
    public :: operator(-)
    public :: operator(*)
    public :: operator(/)
    
    ! 3. Declare parameters
    ! ---------------------
    
    ! `wp` stands for "working precision" in case I want to change the precision later.
#ifndef __DP__
    integer, public, parameter :: wp = selected_real_kind(33, 4931)
#else
    integer, public, parameter :: wp = selected_real_kind(15, 307)
#endif
    
    ! Kind number for integers.
    integer, public, parameter :: i5 = selected_int_kind(5)
    
#ifdef __FTN95__
    integer, public, parameter :: error_unit = 0
#endif
    
    ! 4. Declare variables
    ! --------------------
    
    ! number of preals, used as the dimension of the covariance matrix
    !integer(kind=i5) :: number_of_preals = 0
    
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
        logical       :: flag
        
        ! Why have logical variables for whether the `lower_bound` and `upper_bound` are set if `lower_bound` is set to
        ! `-huge(1._wp)` when `lower_bound_set == .false.` and `upper_bound` is set to `huge(1._wp)` when
        ! `upper_bound_set == .false.`? That is, if the bound variables are set to the limits of the real type anyway, why not
        ! simply check against those bounds anyway? The bounds aren't simply checked against; they are *propagated*. For example,
        ! if `x%lower_bound = -1._wp`, and `y = 2._wp * x`, then `y%lower_bound = -2._wp`. The interval arithmetic should be
        ! disabled when it is not needed.
!        logical :: lower_bound_set
!        real(kind=wp) :: lower_bound
!        logical :: upper_bound_set
!        real(kind=wp) :: upper_bound
    end type preal
    
    ! 6. Declare interfaces
    ! ---------------------
    
    ! TODO: Declare assignment operator to check if bounds of preal to be assigned to are different than the bounds of the preal
    ! being assigned from. In other words, if the bounds of the preal on the left-hand-side are different from the bounds of preal
    ! on the right-hand-side. Pick the more restrictive bounds.
    
    interface operator (+) !
        ! Overload the + operator so that it works for preals.
        module procedure padd_scalar, padd_array
    end interface
    
    interface operator (-) !
        ! Overload the - operator so that it works for preals.
        module procedure psubtract_scalar, psubtract_array
    end interface
    
    interface operator (*) !
        ! Overload the * operator so that it works for preals.
        module procedure pmultiply_scalar, pmultiply_array
    end interface
    
    interface operator (/) !
        ! Overload the / operator so that it works for preals.
        module procedure pdivide_scalar, pdivide_array
    end interface
    
    interface check_flag !
        ! Asserts that the flag for the preal scalar or array is not set.
        module procedure check_flag_scalar, check_flag_array
    end interface
contains
    ! 7. Testing procedures
    ! ---------------------
    
    subroutine assert(condition, message, filename, line_number) !
        ! An assertion subroutine. Roughly based on check from <https://stdlib.fortran-lang.org/page/specs/stdlib_error.html>.
        ! Unlike in stdlib, the message, filename, and line numbers are required.
        logical, intent(in)          :: condition
        character(len=*), intent(in) :: message
        character(len=*), intent(in) :: filename
        integer(kind=i5), intent(in) :: line_number
        character(len=5)             :: line_str
        
        if (.not. condition) then
            write(unit=line_str, fmt="(i5)") line_number
            call error_stop("("//filename//":"//trim(adjustl(line_str))//") ERROR: "//message)
        end if
    end subroutine assert
    
    subroutine assert_flag(condition, flag) !
        ! An assertion subroutine that sets flag to true if the condition is not met.
        logical, intent(in)     :: condition
        logical, intent(inout) :: flag
        
        if (.not. condition) then
            flag = .true.
        end if
    end subroutine assert_flag
    
    subroutine check_flag_scalar(preal_in, filename, line_number) !
        ! Asserts that the flag for the preal is not set.
        ! The flag being set means that an error occurred in a previous calculation.
        type(preal), intent(in)      :: preal_in
        character(len=*), intent(in) :: filename
        integer(kind=i5), intent(in) :: line_number
        
        call assert(.not. preal_in%flag, "preal error detected.", filename, line_number)
    end subroutine check_flag_scalar
    
    subroutine check_flag_array(preal_array_in, filename, line_number) !
        ! Asserts that the flag for the preal array is not set.
        ! The flag being set means that an error occurred in a previous calculation.
        type(preal), dimension(:), intent(in) :: preal_array_in
        character(len=*), intent(in)          :: filename
        integer(kind=i5), intent(in)          :: line_number
        integer(kind=i5)                      :: i
        
        do i = lbound(preal_array_in, dim=1), ubound(preal_array_in, dim=1)
            call assert(.not. preal_array_in(i)%flag, "preal error detected.", filename, line_number)
        end do
    end subroutine check_flag_array
    
    subroutine error_stop(msg) !
        ! Stops execution and prints error message.
        character(len=*), intent(in) :: msg
        
        call error_print(msg)
        stop 1
    end subroutine error_stop
    
    subroutine error_print(msg) !
        ! Prints error message.
        character(len=*), intent(in) :: msg
        
        write(unit=error_unit, fmt=*) msg
    end subroutine error_print
    
    subroutine validate_preal(preal_in) !
        ! Check that a preal is plausible.
        
        type(preal), intent(inout) :: preal_in
        
        ! preal_id must be greater than zero.
!        call assert_flag(preal_in%preal_id > 0_intk, preal_in%flag)
        
        ! preal_id must be less than or equal to the number of preals
!        call assert_flag(preal_in%preal_id <= number_of_preals, preal_in%flag)
        
        ! The standard deviation must be greater than zero.
        call assert_flag(preal_in%stdev > 0.0_wp, preal_in%flag)
        
        ! The mean must be greater than or equal to the lower bound.
!        if (preal_in%lower_bound_set) then
!            call assert_flag(preal_in%mean >= preal_in%lower_bound, preal_in%flag)
!        end if
        
        ! The mean must be less than or equal to the lower bound.
!        if (preal_in%upper_bound_set) then
!            call assert_flag(preal_in%mean <= preal_in%upper_bound, preal_in%flag)
!        end if
    end subroutine validate_preal
    
    subroutine validate_preal_array(preal_array_in) !
        ! Check that a preal array is plausible.
        
        type(preal), dimension(:), intent(inout) :: preal_array_in
        integer(kind=i5) :: i
        
        do i = lbound(preal_array_in, dim=1), ubound(preal_array_in, dim=1)
            call validate_preal(preal_array_in(i))
        end do
    end subroutine validate_preal_array
    
    subroutine operation_size_flag(preal_array_1, preal_array_2, preal_array_out) !
        ! Check that preal_array_1 and preal_array_2 have the same dimensions.
        type(preal), dimension(:), intent(in) :: preal_array_1, preal_array_2
        type(preal), dimension(:), intent(inout) :: preal_array_out
        
        call assert_flag(lbound(preal_array_1, dim=1) == lbound(preal_array_2, dim=1), &
                preal_array_out(lbound(preal_array_1, dim=1))%flag)
        call assert_flag(ubound(preal_array_1, dim=1) == ubound(preal_array_2, dim=1), &
                preal_array_out(lbound(preal_array_1, dim=1))%flag)
    end subroutine operation_size_flag
    
    function operation_input_flag(preal_1, preal_2) !
        ! If any input preal flag is `.true.`, set the output preal flag to `.true.`.
        ! Otherwise set the output preal flag to `.false.`.
        type(preal), intent(in) :: preal_1, preal_2
        logical :: operation_input_flag
        
        if (preal_1%flag .or. preal_2%flag) then
            operation_input_flag = .true.
        else
            operation_input_flag = .false.
        end if
    end function operation_input_flag
    
    function is_close_wp(input_real_1, input_real_2, rel_tol, abs_tol) !
        ! Determine whether two reals are close.
        
        real(kind=wp), intent(in) :: input_real_1, input_real_2
        real(kind=wp), intent(in), optional :: rel_tol, abs_tol
        real(kind=wp) :: rel_tol_set, abs_tol_set, tol
        logical :: is_close_wp
        
        if (present(rel_tol)) then
            call ASSERT(rel_tol >= 0.0_wp, "Set relative tolerance to zero or greater.")
            rel_tol_set = rel_tol
        else
            rel_tol_set = 10.0_wp * epsilon(1.0_wp)
            call ASSERT(rel_tol_set > 0.0_wp, "Default relative tolerance not greater than zero.")
            call ASSERT(rel_tol_set < 0.0001_wp, "Default relative tolerance not particularly small.")
        end if
        
        if (present(abs_tol)) then
            call ASSERT(abs_tol >= 0.0_wp, "Set absolute tolerance to zero or greater.")
            abs_tol_set = abs_tol
        else
            abs_tol_set = 10.0_wp * epsilon(1.0_wp)
        end if
        
        tol = max(rel_tol_set * abs(input_real_1), rel_tol_set * abs(input_real_2), abs_tol_set)
        
        call ASSERT(tol > 0.0_wp, "Tolerance not greater than zero.")
        
        if (abs(input_real_1 - input_real_2) < tol) then
            is_close_wp = .true.
        else
            is_close_wp = .false.
        end if
    end function is_close_wp
    
    subroutine logical_test(condition, msg, number_of_failures) !
        ! Check whether test condition is true, increase number_of_failures if false.
        
        logical, intent(in) :: condition
        character(len=*), intent(in) :: msg
        integer(kind=i5), intent(inout) :: number_of_failures
        
        if (condition) then
            write(unit=*, fmt=*) "pass: "//msg
        else
            call error_print("fail: "//msg)
            number_of_failures = number_of_failures + 1
        end if
    end subroutine logical_test
    
    subroutine real_equality_test(program_real, expected_real, msg, number_of_failures) !
        ! Check whether two reals are close, increase number_of_failures if false.
        
        real(kind=wp), intent(in) :: program_real, expected_real
        character(len=*), intent(in) :: msg
        integer(kind=i5), intent(inout) :: number_of_failures
        
        write(unit=*, fmt="(a, es15.8)") "  returned:", program_real
        write(unit=*, fmt="(a, es15.8)") "  expected:", expected_real
        write(unit=*, fmt="(a, es15.8)") "difference:", abs(program_real - expected_real)
        call logical_test(is_close_wp(program_real, expected_real), msg, number_of_failures)
    end subroutine real_equality_test
    
    subroutine real_inequality_test(program_real, expected_real, msg, number_of_failures) !
        ! Check whether two reals are close, increase number_of_failures if true.
        
        real(kind=wp), intent(in) :: program_real, expected_real
        character(len=*), intent(in) :: msg
        integer(kind=i5), intent(inout) :: number_of_failures
        
        write(unit=*, fmt="(a, es15.8)") "  returned:", program_real
        write(unit=*, fmt="(a, es15.8)") "  expected:", expected_real
        write(unit=*, fmt="(a, es15.8)") "difference:", abs(program_real - expected_real)
        call logical_test(.not. is_close_wp(program_real, expected_real), msg, number_of_failures)
    end subroutine real_inequality_test
    
    subroutine tests_end(number_of_failures) !
        integer(kind=i5), intent(in) :: number_of_failures
        
        if (number_of_failures > 0) then
            ! TODO: After adding a function to convert integers to strings, change the next line to use error_print.
            write(unit=*, fmt=*) number_of_failures, "test(s) failed."
            
            call error_stop("Exiting with error.")
        else
            write(unit=*, fmt=*) "All tests passed."
        end if
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
        preal_out%flag     = .false.
        
!        if (present(lower_bound)) then
!            preal_out%lower_bound_set = .true.
!            preal_out%lower_bound = lower_bound
!        else
!            preal_out%lower_bound_set = .false.
!            !preal_out%lower_bound = -huge(1._wp)
!        end if
        
        call validate_preal(preal_out)
    end function N
    
    ! 9. Operator functions
    ! ---------------------
    
    ! 9a. preal scalars
    ! -----------------
    
    function padd_scalar(preal_1, preal_2) result(preal_out) !
        ! Adds two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%flag = operation_input_flag(preal_1, preal_2)
        preal_out%mean = preal_1%mean + preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
    end function padd_scalar
    
    function psubtract_scalar(preal_1, preal_2) result(preal_out) !
        ! Subtracts two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%flag = operation_input_flag(preal_1, preal_2)
        preal_out%mean = preal_1%mean - preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
    end function psubtract_scalar
    
    function pmultiply_scalar(preal_1, preal_2) result(preal_out) !
        ! Multiplies two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%flag = operation_input_flag(preal_1, preal_2)
        preal_out%mean = preal_1%mean * preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
    end function pmultiply_scalar
    
    function pdivide_scalar(preal_1, preal_2) result(preal_out) !
        ! Divides two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%flag = operation_input_flag(preal_1, preal_2)
        preal_out%mean = preal_1%mean / preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
    end function pdivide_scalar
    
    ! 9b. preal arrays
    ! ----------------
    
    function padd_array(preal_array_1, preal_array_2) result(preal_array_out) !
        ! Adds two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer(kind=i5) :: i
        
        do i = lbound(preal_array_1, dim=1), ubound(preal_array_1, dim=1)
            preal_array_out(i) = preal_array_1(i) + preal_array_2(i)
        end do
        
        call operation_size_flag(preal_array_1, preal_array_2, preal_array_out)
        call validate_preal_array(preal_array_out)
    end function padd_array
    
    function psubtract_array(preal_array_1, preal_array_2) result(preal_array_out) !
        ! Subtracts two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer(kind=i5) :: i
        
        do i = lbound(preal_array_1, dim=1), ubound(preal_array_1, dim=1)
            preal_array_out(i) = preal_array_1(i) - preal_array_2(i)
        end do
        
        call operation_size_flag(preal_array_1, preal_array_2, preal_array_out)
        call validate_preal_array(preal_array_out)
    end function psubtract_array
    
    function pmultiply_array(preal_array_1, preal_array_2) result(preal_array_out) !
        ! Multiplies two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer(kind=i5) :: i
        
        do i = lbound(preal_array_1, dim=1), ubound(preal_array_1, dim=1)
            preal_array_out(i) = preal_array_1(i) * preal_array_2(i)
        end do
        
        call operation_size_flag(preal_array_1, preal_array_2, preal_array_out)
        call validate_preal_array(preal_array_out)
    end function pmultiply_array
    
    function pdivide_array(preal_array_1, preal_array_2) result(preal_array_out) !
        ! Divides two preal arrays.
        
        type(preal), dimension(:), intent(in) :: preal_array_1
        type(preal), dimension(:), intent(in) :: preal_array_2
        type(preal), dimension(size(preal_array_1)) :: preal_array_out
        integer(kind=i5) :: i
        
        do i = lbound(preal_array_1, dim=1), ubound(preal_array_1, dim=1)
            preal_array_out(i) = preal_array_1(i) / preal_array_2(i)
        end do
        
        call operation_size_flag(preal_array_1, preal_array_2, preal_array_out)
        call validate_preal_array(preal_array_out)
    end function pdivide_array
end module daphne
