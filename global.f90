module global
    !-------------------------------------------------------------------
    ! The global module holds global variables
    !
    ! Global variables include string buffer lengths, file unit lengths,
    ! etc.
    !-------------------------------------------------------------------

    implicit none
    ! String buffer lengths
    integer, parameter :: FILE_NAME_LENGTH = 32
    integer, parameter :: SCHEME_NAME_LENGTH = 16
    integer, parameter :: INTERPOLANT_NAME_LENGTH = 20
    integer, parameter :: DESCRIPTION_STRING_LENGTH = 64
    integer, parameter :: STRING_BUFFER_LENGTH = 128
    integer, parameter :: ERROR_MESSAGE_LENGTH = 256
    ! File unit numbers
    integer, parameter :: CONFIG_FILE_UNIT = 1
    integer, parameter :: GRID_FILE_UNIT = 2
    integer, parameter :: STATE_FILE_UNIT = 10
    integer, parameter :: OUT_FILE_UNIT = 20
    integer, parameter :: RESNORM_FILE_UNIT = 21
    integer, parameter :: IB_FILE_UNIT = 22
    integer, parameter :: MASS_RESIDUE_FILE_UNIT = 23

end module global
