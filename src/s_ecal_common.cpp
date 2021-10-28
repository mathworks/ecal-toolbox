#include "s_ecal_common.h"

namespace s_eCAL {

    int infoLog(const char_T *msg, ...) {

        char str[1024] = "";
        va_list args;
        va_start(args, msg);
        vsprintf(str, msg, args);
        va_end(args);

        #ifdef SIMULINK_REAL_TIME
        LOG(info,0) << str;
        #else
        ssPrintf(str);
        #endif

        return 0;
    }

    void warningLog(SimStruct *S, const char_T *msg, ...) {

        char str[1024] = "";
        va_list args;
        va_start(args, msg);
        vsprintf(str, msg, args);
        va_end(args);

        #ifdef SIMULINK_REAL_TIME
        LOG(warning,0) << str;
        #else
        ssWarning(S, str);
        #endif
    }

    void errorLog(SimStruct *S, const char_T *msg, ...) {

        char str[1024] = "";
        va_list args;
        va_start(args, msg);
        vsprintf(str, msg, args);
        va_end(args);

        #ifdef SIMULINK_REAL_TIME
        LOG(error,0) << str;
        exit(EXIT_FAILURE);
        #else
        ssSetErrorStatus(S, str);
        #endif
    }


    void Initialize (SimStruct *S) {
        const std::string model_path(ssGetModelName(ssGetRootSS(S)));
        if(!eCAL::IsInitialized()) {
            if(eCAL::Initialize(0, nullptr, model_path.c_str())) {
                s_eCAL::errorLog(S, "Error initializing eCAL.\n");
            } else {
                s_eCAL::infoLog("eCAL %s initialized.\n",eCAL::GetVersionString());
            }
        } else {
            const std::string ecalUnitName(eCAL::Process::GetUnitName());
            if(ecalUnitName != model_path) {
                s_eCAL::warningLog(S, "eCAL has already been initialized at %s. Please start another MATLAB instance to use eCAL on %s.\n",ecalUnitName.c_str(),model_path.c_str());
            }
        }
    }

    void Finalize (SimStruct *S) {
        if(eCAL::IsInitialized()) {
            if(eCAL::Finalize()) {
                s_eCAL::errorLog(S, "Error finalizing eCAL.\n");
            } else {
                s_eCAL::infoLog("eCAL finalized.\n");
            }
        }
    }

}