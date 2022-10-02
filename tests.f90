! tests.f90 - tests for Daphne
! ============================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-09-28
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

program tests
    ! Summary
    ! -------
    ! 
    ! Tests for all operators and procedures in Daphne.
    ! 
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare variables
    ! 3. Initialize variables
    ! 4. Tests
    ! 4a. Testing procedures
    ! 4b. Constructors
    ! 4c. Operators
    ! 5. Final result
    
    ! 1. Set modules and other boilerplate
    ! ------------------------------------
    
    use daphne
    use nonstdlib
    implicit none
    
    ! 2. Declare variables
    ! --------------------
    
    type(preal) :: x, y, z
    type(preal), dimension(3) :: array_1, array_2
    integer :: number_of_failures
    
    ! 3. Initialize variables
    ! -----------------------
    
    number_of_failures = 0
    
    ! 4. Tests
    ! --------
    
    ! 4a. Testing procedures
    
    ! TODO: validate_preal
    ! TODO: validate_preal_array
    
    call logical_test(is_close_wp(1._wp, 1._wp), &
        "is_close_wp, identical numbers", &
        number_of_failures)
    
    call logical_test(.not. is_close_wp(1._wp, 10._wp), &
        "is_close_wp, different numbers", &
        number_of_failures)
    
    call logical_test(is_close_wp(1._wp, 1.05_wp, eps=0.1_wp), &
        "is_close_wp, close numbers with set eps, inside eps", &
        number_of_failures)
    
    call logical_test(.not. is_close_wp(1._wp, 1.15_wp, eps=0.1_wp), &
        "is_close_wp, close numbers with set eps, outside eps", &
        number_of_failures)

    ! 4b. Constructor
    ! ---------------
    
    x = N(1._wp / 7._wp, 2._wp / 7._wp)
    
    call real_comparison_test(x%mean, 1._wp / 7._wp, &
        "preal scalar constructor, whether mean is set properly", &
        number_of_failures)
    
    call real_comparison_test(x%stdev, 2._wp / 7._wp, &
        "preal scalar constructor, whether stdev is set properly", &
        number_of_failures)
    
    ! TODO: Constructor setting right dimensions
    ! TODO: Constructor setting right lower bound
    ! TODO: Constructor setting right upper bound
    ! TODO: Constructor incrementing number_of_preals
    ! TODO: Constructor setting right preal_id
    
    array_1(1) = N(1._wp, 0.1_wp)
    array_1(2) = N(2._wp, 0.1_wp)
    array_1(3) = N(3._wp, 0.1_wp)
    
    ! 4c. Operators
    ! -------------
    
    y = N(6._wp / 7._wp, 1._wp / 7._wp)
    
    ! Addition
    
    z = x + y
    call real_comparison_test(z%mean, 1._wp, &
        "preal scalar addition, mean check", &
        number_of_failures)
    
    ! subtraction
    
    z = x - y
    call real_comparison_test(z%mean, -5._wp / 7._wp, &
        "preal scalar subtraction, mean check", &
        number_of_failures)
    
    array_2(1) = N(1._wp, 0.1_wp)
    array_2(2) = N(1._wp, 0.1_wp)
    array_2(3) = N(1._wp, 0.1_wp)
    
    array_2(:) = array_1(:) + array_2(:)
    
    ! TODO: Addition for arrays
    ! TODO: Subtraction for arrays
    ! TODO: Multiplication for scalars and arrays
    ! TODO: Division for scalars and arrays
    ! TODO: checking number_of_preals and preal_id for each operator
    
    ! 5. Final result
    ! ---------------
    
    call tests_end(number_of_failures)
end program tests
