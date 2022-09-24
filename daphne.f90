module daphne
    implicit none
    private
    public wp, preal, operator(+), operator(-), operator(*), operator(/)
    
    ! Double precision, but labeled as wp for "working precision" in case I want to change this later.
    ! Quad precision: integer, parameter :: wp = selected_real_kind(33, 4931)
    integer, parameter :: wp = selected_real_kind(15, 307)
    
    type preal
        real(wp) :: value
    end type preal
    
    interface operator (+)
        module procedure dadd
    end interface
    
    interface operator (-)
        module procedure dsubtract
    end interface
    
    interface operator (*)
        module procedure dmultiply
    end interface
    
    interface operator (/)
        module procedure ddivide
    end interface
contains
    function dadd(preal_1, preal_2) result (preal_3)
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value + preal_2%value
    end function dadd
    
    function dsubtract(preal_1, preal_2) result (preal_3)
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value - preal_2%value
    end function dsubtract
    
    function dmultiply(preal_1, preal_2) result (preal_3)
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value * preal_2%value
    end function dmultiply
    
    function ddivide(preal_1, preal_2) result (preal_3)
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value / preal_2%value
    end function ddivide
end module daphne
