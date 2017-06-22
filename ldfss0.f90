module ldfss0
    !-------------------------------------------------------------------
    ! LDFSS is a class of flux-splitting schemes
    !-------------------------------------------------------------------

    use utils, only: alloc, dealloc, dmsg
    use grid, only: imx, jmx
    use geometry, only: xnx, xny, ynx, yny, xA, yA
    use face_interpolant, only: x_pressure_left, x_pressure_right, &
                y_pressure_left, y_pressure_right, &
                x_density_left, x_density_right, &
                y_density_left, y_density_right
    use van_leer, only: setup_scheme_VL => setup_scheme, &
            destroy_scheme_VL => destroy_scheme, &
            get_residue_VL => get_residue, &
            compute_face_quantities_VL => compute_face_quantities, &
            compute_fluxes_VL => compute_fluxes, &
            x_M_perp_left, x_M_perp_right, &
            y_M_perp_left, y_M_perp_right, &
            x_beta_left, x_beta_right, &
            y_beta_left, y_beta_right, &
            x_c_plus, x_c_minus, &
            y_c_plus, y_c_minus, &
            x_sound_speed_avg, y_sound_speed_avg, &
            F_van_leer => F, G_van_leer => G

    implicit none
    private

    real, dimension(:, :), allocatable :: x_M_ldfss, x_M_plus_ldfss, x_M_minus_ldfss
    real, dimension(:, :), allocatable :: y_M_ldfss, y_M_plus_ldfss, y_M_minus_ldfss
    real, public, dimension(:, :, :), pointer :: F, G

    ! Public methods
    public :: setup_scheme
    public :: destroy_scheme
    public :: compute_face_quantities
    public :: compute_fluxes
    public :: get_residue

    contains

        subroutine setup_scheme()

            implicit none

            call dmsg(1, 'ldfss', 'setup_scheme')

            call setup_scheme_VL()
            F => F_van_leer
            G => G_van_leer

            call alloc(x_M_ldfss, 1, imx, 1, jmx-1, &
                    errmsg='Error: Unable to allocate memory for x_M_ldfss.')
            call alloc(x_M_plus_ldfss, 1, imx, 1, jmx-1, &
                    errmsg='Error: Unable to allocate memory for x_M_plus_ldfss.')
            call alloc(x_M_minus_ldfss, 1, imx, 1, jmx-1, &
                    errmsg='Error: Unable to allocate memory for x_M_minus_ldfss.')
            call alloc(y_M_ldfss, 1, imx-1, 1, jmx, &
                    errmsg='Error: Unable to allocate memory for y_M_ldfss.')
            call alloc(y_M_plus_ldfss, 1, imx, 1, jmx-1, &
                    errmsg='Error: Unable to allocate memory for y_M_plus_ldfss.')
            call alloc(y_M_minus_ldfss, 1, imx, 1, jmx-1, &
                    errmsg='Error: Unable to allocate memory for y_M_minus_ldfss.')

        end subroutine setup_scheme

        subroutine destroy_scheme()

            implicit none

            call dmsg(1, 'ldfss', 'destroy_scheme')

            call dealloc(x_M_ldfss)
            call dealloc(x_M_plus_ldfss)
            call dealloc(x_M_minus_ldfss)
            call dealloc(y_M_ldfss)
            call dealloc(y_M_plus_ldfss)
            call dealloc(y_M_minus_ldfss)
            call destroy_scheme_VL()

        end subroutine destroy_scheme

        subroutine ldfss_modify_xi_face_quantities()
            !-----------------------------------------------------------
            ! Update the Van-Leer computed speeds: x_c_plus & x_c_minus
            !-----------------------------------------------------------

            implicit none

            x_M_ldfss = 0.25 * x_beta_left * x_beta_right * &
                    (sqrt((x_M_perp_left ** 2. + x_M_perp_right ** 2.) * 0.5) &
                    - 1) ** 2.
            x_M_plus_ldfss = x_M_ldfss * &
                            (1 - (x_pressure_left - x_pressure_right) / &
                                 (2 * x_density_left * (x_sound_speed_avg ** 2)))
            x_M_minus_ldfss = x_M_ldfss * &
                            (1 - (x_pressure_left - x_pressure_right) / &
                                 (2 * x_density_right * (x_sound_speed_avg ** 2)))
            x_c_plus = x_c_plus - x_M_plus_ldfss
            x_c_minus = x_c_minus + x_M_minus_ldfss

        end subroutine ldfss_modify_xi_face_quantities

        subroutine ldfss_modify_eta_face_quantities()
            !-----------------------------------------------------------
            ! Update the Van-Leer computed speeds: y_c_plus & y_c_minus
            !-----------------------------------------------------------

            implicit none

            y_M_ldfss = 0.25 * y_beta_left * y_beta_right * &
                    (sqrt((y_M_perp_left ** 2. + y_M_perp_right ** 2.) * 0.5) &
                    - 1) ** 2.
            y_M_plus_ldfss = y_M_ldfss * &
                            (1 - (y_pressure_left - y_pressure_right) / &
                                 (2 * y_density_left * (y_sound_speed_avg ** 2)))
            y_M_minus_ldfss = y_M_ldfss * &
                            (1 - (y_pressure_left - y_pressure_right) / &
                                 (2 * y_density_right * (y_sound_speed_avg ** 2)))
            y_c_plus = y_c_plus - y_M_plus_ldfss
            y_c_minus = y_c_minus + y_M_minus_ldfss

        end subroutine ldfss_modify_eta_face_quantities

        subroutine compute_face_quantities()

            implicit none

            call compute_face_quantities_VL()
            
            ! Update the face variables according to the LDFSS(0) specs
            call ldfss_modify_xi_face_quantities()
            call ldfss_modify_eta_face_quantities()

        end subroutine compute_face_quantities

        subroutine compute_fluxes()
        
            implicit none

            call compute_fluxes_VL()

        end subroutine compute_fluxes

        function get_residue() result(residue)
            !-----------------------------------------------------------
            ! Return the LDFSS(0) residue
            !-----------------------------------------------------------

            implicit none
            real, dimension(imx-1, jmx-1, 4) :: residue

            residue = get_residue_VL()

        end function get_residue

end module ldfss0
