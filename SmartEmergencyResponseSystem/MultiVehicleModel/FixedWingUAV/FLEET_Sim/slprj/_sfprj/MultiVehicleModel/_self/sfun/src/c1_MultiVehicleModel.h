#ifndef __c1_MultiVehicleModel_h__
#define __c1_MultiVehicleModel_h__

/* Include files */
#include "sfc_sf.h"
#include "sfc_mex.h"
#include "rtwtypes.h"
#include "multiword_types.h"

/* Type Definitions */
#ifndef typedef_SFc1_MultiVehicleModelInstanceStruct
#define typedef_SFc1_MultiVehicleModelInstanceStruct

typedef struct {
  SimStruct *S;
  ChartInfoStruct chartInfo;
  uint32_T chartNumber;
  uint32_T instanceNumber;
  int32_T c1_sfEvent;
  boolean_T c1_isStable;
  boolean_T c1_doneDoubleBufferReInit;
  uint8_T c1_is_active_c1_MultiVehicleModel;
  real_T c1_wpointer;
  boolean_T c1_wpointer_not_empty;
  real_T c1_mode;
  boolean_T c1_mode_not_empty;
  real_T c1_wpointAux[4];
  boolean_T c1_wpointAux_not_empty;
} SFc1_MultiVehicleModelInstanceStruct;

#endif                                 /*typedef_SFc1_MultiVehicleModelInstanceStruct*/

/* Named Constants */

/* Variable Declarations */

/* Variable Definitions */

/* Function Declarations */
extern const mxArray *sf_c1_MultiVehicleModel_get_eml_resolved_functions_info
  (void);

/* Function Definitions */
extern void sf_c1_MultiVehicleModel_get_check_sum(mxArray *plhs[]);
extern void c1_MultiVehicleModel_method_dispatcher(SimStruct *S, int_T method,
  void *data);

#endif
