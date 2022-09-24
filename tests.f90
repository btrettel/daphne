! Tests for Daphne
program tests
    use daphne
    use stdlib
    implicit none
    
    type(preal) :: x, y
    
    x%value = 1._wp / 7._wp
    y%value = 6._wp / 7._wp
    print *, wp, x%value
    
    !call check(x%value > 0._wp)
    !call check(.false.)
    call check(.true.)
    
    x = x + y
    print *, wp, x%value
end program tests
