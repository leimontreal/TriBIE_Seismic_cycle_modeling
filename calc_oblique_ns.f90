!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   Calculate mesh's green coef
!
!   Version:
!       2007-09-18  Clean this program
!       2006-12-13  Create this program
!
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program p_calc_green
    use m_calc_green
    use mpi
   implicit none
  character(*),parameter        :: fname="green_para_cell_1km_smooth_flip.gts"
  integer ::                   n_vertex,n_edge,n_cell
  real(8),DIMENSION(:,:),ALLOCATABLE  ::  arr_vertex
  integer,DIMENSION(:,:),ALLOCATABLE  ::  arr_edge
  integer,DIMENSION(:,:),ALLOCATABLE  ::  arr_cell
  
   integer :: ierr,size,myid
   integer :: Nt,nproc,Nt_all,master
   parameter (nproc= 120)
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! Load input mesh data
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call MPI_Init(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD,myid,ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD,size,ierr)
  master=0
    
!!! load n_vertex,n_vertex,n_cell from fname
     call load_name(fname,n_vertex,n_edge,n_cell)

     allocate(arr_vertex(n_vertex,3),arr_edge(n_edge,2),arr_cell(n_cell,3))

!!!!! load arr_vertex,arr_edge,arr_cell from fname
     call load_gts(fname,n_vertex,n_edge,&
                   n_cell,arr_vertex,arr_edge,arr_cell)
   
write(*,*) myid

if(mod(n_cell,nproc)/=0)then
   write(*,*)'Nt_all must be integer*nprocs. Change nprocs!'
   STOP
else
   write(*,*)'Each cpu calculates',n_cell/nproc,'cells'
end if

  Nt_all=n_cell
  Nt=Nt_all/nproc

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! for all element's center point as op
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    call calc_green_allcell(myid,Nt,arr_vertex,arr_cell,n_vertex,n_cell)
    
    deallocate(arr_vertex,arr_edge,arr_cell) 
 
   call MPI_barrier(MPI_COMM_WORLD,ierr)
   call MPI_finalize(ierr)
end program


subroutine load_name(fname,n_vertex,n_edge,n_cell)
    implicit none

    character(*)               ::  fname
    integer                     ::  i
    integer                     :: n_vertex,n_edge,n_cell

    OPEN(unit=33, FILE=fname)
    read(33, *) n_vertex, n_edge, n_cell
   close(33)
return
end subroutine

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine load_gts(fname,n_vertex,n_edge,n_cell,arr_vertex,arr_edge,arr_cell)
    implicit none
    
    character(*)               ::  fname
    integer                     ::  i
    integer                     :: n_vertex,n_edge,n_cell
    real(8)  :: arr_vertex(n_vertex,3)
    integer  ::  arr_edge(n_edge,2)
    integer  ::  arr_cell(n_cell,3) 
 
    OPEN(unit=10, FILE=fname)
    read(10, *) n_vertex, n_edge, n_cell
    
    write(*,*) ">>> load_gts"
    write(*,*) "    fname   =", fname
    write(*,*) "    n_vertex=", n_vertex
    write(*,*) "    n_edge  =", n_edge
    write(*,*) "    n_cell  =", n_cell
   
!   allocate(arr_vertex(n_vertex,3),arr_edge(n_edge,2),arr_cell(n_cell,3))      

    do i=1, n_vertex
        read(10, *) arr_vertex(i, 1), arr_vertex(i, 2), arr_vertex(i, 3)
        arr_vertex(i, 3)= arr_vertex(i, 3)   
    end do
    
    do i=1, n_edge
        read(10, *) arr_edge(i, 1), arr_edge(i, 2)
    end do
    
    do i=1, n_cell
        read(10, *) arr_cell(i, 1), arr_cell(i, 2), arr_cell(i, 3)
    end do
    
    CLOSE(10)
return
end subroutine

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
real(8) function calc_triangle_area(p1, p2, p3)
    implicit none
    
    real(8)                     ::  p1(3), p2(3), p3(3)
    
    real(8)                     ::  a, b, c, s
    real(8)                     ::  dx, dy, dz
  
    ! a
    dx = p1(1) - p2(1)
    dy = p1(2) - p2(2)
    dz = p1(3) - p2(3)
    a = sqrt(dx**2 + dy**2 + dz**2)
    
    ! b
    dx = p2(1) - p3(1)
    dy = p2(2) - p3(2)
    dz = p2(3) - p3(3)
    b = sqrt(dx**2 + dy**2 + dz**2)
    
    ! c
    dx = p3(1) - p1(1)
    dy = p3(2) - p1(2)
    dz = p3(3) - p1(3)
    c = sqrt(dx**2 + dy**2 + dz**2)
    
    s = (a + b + c) / 2.0
    calc_triangle_area = sqrt(s*(s-a)*(s-b)*(s-c))
end function

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_triangle_centroid(p1, p2, p3, c)
    implicit none
    real(8)                     ::  p1(3), p2(3), p3(3), c(3)

    c(1:3) = (p1(1:3) + p2(1:3) + p3(1:3)) / 3.d0
end subroutine calc_triangle_centroid

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate strain from displacement gradient
!
! Parameters:
!   dg              [in] displacement gradient
!   e               [out] strain tensors
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_strain(dg, e)
    implicit none
    
    real(8)             ::  dg(9), e(9)
    
    e(1) = dg(1)
    e(2) = ( dg(3*1+1) + dg(2) ) / 2.0
    e(3) = ( dg(3) + dg(3*2 + 1) ) / 2.0
    
    e(4) = ( dg(3*1+1) + dg(2) ) / 2.0
    e(5) = dg(5)
    e(6) = ( dg(3*1+3) + dg(3*2+2) ) / 2.0
    
    e(7) = ( dg(3) + dg(3*2+1) ) / 2.0
    e(8) = ( dg(3*1+3) + dg(3*2+2) ) / 2.0
    e(9) = dg(9)
end subroutine 

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate stress tensor from strain
!
! Parameters:
!   e               [in] strain tensor
!   sig             [out] stress tensor
!   l               [in] 
!   miu             [in] 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_stress(e, sig, l, miu)
    implicit none
    
    real(8)             ::  e(9), sig(9), l, miu
    
    sig(1) = l * ( e(1) + e(5) + e(9) ) + 2.0 * miu * e(1)
    sig(2) = 2.0 * miu * e(2)
    sig(3) = 2.0 * miu * e(3)
    
    sig(4) = 2.0 * miu * e(4)
    sig(5) = l * ( e(1) + e(5) + e(9) ) + 2.0 * miu * e(5)
    sig(6) = 2.0 * miu * e(6)
    
    sig(7) = 2.0 * miu * e(7)
    sig(8) = 2.0 * miu * e(8)
    sig(9) = l * ( e(1) + e(5) + e(9) ) + 2.0 * miu * e(9)
end subroutine

subroutine calc_n_stress(e, sig, l_miu)
    implicit none
    
    real(8)             ::  e(9), sig(9), l_miu
 
    sig(1) = l_miu * ( e(1) + e(5) + e(9) ) + 2.d0 * e(1)
    sig(2) = 2.d0 * e(2)
    sig(3) = 2.d0 * e(3)
    
    sig(4) = 2.d0 * e(4)
    sig(5) = ( e(1) + e(5) + e(9) ) + 2.d0 * e(5)
    sig(6) = 2.d0 * e(6)
    
    sig(7) = 2.d0 * e(7)
    sig(8) = 2.d0 * e(8)
    sig(9) = (e(1) + e(5) + e(9)) + 2.d0 * e(9)
end subroutine calc_n_stress


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate transformered stress tensor
!
! Parameters:
!   sig             [in] input stress tensor
!   v               [in] new axis & old axis's cos value array
!   s               [out] output new stress tensor
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine stress_transformation(sig, v, s)
  implicit none

  real(8)             ::  sig(9), &       ! input stress tensor
                          v(9), &         ! new axis & old axis ' cos value
                          s(9)            ! output new stress tensor
                            
  integer             ::  i, j, id, jd
    
  do i=1, 9
    s(i) = 0.0D0
  end do
    
  do id=1, 3
    do jd=1, 3          
      do i=1, 3
        do j=1, 3
          s((id-1)*3+jd) = s((id-1)*3 + jd) + &
                  v((id-1)*3+i) * v((jd-1)*3+j) * sig((i-1)*3+j)
        end do
      end do
    end do
  end do
end subroutine 


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate cos value between two coordinate's axes
!
! Parameters:
!   c1              [in] old coordinate
!   c2              [in] new coordinate
!   v               [out] cos value of coodinate axes
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_coord_cos(c1, c2, v)
  implicit none

  real(8)             ::  c1(3, 3), &     ! old coordinate
                          c2(3, 3)        ! new coordinate
  real(8)             ::  v(9)
  
  integer             ::  i, j
  real(8)             ::  f1, f2, av1, av2
  
  do j=1, 3
    do i=1, 3
      f1  = c1(i, 1) * c2(j, 1) + c1(i, 2) * c2(j, 2) + c1(i, 3) * c2(j, 3)

      av1 = sqrt(c1(i, 1)**2 + c1(i, 2)**2 + c1(i, 3)**2)
      av2 = sqrt(c2(j, 1)**2 + c2(j, 2)**2 + c2(j, 3)**2)
      f2  = av1 * av2
            
      v((j-1)*3 + i) = f1 / f2
    end do
  end do
end subroutine calc_coord_cos

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate vector's product
!
! Parameters:
!   p1              [in] vector 1
!   p2              [in] vector 2
!   p               [in] normal vector
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine vector_product(p1, p2, p)
  implicit none

  real(8)                     ::  p1(3), p2(3), p(3)
    
  p(1) = p1(2)*p2(3) - p1(3)*p2(2)
  p(2) = p1(3)*p2(1) - p1(1)*p2(3)
  p(3) = p1(1)*p2(2) - p1(2)*p2(1)
end subroutine vector_product

subroutine unit_vect(v)
  implicit none
  
  real(8)                   :: v(3)
  real(8)                   :: l

  l = sqrt(v(1)**2 + v(2)**2 + v(3)**2)
  v(1) = v(1) / l
  v(2) = v(2) / l
  v(3) = v(3) / l
end subroutine


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate given trianle's normal vector
!
! Parameters:
!   p1              [in] triangle vertex 1
!   p2              [in] triangle vertex 2
!   p3              [in] triangle vertex 3
!   p               [out] normal vector
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine tri_normal_vect(p1, p2, p3, p)
  implicit none
    
  real(8)                     ::  p1(3), p2(3), p3(3), p(3)
  real(8)                     ::  v1(3), v2(3)
    
  v1(1:3) = p1(1:3) - p2(1:3)
  v2(1:3) = p2(1:3) - p3(1:3)
    
  call vector_product(v1, v2, p)
end subroutine

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate special parameters (ss, ds, op)
!
! Parameters:
!   v1              [in] triangle vertex 1
!   v2              [in] triangle vertex 2
!   v3              [in] triangle vertex 3
!   v_pl            [in] input direction vector
!   ss              [out] ss scale parameter (for hor vector)
!   ds              [out] ds scale parameter (for downdip vector)
!   op              [out] op scale parameter (for perp vector)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_ss_ds(v1, v2, v3, v_pl, ss, ds, op)
 use m_calc_green 
 implicit none
    
  real(8)                     ::  v1(3), v2(3), v3(3)
  real(8)                     ::  v_pl(3)
  real(8)                     ::  ss, ds, op
  
  real(8)                     ::  vpl, vpl0, theta
  real(8)                     ::  nv(3)
  real(8)                     ::  x, y, z
    
  real(8)                     ::  a, b
  real(8)                     ::  rl,a11,a12,a13,gamma
  integer                     ::  i
    
  ! get triangle's normal vector
  call tri_normal_vect(v1, v2, v3, nv)

  if ( nv(3) .lt. 0 ) then
    do i=1, 3
      nv(i) = -nv(i)
    end do
  end if

  rl=(vpl1**2+vpl2**2)+(nv(1)*vpl1+nv(2)*vpl2)**2/nv(3)**2
  rl=1.d0/rl
  rl=sqrt(rl)
  gamma=-(nv(1)*vpl1+nv(2)*vpl2)*rl/nv(3)

  a11 = vpl1*rl
  a12 = vpl2*rl
  a13 = gamma

  ! calc ss, ds
  ss=(nv(2)*a11-nv(1)*a12)/sqrt(nv(1)**2+nv(2)**2)
  ds=sqrt(nv(1)**2+nv(2)**2-(nv(2)*a11-nv(1)*a12)**2)
  ds=ds/sqrt(nv(1)**2+nv(2)**2)
  op=0.d0
    
end subroutine calc_ss_ds

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate local coordinate
!
! Parameters:
!   v1              [in] triangle vertex 1
!   v2              [in] triangle vertex 2
!   v3              [in] triangle vertex 3
!   v_pl            [in] input direction vector
!   c               [out] local coordinate
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_local_coordinate2(v1, v2, v3, v_pl, c)
 use m_calc_green  
  implicit none
    
    real(8)                     ::  v1(3), v2(3), v3(3)
    real(8)                     ::  v_pl(3)
    real(8)                     ::  c(3, 3)
    
    real(8)                     ::  nv(3)
    real(8)                     ::  ss, ds, op
    real(8)                     ::  a1(3), a2(3), a3(3)
    real(8)                     ::  rl,gamma
    integer                     ::  i
    
    ! get ss, ds, op
    call calc_ss_ds(v1, v2, v3, v_pl, ss, ds, op)
    
    ! get triangle's normal vector
    call tri_normal_vect(v1, v2, v3, nv)
    
    if( nv(3) .lt. 0 ) then
       do i=1, 3
          nv(i) = -nv(i)
       end do
    end if

    !write(6,*) "nv(3)check",nv(3)
    ! calc axis 1
    a1(1) = ss
    a1(2) = ds
    
    a3(1:3) = nv(1:3)
    
    a1(3) = - ( a3(1)*a1(1) + a3(2)*a1(2) ) / a3(3)
        
    rl=(vpl1**2+vpl2**2)+(nv(1)*vpl1+nv(2)*vpl2)**2/nv(3)**2
    rl=1.d0/rl
    rl=sqrt(rl)
    gamma=-(nv(1)*vpl1+nv(2)*vpl2)*rl/nv(3)

    !a1(1) = vpl1*rl
    !a1(2) = vpl2*rl
    !a1(3) = gamma

     a1(1) = -nv(2)/sqrt(nv(1)**2+nv(2)**2)
     a1(2) = nv(1)/sqrt(nv(1)**2+nv(2)**2)
     a1(3) = 0.0

    ! calc axis 2
    call vector_product(a1, a3, a2)
    if ( a3(3) .lt. 0 ) then
      a3(1:3) = a3(1:3)
    end if


    call unit_vect(a1)
    call unit_vect(a2)
    call unit_vect(a3)
    
    c(1, 1:3) = a1(1:3)
    c(2, 1:3) = a2(1:3)
    c(3, 1:3) = a3(1:3)

end subroutine


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine calc_green_allcell(myid,Nt,arr_vertex,arr_cell,n_vertex,n_cell)
 use m_calc_green,only: parm_nu,parm_l,parm_miu,vpl1,vpl2,PI,ZERO 
 implicit none
    
  real(8) ::       xo(3), tridlc(9), burg(3), u(3), t(9)
  real(8) ::             utmp(3), ttmp(9)
  real(8) ::                tri(3,4)
  real(8) ::               usum(3),tsum(9)
  real(8) ::                ss, ds, op
  
  integer             :: myid, i, j, k,Nt,n_cell,n_vertex
  integer             ::  vi(3), vj(3)
  real(8)             ::  p1(3), p2(3), p3(3), c(3), co(3)
  real(8)             ::  e(9), sig(9), sig_local(9), sig_local2(9)
  real(8)             ::  sig33(3,3)
  real(8)             ::  tt(9)
  real(8)             ::  vpl(3)
  real(8)             ::  ss_, ds_, op_
  character(20)       ::  fname_index
  character(20) ::        cTemp
  real(8)             ::  d, r
  real(8)             ::  l_miu, s_out
  
  real(8)             ::  c_global(3, 3), &
                          c_local(3, 3),  c_local_v(9), &
                          c_local2(3, 3), c_local_v2(9)
  real(8),allocatable :: arr_co(:,:),arr_trid(:,:), &
                         arr_cl_v2(:,:,:), slip_vector(:,:)
  real(8),allocatable :: arr_out(:,:),a_ss(:),a_ds(:),a_op(:), &
                         c_ss(:),c_ds(:),c_op(:),slip_r(:),arr_out_ns(:,:)
  real(8)             :: arr_vertex(n_vertex,3)
  integer             :: arr_cell(n_cell,3)

  vpl(1:3) = 1.d0
  l_miu = parm_l/parm_miu

  ss = 0.d0
  ds = 0.d0
  op = 0.d0
    
  ! global coordinate
  c_global(:,:) = 0.d0
  do i=1,3
    c_global(i,i) =1.d0
  end do

  ! output cell, node number
  allocate(arr_co(3,n_cell),arr_trid(9,n_cell),arr_cl_v2(3,3,n_cell), &
          slip_vector(3,n_cell))
  allocate(a_ss(n_cell),a_ds(n_cell),a_op(n_cell),c_ss(n_cell),c_ds(n_cell), &
          c_op(n_cell),slip_r(n_cell))
  allocate(arr_out(Nt,n_cell))  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  allocate(arr_out_ns(Nt,n_cell))
  ! save each cell's center point
  open(222,file='local_coordinate.txt',form='formatted',access='stream') 
  open(333,file='slip_ratio.txt',form='formatted',access='stream')
  open(220,file='slip_vector.txt',form='formatted',access='stream')
  do j=1, n_cell
    vj(1:3) = arr_cell(j,1:3)
    p1(1:3) = arr_vertex(vj(1),1:3)
    p2(1:3) = arr_vertex(vj(2),1:3)
    p3(1:3) = arr_vertex(vj(3),1:3)
    call calc_triangle_centroid(p1, p2, p3, co)
    arr_co(1:3,j) = co(1:3)
    arr_trid(1:3,j) = p1(1:3)
    arr_trid(4:6,j) = p2(1:3)
    arr_trid(7:9,j) = p3(1:3)
    call calc_local_coordinate2(p1, p2, p3, vpl, c_local2)
    call calc_coord_cos(c_global, c_local2, c_local_v2)
    arr_cl_v2(1:3,1,j) = c_local_v2(1:3)
    arr_cl_v2(1:3,2,j) = c_local_v2(4:6)
    arr_cl_v2(1:3,3,j) = c_local_v2(7:9)

   ! calculate the slip ratio between strike and dip 
!    if (arr_co(2,j) .lt. -47000) then
!       slip_r(j) = 0.35
!    else if (arr_co(2,j) .gt. 133000) then
!       slip_r(j) = 1.1
!    else
!       slip_r(j) = 0.06606 * arr_co(2,j) / 1000 - 1.395 
!       slip_r(j) = 1.0
!    end if
! r0=0.3,r1=0.8,r2=1.1, Ym1=-28km is the segmenting point, [Ym0 Ym2]=[-97 185]
    if (arr_co(2,j).lt. -28000) then
       slip_r(j)=0.0072*1e-3*arr_co(2,j) + 1.0029
      else 
       slip_r(j)=0.0014*1e-3*arr_co(2,j) + 0.8394
    end if
   !specify a uniform slip_r along strike
    !  slip_r(j) = 1.9

   ! write(333,*) arr_co(2,j), slip_r(j)
   ! calculate slip vector for each cell according to ss and ds 
    c_ss(j) = slip_r(j)/sqrt(slip_r(j)**2+1)
    c_ds(j) = -1/sqrt(slip_r(j)**2+1)
    slip_vector(1:3,j) = c_ss(j) * c_local_v2(1:3) +(-1.d0)* c_ds(j) * c_local_v2(4:6)    

    write(333,*) arr_co(2,j),slip_r(j), c_ss(j),c_ds(j)
    write(220,*) slip_vector(1,j),slip_vector(2,j),slip_vector(3,j)
    write(222,*)  c_local_v2(1),c_local_v2(2),c_local_v2(3)
    write(222,*)  c_local_v2(4),c_local_v2(5),c_local_v2(6)
    write(222,*)  c_local_v2(7),c_local_v2(8),c_local_v2(9)
                 
    call calc_ss_ds(arr_trid(1:3,j), arr_trid(4:6,j), arr_trid(7:9,j), vpl, ss, ds, op)
    a_ss(j) = ss
    a_ds(j) = ds
    a_op(j) = op
    arr_out(:,j) = 0.d0

  end do

  close(222)
  close(333)

  write(6,*) "Start parallel loop"
     ! for each triangle element
  do j=(myid)*Nt+1,(myid)*Nt+Nt
    write(6,*)j
    do i=1, n_cell
      ! calculate strain gradients, in dstuart the argument is observation point 
      call dstuart (parm_nu,arr_co(:,j),arr_trid(:,i),c_ss(i),c_ds(i),0.d0, u, t)
            
      ! calc stress
      sig33(3,3) = l_miu * ( t(1) + t(5) + t(9) ) 
      sig33(1,1) = sig33(3,3) + 2.d0 * t(1)
      sig33(2,2) = sig33(3,3) + 2.d0 * t(5)
      sig33(3,3) = sig33(3,3) + 2.d0 * t(9)

      sig33(2,1) = t(4) + t(2)
      sig33(3,1) = t(3) + t(7)
      sig33(3,2) = t(6) + t(8)

      sig33(1,2) = sig33(2,1)
      sig33(1,3) = sig33(3,1)
      sig33(2,3) = sig33(3,2)

      ! calc local stress  in Bar (0.1Mpa)
      arr_out(j-(myid)*Nt,i) =  parm_miu/100 * dot_product(slip_vector(1:3,j),matmul(sig33(:,:),arr_cl_v2(:,3,j)))
      arr_out_ns(j-(myid)*Nt,i) =  parm_miu/100 * dot_product(arr_cl_v2(:,3,j),matmul(sig33(:,:),arr_cl_v2(:,3,j)))

    end do
  end do
  
 write(cTemp,*) myid
 write(*,*) cTemp

  open(14,file='trigreen_'//trim(adjustl(cTemp))//'.bin', form='unformatted',access='stream')
  open(15,file='trigreen_ns_'//trim(adjustl(cTemp))//'.bin', form='unformatted',access='stream')
!  write(14,*) n_cell, n_vertex

 if(myid==0)then 
 open(22,file='position.bin',form='unformatted',access='stream')
! open(33,file='norVec.txt',form='formatted',access='stream') 
  do j=1,n_cell
    write(22) arr_co(1,j), arr_co(2,j), arr_co(3,j)
 !   write(33,*) arr_cl_v2(3,3,j)
  end do
close(22)
 end if

do i=1,Nt
 do j=1,n_cell
  write(14) arr_out(i,j)
  write(15) arr_out_ns(i,j)
end do
end do
close(14)
close(15)
 deallocate (arr_co,arr_trid,arr_cl_v2,slip_vector)
 deallocate (a_ss,a_ds,a_op,c_ss,c_ds,c_op,slip_r)
 deallocate (arr_out) 
 deallocate (arr_out_ns)
return 
end subroutine




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! main procedure
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
