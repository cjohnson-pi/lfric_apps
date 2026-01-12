!-----------------------------------------------------------------------------
! (C) Crown copyright 2021 Met Office. All rights reserved.
! The file LICENCE, distributed with this code, contains details of the terms
! under which the code may be used.
!-----------------------------------------------------------------------------
!> @brief Initialise, define and finalise the adjoint fields.

module adjoint_model_data_mod

  use constants_mod,                  only : i_def, r_def, l_def, str_def
  use pure_abstract_field_mod,        only : pure_abstract_field_type
  use field_array_mod,                only : field_array_type
  use field_mod,                      only : field_type
  use field_collection_mod,           only : field_collection_type
  use function_space_mod,             only : function_space_type
  use function_space_collection_mod,  only : function_space_collection
  use fs_continuity_mod,              only : W2, W3, WTheta, W2h
  use driver_modeldb_mod,             only : modeldb_type
  use gungho_time_axes_mod,           only : gungho_time_axes_type, &
                                             get_time_axes_from_collection
  use init_time_axis_mod,             only : setup_field
  use initialization_config_mod,      only : ls_option,           &
                                             ls_option_analytic,  &
                                             ls_option_file, &
                                             zero_w2v_wind
  use lfric_xios_time_axis_mod,       only : time_axis_type
  use lfric_xios_read_mod,            only : read_field_time_var
  use linear_data_algorithm_mod,      only : linear_copy_model_to_ls,  &
                                             linear_init_pert_random,  &
                                             init_ls_file_alg,         &
                                             linear_init_reference_ls, &
                                             linear_init_pert_analytical, &
                                             init_ls_file_alg,            &
                                             linear_init_pert_zero

  use linear_config_mod,              only : pert_option,          &
                                             pert_option_analytic, &
                                             pert_option_random,   &
                                             pert_option_file,     &
                                             pert_option_zero,     &
                                             ls_read_w2h
  use linked_list_mod,                only : linked_list_type
  use log_mod,                        only : log_event,         &
                                             log_scratch_space, &
                                             LOG_LEVEL_INFO,    &
                                             LOG_LEVEL_ERROR
  use mesh_mod,                       only : mesh_type
  use moist_dyn_mod,                  only : num_moist_factors
  use moist_dyn_factors_alg_mod,      only : moist_dyn_factors_alg
  use mr_indices_mod,                 only : nummr, &
                                             mr_names
  use adjoint_map_fd_alg_mod,         only : adjoint_map_fd_to_prognostics
  use set_any_dof_alg_mod,            only : set_any_dof_alg
  use reference_element_mod,          only : T
  use io_config_mod,                  only : checkpoint_read

  implicit none

  private
  public :: adjoint_init_pert

contains

  !> @brief   Define the initial perturbation values.
  !> @details Define the initial perturbation - currently from random data
  !> @param[in]    mesh      The current 3d mesh
  !> @param[in]    twod_mesh The current 2d mesh
  !> @param[inout] modeldb   The working data set for a model run
  subroutine adjoint_init_pert( mesh, twod_mesh, modeldb )

    implicit none

    type( mesh_type ), pointer, intent(in) :: mesh
    type( mesh_type ), pointer, intent(in) :: twod_mesh

    type( modeldb_type ), target, intent(inout) :: modeldb
    type(field_collection_type), pointer :: prognostic_fields
    type( field_type ),          pointer :: u

    select case( pert_option )

      case( pert_option_random )

        call linear_init_pert_random( modeldb )

      case( pert_option_analytic )

        call linear_init_pert_analytical( mesh,      &
                                          twod_mesh, &
                                          modeldb )

      case( pert_option_file )

        call adjoint_map_fd_to_prognostics( modeldb )

      case( pert_option_zero )

        call linear_init_pert_zero( modeldb )

      case default

        call log_event("This pert_option not available", LOG_LEVEL_ERROR)

    end select

    if (.not. checkpoint_read .and. zero_w2v_wind) then
      prognostic_fields => modeldb%fields%get_field_collection(&
                                          "prognostic_fields")
      call prognostic_fields%get_field('u', u)
      call set_any_dof_alg(u, T, 0.0_r_def)
    end if

  end subroutine adjoint_init_pert

end module adjoint_model_data_mod
