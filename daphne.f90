! daphne.f90
! ==========
! 
! Daphne is (will be) a Fortran library for rigorous data analysis
! in the physical sciences. Dimensional analysis will prevent many
! potential bugs, and uncertainty propagation will reveal the limits
! of what can be understood from the data. Daphne prioritizes
! correctness over speed, so this library is not intended for HPC.
! 
! To use Daphne, create a variable of type `preal`:
! 
!     type(preal) :: x
! 
! Then initialize the variable with dimensions (uncertainties are on the TODO list):
! 
!     x = 
! 
module daphne
    implicit none
    private
    public wp
    public preal
    public operator(+)
    public operator(-)
    public operator(*)
    public operator(/)
    
    ! `wp` stands for "working precision" in case I want to change the
    ! precision later. This is double precision for now.
    ! Quad precision: selected_real_kind(33, 4931)
    integer, parameter :: wp = selected_real_kind(15, 307)
    
    type preal
        real(wp) :: value
    end type preal
    
    interface operator (+) !
        ! Overload the + operator so that it works for preals.
        module procedure padd
    end interface
    
    interface operator (-) !
        ! Overload the - operator so that it works for preals.
        module procedure psubtract
    end interface
    
    interface operator (*) !
        ! Overload the * operator so that it works for preals.
        module procedure pmultiply
    end interface
    
    interface operator (/) !
        ! Overload the / operator so that it works for preals.
        module procedure pdivide
    end interface
contains
    function padd(preal_1, preal_2) result (preal_3) !
        ! Adds two preals, checking the dimensions in the process.
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value + preal_2%value
    end function padd
    
    function psubtract(preal_1, preal_2) result (preal_3) !
        ! Subtracts two preals, checking the dimensions in the process.
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value - preal_2%value
    end function psubtract
    
    function pmultiply(preal_1, preal_2) result (preal_3) !
        ! Multiplies two preals, checking the dimensions in the
        ! process.
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value * preal_2%value
    end function pmultiply
    
    function pdivide(preal_1, preal_2) result (preal_3) !
        ! Divides two preals, checking the dimensions in the process.
        type(preal), intent(in) :: preal_1, preal_2
        type(preal) :: preal_3
        preal_3%value = preal_1%value / preal_2%value
    end function pdivide
end module daphne
