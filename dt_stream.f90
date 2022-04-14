module m ! GitHub FortranTip dt_stream.f90 
! pdt_stream.f90 at GitHub uses parameterized derived types 
implicit none
integer, parameter :: nlen = 10
type :: data_frame
   character (len=nlen), allocatable :: col_names(:) ! (n2)
   real                , allocatable :: x(:,:)       ! (n1,n2)
end type data_frame
contains
subroutine write_stream(df,iu)
type(data_frame), intent(in) :: df
integer         , intent(in) :: iu
! write dimensions of df components followed by values
write (iu) shape(df%x),df%col_names,df%x
end subroutine write_stream
!
subroutine read_stream(df,iu)
type(data_frame), intent(out) :: df
integer         , intent(in)  :: iu
integer                       :: n1,n2
read (iu) n1,n2 ! read dimensions of df%x
call alloc(df,n1,n2) ! allocate components of df
read (iu) df%col_names,df%x ! read df
end subroutine read_stream
!
pure subroutine alloc(df,n1,n2)
type(data_frame), intent(out) :: df
integer         , intent(in)  :: n1,n2
allocate (df%x(n1,n2),df%col_names(n2))
end subroutine alloc
end module m
!
program main
use m, only: data_frame, alloc, write_stream, read_stream
implicit none
integer, parameter :: n1 = 10**7, n2 = 2
type(data_frame) :: df_in,df_out
character (len=*), parameter :: fname = "temp.bin"
integer :: iu
call alloc(df_in,n1,n2) ! allocate components of df_in
df_in%col_names = ["x1","x2"]
call random_number(df_in%x)
open (unit=iu,file=fname,form="unformatted",access="stream")
call write_stream(df_in,iu) ! write dimensions and values of df_in
rewind (iu)
call read_stream(df_out,iu) ! read df_out and check it
print*,minval(df_in%x),maxval(df_in%x),all(df_in%x == df_out%x), &
       all(df_in%col_names==df_out%col_names)
end program main
! sample output:
!    1.78813934E-07  0.999999940     T T
