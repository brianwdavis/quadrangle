#include "quirc.h"
#include <Rcpp.h>

using namespace Rcpp;


// [[Rcpp::export]]
List rcpp_qr_scan_array(RawVector grayarray, int w, int h, bool debug = false) {
  
  // Allocate result
  List z;
  
  // Warning/early return to prevent crashes
  if (grayarray.length() != w*h) {
    Rcpp::warning(
      "Did you misspecify your pixels? %i != %i * %i\n. Currently only grayscale supported.", 
      grayarray.length(), w, h
    );
    return z;
  }
  
  // Create buffer
  struct quirc *qr = quirc_new();
  if (quirc_resize(qr, w, h) < 0) {
    stop("Failed to allocate buffer of size %i bytes.", grayarray.length());
  }
  
  uint8_t *image = quirc_begin(qr, &w, &h);
  
  // Fill image buffer
  for (int i = 0; i < w*h; ++i) {
    image[i] = grayarray[i];
  }
  
  // Gracefully exit
  Rcpp::checkUserInterrupt();
  
  // Free up structures
  quirc_end(qr);
  
  int num_codes = quirc_count(qr);
  
  // Allocate various return vars
  CharacterVector vals(num_codes);
  NumericVector vids(num_codes);
  
  NumericVector vers(num_codes);
  NumericVector vecc(num_codes);
  NumericVector vmsk(num_codes);
  NumericVector vtyp(num_codes);
  NumericVector vlen(num_codes);
  NumericVector veci(num_codes);
  
  NumericVector pid(4*num_codes);
  NumericVector pxs(4*num_codes);
  NumericVector pys(4*num_codes);
  
  // Extract points then values (and metadata)
  for (int j = 0; j < num_codes; ++j) {
    struct quirc_code code;
    struct quirc_data data;
    
    quirc_extract(qr, j, &code);
    quirc_decode(&code, &data);
    
    for (int i=0;i<4;++i) {
      pid[i+4*j] = j+1;
      pxs[i+4*j] = code.corners[i].x;
      pys[i+4*j] = code.corners[i].y;
      // TODO add "corner" column to match JS output
    }
    
    vals[j] = (char*)data.payload;
    vids[j] = j+1;
    
    if (debug) {
      vers[j] = data.version;
      vecc[j] = data.ecc_level;
      vmsk[j] = data.mask;
      vtyp[j] = data.data_type;
      vlen[j] = data.payload_len;
      veci[j] = data.eci;
    }
  }
  
  // Free up structures
  quirc_destroy(qr);
  
  DataFrame zp = DataFrame::create(
    _["id"] = pid, 
    _["x"] = pxs, 
    _["y"] = pys, 
    _["stringsAsFactors"] = false
  );
  
  DataFrame zv;
  
  if (debug) {
    zv = DataFrame::create(
      _["id"] = vids, _["value"] = vals, 
      _["version"] = vers, _["ECC"] = vecc,
      _["mask"] = vmsk, _["data_type"] = vtyp, 
      _["length"] = vlen, _["ECI"] = veci,
      _["stringsAsFactors"] = false
    );
  } else {
    zv = DataFrame::create(
      _["id"] = vids, _["value"] = vals, 
      _["stringsAsFactors"] = false
    );
  }
  
  z = List::create(_["values"] = zv, _["points"] = zp);
  return z;
  
}
