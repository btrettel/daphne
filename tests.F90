! tests.f90 - tests for Daphne
! ============================
! 
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: 2022-10-02
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

#define CHECK(ARG1, ARG2) check(ARG1, ARG2, __FILE__, __LINE__)

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
    implicit none
    
    ! 2. Declare variables
    ! --------------------
    
    type(preal) :: x, y, z
    type(preal), dimension(3) :: array_1, array_2, array_3
    integer :: number_of_failures
    
    ! 3. Initialize variables
    ! -----------------------
    
    number_of_failures = 0
    
    ! 4. Tests
    ! --------
    
    ! 4a. Testing procedures
    
    ! TODO: validate_preal
    ! TODO: validate_preal_array
    ! TODO: Test Git revision number.
    
    ! Check that my assertion macro to insert filenames and line
    ! numbers works.
    call CHECK(.true., "This is true.")
    
    call logical_test(.true., &
        "logical test", &
        number_of_failures)
    
    call logical_test(__FILE__ == "tests.F90", &
        "preprocessor filename", &
        number_of_failures)
    
    call logical_test(__LINE__ > 0, &
        "preprocessor line number", &
        number_of_failures)
    
    call logical_test(is_close_wp(1.0_wp, 1.0_wp), &
        "is_close_wp, identical numbers", &
        number_of_failures)
    
    call logical_test(.not. is_close_wp(1.0_wp, 10.0_wp), &
        "is_close_wp, different numbers", &
        number_of_failures)
    
    call logical_test(is_close_wp(1.0_wp, 1.05_wp, &
        abs_tol=0.1_wp, rel_tol=0.0_wp), &
        "is_close_wp, close numbers with set abs_tol, "&
            //"inside abs_tol", &
        number_of_failures)
    
    call logical_test(.not. is_close_wp(1.0_wp, 1.15_wp, &
        abs_tol=0.1_wp, rel_tol=0.0_wp), &
        "is_close_wp, close numbers with set abs_tol, "&
            //"outside abs_tol", &
        number_of_failures)
    
    call logical_test(is_close_wp(1.0_wp, 1.05_wp, &
        abs_tol=0.0_wp, rel_tol=0.1_wp), &
        "is_close_wp, close numbers with set rel_tol, "&
            //"inside rel_tol", &
        number_of_failures)
    
    call logical_test(.not. is_close_wp(1.0_wp, 1.15_wp, &
        abs_tol=0.0_wp, rel_tol=0.1_wp), &
        "is_close_wp, close numbers with set rel_tol, "&
            //"outside rel_tol", &
        number_of_failures)

    ! 4b. Constructor
    ! ---------------
    
    x = N(1.0_wp / 7.0_wp, 2.0_wp / 7.0_wp)
    
    call real_comparison_test(x%mean, 1.0_wp / 7.0_wp, &
        "preal scalar constructor, whether mean is correct", &
        number_of_failures)
    
    call real_comparison_test(x%stdev, 2.0_wp / 7.0_wp, &
        "preal scalar constructor, whether stdev is correct", &
        number_of_failures)
    
    ! TODO: Constructor setting right dimensions
    ! TODO: Constructor setting right lower bound
    ! TODO: Constructor setting right upper bound
    ! TODO: Constructor incrementing number_of_preals
    ! TODO: Constructor setting right preal_id
    
    array_1(1) = N(1.0_wp, 0.3_wp)
    array_1(2) = N(2.0_wp, 0.2_wp)
    array_1(3) = N(3.0_wp, 0.1_wp)
    
    call real_comparison_test(array_1(1)%mean, 1.0_wp, &
        "preal array constructor, whether mean is correct (1)", &
        number_of_failures)
    call real_comparison_test(array_1(2)%mean, 2.0_wp, &
        "preal array constructor, whether mean is correct (2)", &
        number_of_failures)
    call real_comparison_test(array_1(3)%mean, 3.0_wp, &
        "preal array constructor, whether mean is correct (3)", &
        number_of_failures)
    
    call real_comparison_test(array_1(1)%stdev, 0.3_wp, &
        "preal array constructor, whether stdev is correct (1)", &
        number_of_failures)
    call real_comparison_test(array_1(2)%stdev, 0.2_wp, &
        "preal array constructor, whether stdev is correct (2)", &
        number_of_failures)
    call real_comparison_test(array_1(3)%stdev, 0.1_wp, &
        "preal array constructor, whether stdev is correct (3)", &
        number_of_failures)
    
    ! 4c. Operators
    ! -------------
    
    y = N(6.0_wp / 7.0_wp, 1.0_wp / 7.0_wp)
    
    ! Addition
    
    z = x + y
    call real_comparison_test(z%mean, 1.0_wp, &
        "preal scalar addition, mean check", &
        number_of_failures)
    
    ! Subtraction
    
    z = x - y
    call real_comparison_test(z%mean, -5.0_wp / 7.0_wp, &
        "preal scalar subtraction, mean check", &
        number_of_failures)
    
    ! Multiplication
    
    z = x * y
    call real_comparison_test(z%mean, 6.0_wp / 49.0_wp, &
        "preal scalar multiplication, mean check", &
        number_of_failures)
    
    ! Division
    
    z = x / y
    call real_comparison_test(z%mean, 1.0_wp / 6.0_wp, &
        "preal scalar division, mean check", &
        number_of_failures)
    
    array_2(1) = N(1.0_wp, 0.1_wp)
    array_2(2) = N(1.0_wp, 0.1_wp)
    array_2(3) = N(1.0_wp, 0.1_wp)
    
    ! Addition
    
    array_3(:) = array_1(:) + array_2(:)
    call real_comparison_test(array_3(1)%mean, 2.0_wp, &
        "preal array addition, mean check (1)", &
        number_of_failures)
    call real_comparison_test(array_3(2)%mean, 3.0_wp, &
        "preal array addition, mean check (2)", &
        number_of_failures)
    call real_comparison_test(array_3(3)%mean, 4.0_wp, &
        "preal array addition, mean check (3)", &
        number_of_failures)
    
    ! Subtraction
    
    array_3(:) = array_1(:) - array_2(:)
    call real_comparison_test(array_3(1)%mean, 0.0_wp, &
        "preal array subtraction, mean check (1)", &
        number_of_failures)
    call real_comparison_test(array_3(2)%mean, 1.0_wp, &
        "preal array subtraction, mean check (2)", &
        number_of_failures)
    call real_comparison_test(array_3(3)%mean, 2.0_wp, &
        "preal array subtraction, mean check (3)", &
        number_of_failures)
    
    ! Multiplication
    
    array_2(1) = N(2.0_wp, 0.1_wp)
    array_2(2) = N(2.0_wp, 0.1_wp)
    array_2(3) = N(2.0_wp, 0.1_wp)
    
    array_3(:) = array_1(:) * array_2(:)
    call real_comparison_test(array_3(1)%mean, 2.0_wp, &
        "preal array multiplication, mean check (1)", &
        number_of_failures)
    call real_comparison_test(array_3(2)%mean, 4.0_wp, &
        "preal array multiplication, mean check (2)", &
        number_of_failures)
    call real_comparison_test(array_3(3)%mean, 6.0_wp, &
        "preal array multiplication, mean check (3)", &
        number_of_failures)
    
    ! Division
    
    array_3(:) = array_1(:) / array_2(:)
    call real_comparison_test(array_3(1)%mean, 1.0_wp / 2.0_wp, &
        "preal array division, mean check (1)", &
        number_of_failures)
    call real_comparison_test(array_3(2)%mean, 1.0_wp, &
        "preal array division, mean check (2)", &
        number_of_failures)
    call real_comparison_test(array_3(3)%mean, 3.0_wp / 2.0_wp, &
        "preal array division, mean check (3)", &
        number_of_failures)
    
    ! TODO: checking number_of_preals and preal_id for each operator
    
    array_1(1) = N(1.0_wp, 0.3_wp)
    array_1(2) = N(2.0_wp, 0.2_wp)
    array_1(3) = N(3.0_wp, 0.1_wp)
    
    array_2(1) = N(1.0_wp, 0.1_wp)
    array_2(2) = N(1.0_wp, 0.1_wp)
    array_2(3) = N(1.0_wp, 0.1_wp)
    
    ! 5. Final result
    ! ---------------
    
    call tests_end(number_of_failures)
    stop
end program tests