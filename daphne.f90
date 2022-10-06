! daphne.f90 - module for uncertain dimensioned variables
! =======================================================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-10-05
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

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
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare parameters
    ! 3. Declare variables
    ! 4. Initialize variables
    ! 5. Declare operators
    ! 6. Testing procedures
    ! 7. Convenience procedures
    ! 8. Constructors
    ! 9. Operator functions
    ! 9a. preal scalars
    ! 9b. preal arrays
    
    ! 1. Set modules and other boilerplate
    ! ------------------------------------
    
    use nonstdlib
    implicit none
    private
    public wp
    public preal
    public is_close_wp
    public logical_test
    public real_comparison_test
    public tests_end
    public N
    public operator(+)
    public operator(-)
    public operator(*)
    public operator(/)
    
    ! 2. Declare parameters
    ! ---------------------
    
    ! `wp` stands for "working precision" in case I want to change
    ! the precision later. This is double precision for now.
    ! Quad precision: selected_real_kind(33, 4931)
    integer, parameter :: wp = selected_real_kind(15, 307)
    
    ! Kind number for integer used to count preals.
    !integer, parameter :: intk = selected_int_kind(4)
    
    ! 3. Declare variables
    ! --------------------
    
    ! number of preals, used as the dimension of the covariance matrix
    !integer(kind=intk) :: number_of_preals = 0
    
    ! covariance matrix
    ! real(kind=wp), allocatable, dimension(:,:) :: covariance
    
    ! 4. Declare preal type
    ! ---------------------
    
    type preal
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
    
    ! 5. Declare operators
    ! --------------------
    
    ! TODO: Declare assignment operator to check if bounds of preal
    ! to be assigned to are different than the bounds of the preal
    ! being assigned from. Pick the more restrictive bounds.
    
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
    ! 6. Testing procedures
    ! ---------------------
    
    subroutine validate_preal(preal_in) !
        ! Check that a preal is plausible.
        
        type(preal), intent(in) :: preal_in
        
!        call check(preal_in%preal_id > 0_intk, &
!            "preal_id not greater than zero.")
        
!        call check(preal_in%preal_id <= number_of_preals, &
!            "preal_id not less than or equal to the number of preals.")
        
        call check(preal_in%stdev > 0._wp, &
            "Standard deviation not greater than zero.")
        
!        if (preal_in%lower_bound_set) then
!            call check(preal_in%mean >= preal_in%lower_bound, &
!                "Mean not greater than lower bound.")
!        end if
        
!        if (preal_in%upper_bound_set) then
!            call check(preal_in%mean <= preal_in%upper_bound, &
!                "Mean not less than upper bound.")
!        end if
    end subroutine validate_preal
    
    subroutine validate_preal_array(preal_array_in) !
        ! Check that a preal array is plausible.
        
        type(preal), dimension(:), intent(in) :: preal_array_in
        integer :: i
        
        do i = lbound(preal_array_in, dim=1), &
                ubound(preal_array_in, dim=1)
            call validate_preal(preal_array_in(i))
        end do
    end subroutine validate_preal_array
    
    function is_close_wp(input_real_1, input_real_2, eps) !
        ! Determine whether two reals are close.
        
        real(kind=wp), intent(in) :: input_real_1, input_real_2
        real(kind=wp), intent(in), optional :: eps
        real(kind=wp) :: eps_set
        integer :: prec
        logical :: is_close_wp
        
        prec = precision(input_real_1)
        
        if (present(eps)) then
            eps_set = eps
        else
            ! The first determines a *relative* range. The second
            ! takes the largest of the relative range and an absolute
            ! range, in case input_real_1 is small.
            eps_set = abs(input_real_1 * &
                        10._wp**(-(real(prec, kind=wp) - 2._wp)))
            eps_set = max(eps_set, &
                        10._wp**(-(real(prec, kind=wp) - 2._wp)))
        end if
        
        call check(eps_set > 0._wp)
        
        if (abs(input_real_1 - input_real_2) < eps_set) then
            is_close_wp = .true.
        else
            is_close_wp = .false.
        end if
    end function is_close_wp
    
    subroutine logical_test(condition, msg, number_of_failures) !
        ! Check whether test condition is true, increase
        ! number_of_failures if false.
        
        logical, intent(in) :: condition
        character(len=*), intent(in) :: msg
        integer, intent(inout) :: number_of_failures
        
        if (condition) then
            print *, "pass: "//msg
        else
            write(error_unit, *) "fail: "//msg
            number_of_failures = number_of_failures + 1
        end if
        print *
    end subroutine logical_test
    
    subroutine real_comparison_test(program_real, expected_real, &
                msg, number_of_failures) !
        ! Check whether two reals are close, increase
        ! number_of_failures if false.
        
        real(kind=wp), intent(in) :: program_real, expected_real
        character(len=*), intent(in) :: msg
        integer, intent(inout) :: number_of_failures
        
        print *, "returned: ", program_real
        print *, "expected: ", expected_real
        call logical_test(is_close_wp(program_real, expected_real), &
            msg, &
            number_of_failures)
    end subroutine real_comparison_test
    
    subroutine tests_end(number_of_failures) !
        integer, intent(in) :: number_of_failures
        
        if (number_of_failures > 0) then
            print *, number_of_failures, "test(s) failed."
            call error_stop("Exiting with error.")
        else
            print *, "All tests passed."
        end if
    end subroutine tests_end
    
    ! 7. Convenience procedures
    ! -------------------------
    
    
    
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
    end function padd
    
    function psubtract(preal_1, preal_2) result(preal_out) !
        ! Subtracts two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean - preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
    end function psubtract
    
    function pmultiply(preal_1, preal_2) result(preal_out) !
        ! Multiplies two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean * preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
    end function pmultiply
    
    function pdivide(preal_1, preal_2) result(preal_out) !
        ! Divides two preal scalars.
        
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_out
        
        preal_out%mean = preal_1%mean / preal_2%mean
        preal_out%stdev = max(preal_1%stdev, preal_2%stdev) ! TODO
        
        call validate_preal(preal_out)
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
                    lbound(preal_array_2, dim=1))
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1))
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) + preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
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
                    lbound(preal_array_2, dim=1))
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1))
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) - preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
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
                    lbound(preal_array_2, dim=1))
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1))
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) * preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
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
                    lbound(preal_array_2, dim=1))
        call check(ubound(preal_array_1, dim=1) == &
                    ubound(preal_array_2, dim=1))
        
        ! Allocate the output array.
        
        lower_index = lbound(preal_array_1, dim=1)
        upper_index = ubound(preal_array_1, dim=1)
        
        do i = lower_index, upper_index
            preal_array_out(i) = preal_array_1(i) / preal_array_2(i)
        end do
        
        call validate_preal_array(preal_array_out)
    end function pdivide_array
end module daphne
