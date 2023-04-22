! # $File$
! 
! Summary: Test to make sure that assert(.false.) stops the program with an error.
! Standard: Fortran 2003
! Preprocessor: CPP
! Author: Ben Trettel (<http://trettel.us/>)
! Last updated: $Date$
! Revision: $Revision$
! Project: [Daphne](https://github.com/btrettel/daphne)
! License: [LGPLv3](https://www.gnu.org/licenses/lgpl-3.0.en.html)

#define ASSERT(ARG1, ARG2) assert(ARG1, ARG2, __FILE__, __LINE__)
#define CHECK_FLAG(ARG) check_flag(ARG, __FILE__, __LINE__)
#define __WRITEFILELINE__ write(unit=*, fmt=*) __FILE__, __LINE__

program fail
    ! Table of contents
    ! -----------------
    ! 
    ! 1. Set modules and other boilerplate
    ! 2. Declare variables
    ! 3. Final result
    
    ! 1. Set modules and other boilerplate
    ! ------------------------------------
    
    use daphne
    implicit none
    
    ! 2. Declare variables
    ! --------------------
    
    integer(kind=i5) :: number_of_failures
    
    number_of_failures = 0
    
    ! 3. Final result
    ! ---------------
    
    ! To get code coverage for all of logical_test.
    
    call logical_test(.false., "logical test (failure)", number_of_failures)
    
    ! To get code coverage for all of real_equality_test.
    
    call real_equality_test(15.0_wp, 20.0_wp, "real_equality_test (failure)", number_of_failures)
    
    ! To get code coverage for all of real_inequality_test.
    
    call real_inequality_test(15.0_wp, 15.0_wp, "real_inequality_test (failure)", number_of_failures)
    
    ! For testing the `tests_end`, `assert`, and `error_stop` procedures.
    
    call tests_end(number_of_failures)
    stop
end program fail
