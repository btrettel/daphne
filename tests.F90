! Tests for Daphne
program tests
    use, intrinsic :: iso_fortran_env
    
    implicit none
    
#ifndef double_precision
    integer, parameter :: udrealp = REAL128
#else
    integer, parameter :: udrealp = REAL64
#endif
    
    real(udrealp) :: x
    
    x = sqrt(2._udrealp)
    print *, x
end program tests
