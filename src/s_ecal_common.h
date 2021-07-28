#include "simstruc.h"

// Include Logger for Simulink Real-Time
#ifdef SIMULINK_REAL_TIME
#include "Logger.hpp"
#endif

#include <ecal/ecal.h>

namespace s_eCAL {

void Initialize (SimStruct *S);
void Finalize (SimStruct *S);

}