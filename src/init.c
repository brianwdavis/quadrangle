#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

// Generated with:
// tools::package_native_routine_registration_skeleton(".", character_only = F)

/* .Call calls */
extern SEXP _quadrangle_rcpp_qr_scan_array(SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
  {"_quadrangle_rcpp_qr_scan_array", (DL_FUNC) &_quadrangle_rcpp_qr_scan_array, 4},
  {NULL, NULL, 0}
};

void R_init_quadrangle(DllInfo *dll)
{
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
