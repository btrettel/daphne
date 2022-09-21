module daphne
    implicit none
    private
    public wp, dreal, operator(+), operator(-)
    
    ! Double precision, but labeled as wp for "working precision" in case I want to change this later.
    ! Quad precision: integer, parameter :: wp = selected_real_kind(33, 4931)
    integer, parameter :: wp = selected_real_kind(15, 307)
    
    type dreal
        real(wp) :: value
    end type dreal
    
    interface operator (+)
        module procedure dadd
    end interface
    
    interface operator (-)
        module procedure dsubtract
    end interface
contains
    function dadd(dreal_1, dreal_2) result (dreal_3)
        type(dreal), intent(in) :: dreal_1, dreal_2
        type(dreal) :: dreal_3
        dreal_3%value = dreal_1%value + dreal_2%value
    end function dadd
    
    function dsubtract(dreal_1, dreal_2) result (dreal_3)
        type(dreal), intent(in) :: dreal_1, dreal_2
        type(dreal) :: dreal_3
        dreal_3%value = dreal_1%value + dreal_2%value
    end function dsubtract
end module daphne
