#include "s_ecal_common.h"

namespace s_eCAL {

void Initialize (SimStruct *S) {
    const std::string model_path(ssGetModelName(ssGetRootSS(S)));
        if(!eCAL::IsInitialized()) {
            if(eCAL::Initialize(0, nullptr, model_path.c_str())) {
                #ifdef SIMULINK_REAL_TIME
                LOG(error,0) << "Error initializing eCAL";
                exit(EXIT_FAILURE);
                #else
                ssSetLocalErrorStatus(S, "Error initializing eCAL");
                #endif
            } else {
                static char startmsg[100];
                sprintf(startmsg,"eCAL %s initialized\n",eCAL::GetVersionString());
                #ifdef SIMULINK_REAL_TIME
                LOG(info,0) << startmsg;
                #else
                ssPrintf(startmsg);
                #endif
            }
        } else {
            const std::string ecalUnitName(eCAL::Process::GetUnitName());
            if(ecalUnitName != model_path) {
                static char warningmsg[300];
                sprintf(warningmsg,"eCAL has already been initialized at %s. Please start another MATLAB instance to use eCAL on %s.",ecalUnitName.c_str(),model_path.c_str());
                ssWarning(S, warningmsg);
            }
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