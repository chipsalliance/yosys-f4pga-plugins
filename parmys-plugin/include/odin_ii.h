#ifndef ODIN_II_H
#define ODIN_II_H

#include "odin_types.h"
/* Odin-II exit status enumerator */
enum ODIN_ERROR_CODE { ERROR_INITIALIZATION, ERROR_PARSE_CONFIG, ERROR_PARSE_ARCH, ERROR_ELABORATION, ERROR_OPTIMIZATION, ERROR_TECHMAP };

void set_default_config();

#endif
