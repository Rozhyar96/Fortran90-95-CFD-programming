!!---FULLY DEVELOPED FLOW IN RECTANGULAR DUCT WITH A CONSTANT STREAMWISE PRESSURE GRADIANT---!!
!!---SOLVED BY L.G.S METHOD---!!

PROGRAM LGS_METHOD
IMPLICIT NONE
REAL,DIMENSION(:,:,:),ALLOCATABLE::USTAR!---NON-DIMENSIONAL VELOCITY MATRIX
REAL,DIMENSION(:,:),ALLOCATABLE::UDIM_F,UNONDIM_F !---DIMENSIONAL & NON-DIMENSIONAL FINAL VELOCITY
REAL,DIMENSION(:),ALLOCATABLE::YSTAR,ZSTAR,YA,ZA !---DEFINING X&Y SSTAR , AND NORMAL AXIS
REAL,DIMENSION(:),ALLOCATABLE::UDIM,UNONDIM !---DIEMNSIONAL AND NON-DIMENSIONAL INITIAL VELOCITY
!!---VARIABLE OF TDM---!!
REAL,DIMENSION(:,:),ALLOCATABLE::A
REAL,DIMENSION(:),ALLOCATABLE::B,X
INTEGER::N
REAL,DIMENSION(:),ALLOCATABLE::MAINDIACOMP,UPPERDIACOMP,LOWERDIACOMP,RHO,GAMMA
REAL,DIMENSION(41,7)::PART1UDIM_F
REAL,DIMENSION(41,7)::PART2UDIM_F
REAL,DIMENSION(41,7)::PART3UDIM_F
REAL,DIMENSION(41,7)::PART4UDIM_F
REAL,DIMENSION(41,7)::PART5UDIM_F
REAL,DIMENSION(41,7)::PART6UDIM_F
REAL,DIMENSION(41,7)::PART7UDIM_F
REAL,DIMENSION(41,7)::PART8UDIM_F
REAL,DIMENSION(41,5)::PART9UDIM_F

!!---DEFINING PARAMETERS---!!
REAL::dYstar,dZstar,dZA,dYA,BETA
INTEGER::JM,KM,i,j,ITERATION
REAL::L,H,MU,dP,R
REAL::ERRORMAX,SUM_1,SUM_2
REAL::UAVG !--AVERAGE VELOCITY USED AS FIRST GUESS
!!---PHYSCAL PARAMETES---!!
JM= 61
KM= 41
ERRORMAX= 0.00001
MU= 0.4 !--PA.S
L= 1.50!--M
H= 1.00 !--M
dP= -10.00 !--PA/M
dYA= (2*L)/(JM-1)
dZA= (2*H)/(KM-1)
dYstar= dYA/L
dZstar= dZA/L
BETA= dZstar/dYstar
!!---SINCE OUR PROBLEM MENTION THAT WE HAVE RECTANGULAR PIPE SO  WE ARE GONNA USE HYDRULIC DIAMETER---!!
R= 0.5*((2*2*H*2*L)/((2*H)+(2*L)))
UAVG= -((R**2)/(8*MU))*(dP)
PRINT*,UAVG,R,BETA

!!---DEFINING MATRIXS---!!
ALLOCATE(USTAR(KM,JM,2))
ALLOCATE(Ystar(JM))
ALLOCATE(Zstar(KM))
ALLOCATE(YA(JM))
ALLOCATE(ZA(KM))
ALLOCATE(UDIM_F(KM,JM))
ALLOCATE(UNONDIM_F(KM,JM))
ALLOCATE(UDIM(KM))
ALLOCATE(UNONDIM(KM))

!!--AXIS DEFINITION--!!
YA(((JM+1)/2))=0.0
DO i=1,((JM-1)/2)
  YA(((JM+1)/2)+i)= i*dYA
  YA(((JM+1)/2)-i)= -i*dYA
END DO
DO i=1,JM
  YSTAR(i)=YA(i)/L
END DO
ZA(((KM+1)/2))=0.0
DO j=1,((KM-1)/2)
  ZA(((KM+1)/2)+j)= j*dZA
  ZA(((KM+1)/2)-j)= -j*dZA
END DO
DO j=1,KM
  ZSTAR(j)=ZA(j)/L
END DO

!!---------INITIAL GEUSS------------!!
DO i=1,KM
  UDIM(i)=UAVG
ENDDO
DO i=1,KM
  UNONDIM(i)=(UAVG*MU)/((L**2)*(-dP))
ENDDO
DO i=1,KM
  USTAR(i,:,1)=UNONDIM(i)
ENDDO
PRINT*,USTAR(21,31,1)
!!---BOUNDRY CONDITIONS----!!
DO i=1,KM
  USTAR(i,1,1)=0.0
  USTAR(i,JM,1)=0.0
  USTAR(i,1,2)=0.0
  USTAR(i,JM,2)=0.0
ENDDO
DO j=1,JM
  USTAR(1,j,1)=0.0
  USTAR(KM,j,1)=0.0
  USTAR(1,j,2)=0.0
  USTAR(KM,j,2)=0.0
ENDDO

SUM_1=0.0
DO i=1,KM
  DO j=1,JM
    SUM_1=SUM_1+USTAR(i,j,1)
  ENDDO
ENDDO

N=JM-2
ALLOCATE (A(N,N))
ALLOCATE (B(N))
ALLOCATE (X(N))
ALLOCATE (MAINDIACOMP(N))
ALLOCATE (UPPERDIACOMP(N-1))
ALLOCATE (LOWERDIACOMP(N))
ALLOCATE (RHO(N))
ALLOCATE (GAMMA(N-1))

DO i=1,N
  DO j=1,N
    A(i,j)=0.0
  ENDDO
ENDDO
DO i=1,N
  A(i,i)= -2*(1+BETA**2)
ENDDO
DO i=1,N-1
  A(i,i+1)=1.0
ENDDO
DO i=2,N
  A(i,i-1)=1.0
ENDDO
DO i=1,N
  MAINDIACOMP(i)=A(i,i)
ENDDO
DO i=1,N-1
  UPPERDIACOMP(i)=A(i,i+1)
ENDDO
LOWERDIACOMP(1)=0.0
DO i=2,N
  LOWERDIACOMP(i)=A(i,i-1)
ENDDO
!!---BUILDING THE KNOW RHS MATRIX B AND SOLVE TDM---!!
SUM_2=0.0
ITERATION=0.0
DO
  DO i=2,KM-1
    DO j=2,JM-1
      B(j-1)= -USTAR(i+1,j,1)-USTAR(i-1,j,2)-dYSTAR**2
    ENDDO
    GAMMA(1)=UPPERDIACOMP(1)/MAINDIACOMP(1)
    DO j=2,N-1
      GAMMA(j)=UPPERDIACOMP(j)/(MAINDIACOMP(j)-(LOWERDIACOMP(j)*GAMMA(j-1)))
    ENDDO
    RHO(1)=B(1)/MAINDIACOMP(1)
    DO j=2,N
      RHO(j)=(B(j)-(LOWERDIACOMP(j)*RHO(j-1)))/(MAINDIACOMP(j)-(LOWERDIACOMP(j)*GAMMA(j-1)))
    ENDDO
    X(N)=RHO(N)
    DO j=N-1,1,-1
      X(j)=RHO(j)-(GAMMA(j)*X(j+1))
    ENDDO
    DO j=2,JM-1
      USTAR(i,j,2)=X(j-1)
    ENDDO
  ENDDO
  DO i=2,KM-1
    DO j= 2,JM-1
      SUM_2=SUM_2+USTAR(i,j,2)
    ENDDO
  ENDDO
  IF (ABS(SUM_1 - SUM_2) > ERRORMAX )THEN
    ITERATION=ITERATION+1
    PRINT*,ITERATION
    SUM_1=SUM_2
    DO i=2,KM-1
      DO j= 2,JM-1
        USTAR(i,j,1)=USTAR(i,j,2)
      ENDDO
    ENDDO
  ELSE
     DEALLOCATE (A)
     DEALLOCATE (B)
     DEALLOCATE (X)
     DEALLOCATE (MAINDIACOMP)
     DEALLOCATE (UPPERDIACOMP)
     DEALLOCATE (LOWERDIACOMP)
     DEALLOCATE (RHO)
     DEALLOCATE (GAMMA)
     EXIT
  ENDIF

ENDDO
   
!--LAST PART_UDIM AND U NONDIM MATRIX--!
DO j=1,KM
  DO i= 1,JM
    UNONDIM_F(j,i)=USTAR(j,i,2)
  ENDDO
ENDDO
PRINT*,UNONDIM_F(21,31)
DO j=1,KM
  DO i=1,JM
    UDIM_F(j,i)= (UNONDIM_F(j,i))*(((L**2)*(-dP))/MU)
  END DO
END DO
PRINT*,UDIM_F(21,31)

!--EXPORTING DATA--!
DO i=1,KM
  DO j=1,7
    PART1UDIM_F(i,j)=UDIM_F(i,j)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART2UDIM_F(i,j)=UDIM_F(i,j+7)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART3UDIM_F(i,j)=UDIM_F(i,j+14)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART4UDIM_F(i,j)=UDIM_F(i,j+21)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART5UDIM_F(i,j)=UDIM_F(i,j+27)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART6UDIM_F(i,j)=UDIM_F(i,j+35)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART7UDIM_F(i,j)=UDIM_F(i,j+42)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,7
    PART8UDIM_F(i,j)=UDIM_F(i,j+49)
  ENDDO
ENDDO

DO i=1,KM
  DO j=1,5
    PART9UDIM_F(i,j)=UDIM_F(i,j+56)
  ENDDO
ENDDO

OPEN(UNIT=12,FILE="DUCT_PART_1.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART1UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_2.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART2UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_3.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART3UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_4.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART4UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_5.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART5UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_6.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART6UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_7.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART7UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_8.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART8UDIM_F(i,j),j=1,7)
END DO

OPEN(UNIT=12,FILE="DUCT_PART_9.TXT",ACTION="WRITE",STATUS="REPLACE")
DO i=1,KM
  WRITE(12,*)(PART9UDIM_F(i,j),j=1,5)
END DO


END PROGRAM