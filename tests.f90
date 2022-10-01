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
    
    ! 1. Set modules and other boilerplate
    ! ------------------------------------
    
    use daphne
    use nonstdlib
    implicit none
    
    type(preal) :: x
    type(preal) :: y
    type(preal), dimension(3) :: array_1
    type(preal), dimension(3) :: array_2
    
    ! TODO: Constructor setting right value
    ! TODO: Constructor setting right uncertainty
    ! TODO: Constructor setting right dimensions
    ! TODO: Constructor setting right lower bound
    ! TODO: Constructor setting right upper bound
    ! TODO: Constructor incrementing number_of_preals
    ! TODO: Constructor setting right preal_id
    ! TODO: Addition (including checking number_of_preals and preal_id)
    ! TODO: Subtraction (including checking number_of_preals and preal_id)
    ! TODO: Multiplication (including checking number_of_preals and preal_id)
    ! TODO: Division (including checking number_of_preals and preal_id)
    
    x = N(1._wp / 7._wp, 1._wp / 7._wp)
    
    y = N(6._wp / 7._wp, 1._wp / 7._wp)
    
    array_1(1) = N(1._wp, 0.1_wp)
    array_1(2) = N(2._wp, 0.1_wp)
    array_1(3) = N(3._wp, 0.1_wp)
    
    array_2(1) = N(1._wp, 0.1_wp)
    array_2(2) = N(1._wp, 0.1_wp)
    array_2(3) = N(1._wp, 0.1_wp)
    
    array_2(:) = array_1(:) + array_2(:)
    
    !call check(x%value > 0._wp)
    !call check(.false.)
    call check(.true.)
    !call check(.false., msg="Testing assertion message.")
    
    x = x + y
    print *, wp, x%mean
end program tests
