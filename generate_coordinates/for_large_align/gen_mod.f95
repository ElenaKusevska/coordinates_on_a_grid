module generate_structures
   use auxilary_subroutines
   use global_module
implicit none
contains
!
!-------------------------------------------------
!soubroutine to generate a grid:
!-------------------------------------------------
!
subroutine generate_grid (dim2,gridd)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
integer :: dim1, i, j
integer, intent(out) :: dim2
real(dp) :: inc, a, n_points, y, z
real(dp), allocatable, dimension(:,:), intent(out) :: gridd
!
!-------------------------------------------------------
!a - length of one axis
!n_points, dim1 - number of points on one axis
!dim2 - total number of points in the grid
!---------------------------------------------------------
!for example, for a cube with length = 2, and increments of 0.4, 
!dim1 = 2/0.4 + 1 = 6
!i.e. 6 points on each axis:
!0---0.4---0.8---0.12---0.16---2.0
!and dim2 = 6*6*6=312 points on the grid
!-----------------------------------------------------------
!
write(*,*) 'what size should the grid be?'
read(*,*) a
write(*,*) 'what size should the increment be?'
read(*,*) inc
n_points = a/inc + 1
!
!---------------------------------------------------
!round up the number of points to the nearest integer:
!------------------------------------------------------
!
dim1 = nint(n_points)
write(25,*) 'number of points on each axis:', n_points, dim1
!
!---------------------------------------------------
!correct the length of each axis (a) considering the
!number of points and the size of the increment:
!-------------------------------------------------------
!
a = dble(dim1 - 1) * inc
write(25,*) 'new value of a:', a
!
!----------------------------------------------------------
!determine the total number of points:
!------------------------------------------------------------
!
dim2=dim1**3
write(25,*) 'total number of points:', dim2
!
allocate( gridd(dim2,3) )
!
!----------------------------------------------------
!fill the grid with values:
!----------------------------------------------------
!
z=0.0
y=0.0
do i = 1, dim2
  if (MODULO(i,dim1) /= 0 ) then
    gridd(i,1) = (MODULO(i,dim1) - 1) * inc
    gridd(i,2) = y
    gridd(i,3) = z
  else if (MODULO(i,dim1) == 0) then
    gridd(i,1) = a
    gridd(i,2) = y
    gridd(i,3) = z
    y = y + inc
  end if
  if (MODULO(i,dim1**2) == 0) then
    z = z + inc
    y = 0.0
  end if
end do
!
!-------------------------------------------------------------
!write the grid 
!----------------------------------------------------------------
!
open (unit=1, file='grid.xyz', status='replace', action='write')
  write(1,*) dim2
  write(1,*) 'grid'
  do i = 1, dim2
    write(1,'(A19,3F11.7)')  ' C                 ', (gridd(i,j), j=1,3)
  end do
close(1)
!
!--------------------------------------------------------
!the purpose of this subroutine is to generate a grid:
!------------------------------------------------------- 
!   /                              /      /  |
!  /(0,a,1)----(1,a,1)----....----(a,a,1)/   |
! /      /    /     /            /      /    |
!|(0,a,0)----(1,a,0)----.....----(a,a,0)|    |
!|(0,a-1,0)---(1,a-1,0)---..---(a,a-1,0)|   / 
!|...                                   |  /  
!|(0,1,0)----(1,1,0)----.....----(a,1,0)| /   
!|(0,0,0)----(1,0,0)----.....----(a,0,0)|/    
!--------------------------------------------------------------
!How does the program determine the values on each of the axes?
!-------------------------------------------------------------
!From the previus example, let's take
!length = 2
!increment = 0.4
!dim1=6
!dim2=312
!-----------------------------------------------------------------
! do i = 1, dim2:
!-----------------------------------------------------------------
!i |x    y    z|
!-------------------------------------------------
!1 |0.0  0    0| x = 0.4*(0) = 0.4*(1-1) = inc*[modulo(i,dim1) -1]
!2 |0.4  0    0| x = 0.4*(1) = 0.4*(2-1) = inc*[modulo(i,dim1) -1]
!3 |0.8  0    0| x = 0.4*(2) = 0.4*(3-1) = inc*[modulo(i,dim1) -1]
!4 |1.2  0    0|
!5 |1.6  0    0|
!6 |2.0  0    0| modulo(i,dim1) = 0, x = length
!-------------------------
!y = y + inc
!-------------------------
!7 |0.0  0.4  0|
!8 |0.4  0.4  0|
!9 |0.8  0.4  0|
!10|1.2  0.4  0| x = 0.4*(3) = 0.4*(4-1) = inc*[modulo(i,dim1) -1]
!11|1.6  0.4  0| x = 0.4*(4) = 0.4*(5-1) = inc*[modulo(i,dim1) -1]
!12|2.0  0.4  0| modulo(i,dim1) = 0, x = length
!---------------------------
!y = y + inc
!-------------------------
!13|0.0  0.8  0|
!14|0.4  0.8  0|
!15|0.8  0.8  0|
!16|1.2  0.8  0|
!17|1.6  0.8  0|
!18|2.0  0.8  0| modulo(i,dim1) = 0, x = length
!---------------------------
!y = y + inc
!---------------------------
!19|0.0  1.2  0|
!20|0.4  1.2  0|
!21|0.8  1.2  0|
!22|1.2  1.2  0|
!23|1.6  1.2  0|
!24|2.0  1.2  0| modulo(i,dim1) = 0, x = length
!---------------------------
!y = y + inc
!---------------------------
!25|0.0  1.6  0|
!26|0.4  1.6  0|
!27|0.8  1.6  0|
!28|1.2  1.6  0|
!29|1.6  1.6  0|
!30|2.0  1.6  0| modulo(i,dim1) = 0, x = length
!---------------------------
!y = y + inc
!---------------------------
!31|0.0  2.0  0|
!32|0.4  2.0  0|
!33|0.8  2.0  0|
!34|1.2  2.0  0|
!35|1.6  2.0  0|
!36|2.0  2.0  0| modulo(i,dim1) = 0, x = length
!---------------------------
!i = dim1**(2) -> an entire plane has been filled.
!modulo(dim1**2,i) = 0
!y = 0.0
!z = z + inc
!---------------------------
!37|0.0  0.0  0.4|
!38|0.4  0.0  0.4|
!39|0.8  0.0  0.4|
!40|1.2  0.0  0.4|
!41|1.6  0.0  0.4|
!42|2.0  0.0  0.4|
!
end subroutine generate_grid
!
!---------------------------------------------------------------
!Determine the total number of possible combinations
!-------------------------------------------------------------------
!
subroutine number_of_combinations(d_grid1, n21, many_combs)
implicit none
!
integer(kind=16), intent(in) :: d_grid1
integer(kind=16), intent(in) :: n21
integer(kind=16) :: n_combs1
character(len=1), intent(out) :: many_combs
!
n_combs1 = combination_x_of_p(n21,d_grid1)
write(25,*) 'number of combinations:', n_combs1
!
if (n_combs1 .le. 100000) then
   many_combs = 'N'
else if (n_combs1 .gt. 100000) then
   many_combs = 'Y'
end if
!
end subroutine number_of_combinations
!
!---------------------------------------------------------------
!create molecular structures by placing atoms on different points
!on the grid
!---------------------------------------------------------------
!
subroutine grid_to_molecule_small(n_grid, n2, method1, V2, grid1, c2, m2, combination1)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
integer, intent(in) :: n_grid
integer, intent(in) :: n2 ! dimension of the grid
character(len=17), intent(in) :: method1
logical, intent(in) :: V2 !vanadium 1 or 2
real(dp), allocatable, dimension(:,:), intent(inout) :: grid1
real(dp), allocatable, dimension(:,:), intent(out) :: combination1
integer, intent(inout) :: c2, m2
integer, allocatable, dimension(:) :: combination, past_combs, previous_runs
integer, allocatable, dimension(:,:) :: combinations
real(dp), allocatable, dimension(:,:) :: coords2
integer :: i, j, x, y, k, a, l, n, n_combs, io, random_comb, r, ncombs
real(dp), dimension(1) :: random
character(len=1) :: n_run
!
!-------------------------------------------------------
!creates the molecular coordinates
!-------------------------------------------------------
!-------------------------------------------------------
!generats the structures as combinations of the number of
!atoms in the molecule and the number of points on the grid, 
!in lexicographical order:
!--------------------------------------------------------
!---------------------------------------------------------
!Let's take as an example, a grid of five atoms, used to 
!form a molecule of three. The combinations are:
!
!123 |molecule(3) < 5, so we we increase it by one
!124 |molecule(3) < 5, so we we increase it by one
!125 |molecule(3) = 5, molecule(2) < 4, so we increase
!     molecule(2) by one, and molecule(3) = molecule(2) + 1
!134 |molecule(3) < 5, so we we increase it by one
!135 |molecule(3) < 5, so we we increase it by one
!145 |molecule(3) = 5, molecule(2) = 4, but molecule(1) < 3
!     so, molecule(1) = molecule(1) + 1
!     molecule(2) = molecule(1)(new) + 1, or, molecule(1)(old) + 2
!     molecule(3) = molecule(2)(new) + 1, or, molecule(1)(old) + 3
!     
!234 |molecule(3) < 5, so we we increase it by one
!235 |molecule(3) = 5, molecule(2) < 4, so we increase
!     molecule(2) by one, and molecule(3) = molecule(2) + 1
!245 |molecule(3) = 5, molecule(2) = 4, but molecule(1) < 3
!     so, molecule(1) = molecule(1) + 1
!     molecule(2) = molecule(1)(new) + 1, or, molecule(1)(old) + 2
!     molecule(3) = molecule(2)(new) + 1, or, molecule(1)(old) + 3
!345 |molecule(1) = 3 --> stop the loop. 
!
!-------------------------------------------------------
!
allocate ( combination(n2), coords2(n2,3), combination1(n2,3) )
!
do i = 1, n2
   combination(i) = i !123
end do
!
do x = 1, n2
   do y = 1, 3
      combination1(x,y) = grid1(combination(x),y)
   end do
end do
!
call write_to_file(combination1, method1, n2, V2, c2, m2)
!
!--------------------------------------------------
!now, we generate all of the other combinations:
!--------------------------------------------------
!
open(unit=4, file='combination.txt', status='replace', action='write')
!
a = 2
k = n2 + 1 !drives the increase of the last integer in the
!          combination, combination(m)
!
do while (combination(1) .lt. (n_grid - n2 + 1))
   if (combination(n2) .lt. n_grid) then
      combination(n2) = k !124 125 135 235
      k = k + 1
      !
      write(4,*) combination
      !   
   else if (combination(n2) .eq. n_grid) then
      do j = 1, n2
         l = n2 - j
         if ( combination(j) .eq. (n_grid - l) ) then
            combination(j-1) = combination(j-1) + 1
            do n = j, n2
               combination(n) = combination(n-1) + 1 !134 145 234 245 
                                                                !345
            end do
            k = combination(n2) + 1
            !
            write(4,*) combination
            !
            exit
         end if
      end do
   end if
   a = a + 1
end do 
!
close(4)
!
!------------------------------------------------------
!to count the number of possible combinations:
!-----------------------------------------------------
!
open(unit=9, file='combination.txt', status='old', action='read')
n_combs = 1
do
   read(9,*,iostat=io) combination
   if (io /= 0) exit
   n_combs = n_combs + 1
end do
write(25,*) 'ncombs', n_combs
close(9)
!
!-------------------------------------------------------
!to store these combinations in a matrix:
!-------------------------------------------------------
!
allocate ( past_combs(n_combs), combinations(n_combs, n2) )
!
open(unit=10, file='combination.txt', status='old', action='read')
do i = 2, n_combs
   read(10,*) (combinations(i,j), j = 1, n2)
end do
close(10)
do j = 1, n2
   combinations(1,j) = j
end do
!
do i = 1, n_combs
   past_combs(i) = 0
end do
!
!-----------------------------------------------------------
!to identify the combinations from previous runs:
!-------------------------------------------------------------
!
write(*,*) 'is this the first run? [Y/N]'
read(*,*) n_run
if (n_run == 'N') then
   open(unit=30, file='previous_runs.txt', status='old', action='read')
   ncombs = 0
   do
      read(30,*,iostat=io) i
      if (io /= 0) exit
      ncombs = ncombs + 1
   end do
   write(*,*) 'ncombs', ncombs
   close(30)
!
   open(unit=31, file='previous_runs.txt', status='old', action='read')
   allocate(previous_runs(ncombs))
   do i = 1, ncombs
      read(31,*) previous_runs(i)
   end do
   close(31)

   do i = 1, ncombs
      r = previous_runs(i)
      past_combs(r) = r
   end do
end if
!
!----------------------------------------------------------------
!randomly select a certain number of combinations and print
!the corresponding structures. 
!----------------------------------------------------------------
!
open(unit=12, file='random_comb.txt', status='replace', action='write')
open(unit=32, file='previous_runs.txt', status='replace', action='write', &
   position="append")
!
a = 1
do while ((m2 .lt. 600) .and. (a .lt. n_combs))
   call random_number(random)
   random_comb = nint(random(1) * n_combs)
   if (random_comb == 0) cycle !because it gives an error
   if (random_comb == 1) cycle
   if (random_comb == past_combs(random_comb)) cycle !because we have 
!                                                     already submitted this
!                                                     job for optimization.
   do i = 1, n2
      combination(i) = combinations(random_comb,i)
   end do
   write(12,*) a, random_comb, '- combination:', combination
   do x = 1, n2
      do y = 1, 3
         coords2(x,y) = grid1(combination(x),y)
      end do
   end do
   call write_to_file (coords2, method1, n2, V2, c2, m2)
   past_combs(random_comb) = random_comb !to make sure that it is not
!                                         repeated in the same run
   write(32,*) random_comb
   a = a + 1
end do
close(12)
close(32)
!
deallocate(combination, combinations, past_combs, coords2)
deallocate(grid1)
close(9)
!
end subroutine grid_to_molecule_small
!
subroutine grid_to_molecule_large(n_grid2, n22, method1, V22, grid2, c22, m22, combination1)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
integer, intent(in) :: n_grid2, n22 ! dimension of the grid
character(len=17), intent(in) :: method1
logical, intent(in) :: V22 !vanadium 1 or 2
real(dp), allocatable, dimension(:,:), intent(inout) :: grid2
real(dp), allocatable, dimension(:,:), intent(out) :: combination1
integer, intent(inout) :: c22, m22
integer(kind=16) :: n_combs2, xx, pp, h, r, b
integer(kind=16), allocatable, dimension(:) :: past_combs2, previous_runs2
integer, allocatable, dimension(:) :: acombination
real(dp), allocatable, dimension(:,:) :: coords22
integer :: i, x, y, io, n_combs, random_comb2
real(dp), dimension(1) :: random
character(len=1) :: n_run
!
!-------------------------------------------------------
!creating the molecular coordinates
!-------------------------------------------------------
!-------------------------------------------------------
!The structures are generated as the kth combination in lexicographical
!order, of the number of atoms in the molecule and the number of points 
!on the grid, using the combinadic method
!--------------------------------------------------------
!
allocate ( acombination(n22), coords22(n22,3), combination1(n22,3) )
!
do i = 1, n22
   acombination(i) = i !123
end do
!
do x = 1, n22
   do y = 1, 3
      combination1(x,y) = grid2(acombination(x),y)
   end do
end do
!
call write_to_file(combination1, method1, n22, V22, c22, m22)
!
!------------------------------------------------------
!to count the number of possible combinations:
!-----------------------------------------------------
!
xx = n22
pp = n_grid2
n_combs2 = combination_x_of_p(xx,pp)
!
if (n_combs2 .gt. 100000000) then
   n_combs2 = 100000000
end if
!
allocate ( past_combs2(n_combs2) )
!
do h = 1, n_combs2
   past_combs2(h) = 0
end do
b = 1
!
!-----------------------------------------------------------
!to identify the combinations from previous runs:
!-------------------------------------------------------------
!
write(*,*) 'is this the first run? [Y/N]'
read(*,*) n_run
if (n_run == 'N') then
   open(unit=30, file='previous_runs.txt', status='old', action='read')
   n_combs = 0
   do
      read(30,*,iostat=io) i
      if (io /= 0) exit
      n_combs = n_combs + 1
   end do
   write(*,*) 'ncombs', n_combs
   close(30)
!
   open(unit=31, file='previous_runs.txt', status='old', action='read')
   allocate(previous_runs2(n_combs))
   do i = 1, n_combs
      read(31,*) previous_runs2(i)
   end do
   close(31)

   do i = 1, n_combs
      past_combs2(i) = previous_runs2(i)
   end do
!
   b = n_combs
   deallocate(previous_runs2)
end if
!
!----------------------------------------------------------------
!randomly select a certain number of combinations
!----------------------------------------------------------------
!
open(unit=12, file='random_comb.txt', status='replace', action='write')
open(unit=32, file='previous_runs.txt', status='replace', action='write', &
   position="append")
!
do while ((m22 .lt. 600) .and. (b .lt. n_combs2))
   call random_number(random)
   random_comb2 = nint(random(1) * n_combs2)
   if (random_comb2 == 0) cycle
   if (random_comb2 == 1) cycle
   !
   do r = 1, b
      if (random_comb2 == (past_combs2(r))) cycle
   end do
   !
   call lexicographical_order (random_comb2, n_grid2, n22, acombination)
   !
   write(12,*) b, random_comb2, '- combination:', acombination
   !
   do x = 1, n22
      do y = 1, 3
         coords22(x,y) = grid2(acombination(x),y)
      end do
   end do
   !
   call write_to_file (coords22, method1, n22, V22, c22, m22)
   !
   b = b + 1
   past_combs2(b) = random_comb2
   write(32,*) random_comb2
end do
close(12)
close(32)
!
deallocate(acombination, past_combs2, coords22)
deallocate(grid2)
close(9)
!
end subroutine grid_to_molecule_large
!
!-----------------------------------------------------------------
!Subroutine to write up structures
!-----------------------------------------------------------------
!
subroutine write_to_file (coords10, method2, n10, V10, c10, m10)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
real(dp), allocatable, dimension(:,:), intent(inout) :: coords10
real(dp), allocatable, dimension(:,:) :: test_coords, flip_coords
character(len=17), intent(in) :: method2
integer, intent(in) :: n10
real(dp), allocatable, dimension(:) :: mass10
logical, intent(in) :: V10
integer, intent(inout) :: c10, m10
integer :: i, j, k, num
character(len=1) :: logic1, logic2
character(len=3) :: file1
character(len=8) :: file11
real(dp) :: coss, sinn
real(dp), dimension(3,3) :: Rzz
!
call test1(coords10, n10, logic1)
write(*,*)
write(*,*) 'test1'
write(*,*) logic1
write(*,*)
if (logic1 == 'Y') then
   call mass_array(n10, mass10)
   call center_and_main_inertia_vector (mass10, n10, coords10)
   call test2 (mass10, coords10, n10, c10, logic2)
   if (logic2 == 'Y') then
      !
      !rotate molecule by 90 degrees around the z-axis
      !in order to interchange the y- and x-axes.
      !
      allocate(test_coords(n10,3))
      coss = 0.0
      sinn = 1.0
      call z_rotation_matrix (coss, sinn, Rzz)
      test_coords = matmul(coords10, Rzz)
      call test2 (mass10, test_coords, n10, c10, logic2)
      if (logic2 == 'Y') then
         allocate(flip_coords(n10,3))
         !
         !flip the coordinates in coords10 by the 
         !x-, y- and z-axes:
         !
         do j = 1, 3
            do i = 1, n10
               do k = 1, 3
               flip_coords(i,k) = coords10(i,k)
               end do
            end do
            do i = 1, n10
               flip_coords(i,j) = -coords10(i,j)
            end do
            call test2 (mass10, flip_coords, n10, c10, logic2)
            if (logic2 == 'N') exit
         end do
         if (logic2 == 'Y') then
            !
            !flip the coordinates in test_coords 
            !by the x-, y- and z- axes.
            !
            do j = 1, 3
               do i = 1, n10
                  do k = 1, 3
                  flip_coords(i,k) = test_coords(i,k)
                  end do
               end do
               do i = 1, n10
                  flip_coords(i,j) = -test_coords(i,j)
               end do
               call test2 (mass10, flip_coords, n10, c10, logic2)
               if (logic2 == 'N') exit
            end do
         end if
      deallocate (flip_coords)
      end if
      !
      deallocate (test_coords)
   end if      
   !
   write(*,*)
   write(*,*) 'test2'
   write(*,*) logic2
   write(*,*)
   !
   !write out the structure:
   !
   if (logic2 == 'Y') then
      write(*,*)
      write(*,*) 'c10', c10
      write(*,*)
      !
      !For test:
      !
      write(file1, "(I3)") c10
      num = 1000 + c10
      write(file11, "(I4,A4)") num, '.xyz'
      open(unit=c10, file=file1, status='new', action='write')
      do i = 1, n10
         write(c10,*) mass10(i), (coords10(i,j), j = 1, 3)
      end do
      close(c10)
      !
      !For me:
      !
      open(unit=num, file=file11, status='new', action='write')
      write(num,'(I2)') n10
      write(num,'(A17)') method2
      do i = 1, n10
         write(num,'(A1,A1,A17,3F11.7)') ' ', 'C', '                ', (coords10(i,j), j = 1, 3)
      end do
      close(num)
      !
      c10 = c10 + 1
      !
      call asign_labels(coords10, method2, V10, m10, n10)
   end if
   deallocate(mass10)
end if
!
end subroutine write_to_file
!
!-------------------------------------------------------
!make xyz structures with labels:
!-------------------------------------------------------
!
subroutine asign_labels (coords7, method3, vanadium2, m7, n7)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
real(dp), allocatable, dimension(:,:), intent(inout) :: coords7
character(len=17), intent(in) :: method3
real(dp), allocatable, dimension(:,:) :: random_array
logical, intent(in) ::  vanadium2
integer, intent(in) :: n7 !number of atoms
integer, intent(inout) :: m7 !structure in to print
character(len=1), allocatable, dimension(:) :: labels
character(len=7) :: file7
logical, allocatable, dimension(:) :: SEA_T_F
integer :: i, j, l, p
!
call SEA (coords7, n7, SEA_T_F)
!
allocate ( random_array(n7,3) )
!
call random_number(random_array)
do i = 1, n7
   do j = 1, 3
      coords7(i,j) = coords7(i,j) + (random_array(i,j)-0.5)*0.2
   end do
end do
deallocate(random_array)
!
allocate( labels(n7) )
!
if (vanadium2 .eqv. .true.) then
   do i = 1, n7 - 1
      do l = i + 1, n7
         if (SEA_T_F(i) .eqv. .false.) then
            if (SEA_T_F(l) .eqv. .false.) then
               do j = 1, n7
                  labels(j) = 'B'
               end do
               labels(i) = 'V'
               labels(l) = 'V'
               !
               write(file7, "(I3,A4)") m7, ".gjf"
               open (unit=m7, file=file7, status='new', action='write')
               write(m7,'(I2)') n7
               write(m7,'(A17)') method3
               do p = 1, n7
                  write(m7,'(A1,A1,A17,3F11.7)') ' ', labels(p), '                     ', (coords7(p,j), j=1,3)
               end do
               close(m7)
               !
               m7 = m7 + 1
            end if
         end if
      end do
   end do
   !
else if (vanadium2 .eqv. .false.) then
   do i = 1, n7
      if (SEA_T_F(i) .eqv. .false.) then
         do j = 1, n7
            labels(j) = 'B'
         end do
         labels(i) = 'V'
         !
         write(file7, '(I3,A4)') m7, ".xyz"
         open (unit=m7, file=file7, status='new', action='write')
         write(m7,'(I2)') n7
         write(m7,'(A17)') method3
         do p = 1, n7
            write(m7,'(A1,A1,A17,3F11.7)') ' ', labels(p), '                 ', (coords7(p,j), j=1,3)
         end do
         close(m7)
         !
         m7 = m7 + 1
      end if
   end do
end if
!
deallocate (labels)
!
end subroutine asign_labels
!
!--------------------------------------------------------
!generate random 3d structures:
!--------------------------------------------------------
!
subroutine generate_random3d (n1, d1, coordinates4)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
integer, intent(in) :: n1 !number of atoms
real(dp), intent(in) :: d1 !average size of the molecule
real(dp), allocatable, dimension(:,:), intent(out) :: coordinates4
integer :: i, j 
!
allocate( coordinates4(n1,3) )
!
call random_number(coordinates4)
!
do i = 1, n1
  do j = 1, 3
    coordinates4(i,j) = coordinates4(i,j) * d1
  end do
end do
!
end subroutine generate_random3d
!
!-------------------------------------------------------
!generate 2d structures:
!-------------------------------------------------------
!
subroutine generate_random2d (n2, d2, coordinates5)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
integer, intent(in) :: n2
real(dp), intent(in) :: d2
real(dp), allocatable, dimension (:,:), intent(out) :: coordinates5
integer :: i, j
!
allocate( coordinates5(n2,3) )
!
call random_number(coordinates5)
!
do i = 1, n2
  do j = 1, 2
    coordinates5(i,j) = coordinates5(i,j) * d2
  end do
end do
!
do i = 1, n2
  coordinates5(i,3) = 0.0
end do
!
end subroutine generate_random2d
!
!-------------------------------------------------------
!subroutine for coordinate walking in 2d
!-------------------------------------------------------
!
subroutine coordinate_walk (first_coords, method15, D3, V15, n15, &
      c15, m15)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
real(dp), allocatable, dimension(:,:), intent(in) :: first_coords
character(len=17), intent(in) :: method15
character(len=1), intent(in) :: D3
integer, intent(in) :: n15
logical, intent(in) :: V15
integer, intent(inout) :: c15, m15
real(dp), allocatable, dimension(:,:) :: coords15, test
integer :: i, j, m_end, dim_walk, m14, x, y, k, m13, m17
real(dp) :: move
character(len=1) :: end_cycle
!
allocate( coords15(n15,3), test(n15,3) )
!
do i = 1, n15
   do j = 1, 3
      coords15(i,j) = first_coords(i,j)
   end do
end do
!
if (D3 == 'N') then
   m_end = m15 + 100
   dim_walk = 2
else if (D3 == 'Y') then
   m_end = m15 + 200
   dim_walk = 3
else 
   write(25,*) 'something is wrong'
   stop
end if
!
write(*,*) 'D3', D3, 'm_end', m_end, 'dim_walk', dim_walk
!
i = 1 ! used to loop over the atoms. 
k = 1
!
write(*,*) 'by how much should the value for each coordinate change?'
read(*,*) move
m13 = m15
m17 = m15
!
do while (m15 .lt. m_end)
   write(25,*)
   write(25,*) 'coordinate walk'
   write(25,*) 'cycle', k, 'walk', i
   write(25,*) 'change of coordinates', move
   write(25,*)
   do x = 1, n15
      do y = 1, 3
         test(x,y) = coords15(x,y)
      end do
   end do
      m14 = m15
      do j = 1, dim_walk
         write(25,*)'--------------------------------------------'
         write(25,*)
         write(25,*) i, j, 'test(i,j)-before', test(i,j)
         test(i,j) = random_walk(test(i,j), move)
         write(25,*) 'test(i,j)-after', test(i,j)
      
         !
         call write_to_file (test, method15, n15, V15, c15, m15)
         !
         if (m15 .gt. m14) then
            write(25,*) 'm15', m15
            write(25,*) 'successful walk'
            do x = 1, n15
               do y = 1, 3
                  coords15(x,y) = test(x,y)
               end do
            end do
            !
         else
            write(*,*) 'bad walk'
         end if
      end do
      if (i == n15) then
         i = 1
         k = k + 1
         !
         write(*,*) 'structures printed at the start of the subroutine:'
         write(*,*) m17
         write(*,*) 'structures printed up to the start of the cycle:'
         write(*,*) m13
         write(*,*) 'structures printed now:'
         write(*,*) m15
         write(*,*) 'exit? [Y/N]'
         read(*,*) end_cycle
         if (end_cycle == 'Y') exit
         write(*,*) 'new value for the change of coordinates?'
         read(*,*) move
         m13 = m15
      else 
         i = i + 1
      end if 
end do
!
deallocate(coords15, test)

end subroutine coordinate_walk
!
!------------------------------------------------
!subroutine to initialize the mass=1 array, used for comparisons
!-------------------------------------------------
!
subroutine mass_array(n12, mass12)
implicit none
integer, parameter :: dp = SELECTED_REAL_KIND(15)
!
integer, intent(in) :: n12
real(dp), allocatable, dimension(:), intent(out) :: mass12
integer :: i
!
allocate(mass12(n12))
do i = 1, n12
   mass12(i) = 1.0D0
end do
!
end subroutine mass_array
!
end module generate_structures

