#include "simstruc.h"

// Include Logger for Simulink Real-Time
#ifdef SIMULINK_REAL_TIME
#include <Logger.hpp>
#endif

#include <ecal/ecal.h>

#include "s_ecal_common.h"

namespace s_eCAL {

void Initialize (SimStruct *S) {
        if(!eCAL::IsInitialized())
        {
            if(eCAL::Initialize()) {
                #ifdef SIMULINK_REAL_TIME
                LOG(error,0) << "Error initializing eCAL";
                exit(EXIT_FAILURE);
                #else
                ssSetLocalErrorStatus(S, "Error initializing eCAL");
                #endif
            } else {
                #ifdef SIMULINK_REAL_TIME
                LOG(info,0) << "eCAL initialized";
                #else
                ssPrintf("eCAL initialized");
                #endif
            }
            const std::string model_path(ssGetModelName(S)); 
            eCAL::SetUnitName(model_path.c_str());
        }
}

void Finalize (SimStruct *S) {
if(eCAL::IsInitialized()) {
        if(eCAL::Finalize()) {
            #ifdef SIMULINK_REAL_TIME
            LOG(error,0) << "Error finalizing eCAL";
            exit(EXIT_FAILURE);
            #else
            ssSetLocalErrorStatus(S, "Error finalizing eCAL");
            #endif
        } else {
            #ifdef SIMULINK_REAL_TIME
            LOG(info,0) << "eCAL finalized";
            #else
            ssPrintf("eCAL finalized");
            #endif
        }
    }
}

}