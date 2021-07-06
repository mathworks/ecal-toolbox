#define S_FUNCTION_NAME  s_ecal_publisher
#define S_FUNCTION_LEVEL 2

/*
 * Need to include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions.
 */
#include "simstruc.h"

/* Error handling
 * --------------
 *
 * You should use the following technique to report errors encountered within
 * an S-function:
 *
 *       ssSetErrorStatus(S,"Error encountered due to ...");
 *       return;
 *
 * Note that the 2nd argument to ssSetErrorStatus must be persistent memory.
 * It cannot be a local variable. For example the following will cause
 * unpredictable errors:
 *
 *      mdlOutputs()
 *      {
 *         char msg[256];         {ILLEGAL: to fix use "static char msg[256];"}
 *         sprintf(msg,"Error due to %s", string);
 *         ssSetErrorStatus(S,msg);
 *         return;
 *      }
 *
 */

#include <string>

// Include Logger for Simulink Real-Time
#ifdef SIMULINK_REAL_TIME
#include <Logger.hpp>
#endif

#include <ecal/ecal.h>
#include <ecal/msg/string/publisher.h>

#include "s_ecal_common.h"

#define PARAM_TOPIC_NAME_IDX        0 
#define PARAM_TOPIC_TYPE_IDX        1 
#define PARAM_SIGNAL_TYPE_IDX       2
#define PARAM_SAMPLE_TIME_IDX       3

#define PARAM_COUNT                 4

#define PORT_DATA                   0
#define PORT_SIZE                   1

#define PORT_COUNT                  2

struct PWorkStruct
{
    eCAL::CPublisher publisher;
    bool signal_type_variable;
};

template <typename T>
static T get_param(SimStruct *S, int index);

template <>
std::string get_param<std::string>(SimStruct *S, int index)
{
    static char buffer[1024];
    mxGetString(ssGetSFcnParam(S, index), buffer, sizeof buffer - 1);
    return buffer;
}

template <>
double get_param<double>(SimStruct *S, int index)
{
    return *reinterpret_cast<double *>(mxGetData(ssGetSFcnParam(S, index)));
}

template <>
uint32_T get_param<uint32_T>(SimStruct *S, int index)
{
    return static_cast<uint32_T>(*reinterpret_cast<double *>(mxGetData(ssGetSFcnParam(S, index))));
}

static void print_params(SimStruct *S)
{
    ssPrintf("PARAM_TOPIC_NAME:      %s\n", get_param<std::string>(S, PARAM_TOPIC_NAME_IDX).c_str());
    ssPrintf("PARAM_TOPIC_TYPE:      %s\n", get_param<std::string>(S, PARAM_TOPIC_TYPE_IDX).c_str());
    ssPrintf("PARAM_SIGNAL_TYPE:     %u\n", get_param<uint32_T>(S, PARAM_SIGNAL_TYPE_IDX));
    ssPrintf("PARAM_SAMPLE_TIME:     %f\n", get_param<double>(S, PARAM_SIGNAL_TYPE_IDX));
}

/*====================*
 * S-function methods *
 *====================*/


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 */

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, PARAM_COUNT);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        /* Return if number of expected != number of actual parameters */
        return;
    }
    
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    
    //print_params(S);
        
    auto signal_type_variable = get_param<uint32_T>(S, PARAM_SIGNAL_TYPE_IDX) == 1 ? true : false;
    
    if (!ssSetNumInputPorts(S, signal_type_variable ? PORT_COUNT - 1 : PORT_COUNT)) return;
    if (!ssSetNumOutputPorts(S, 0)) return;
    
    ssSetInputPortDataType(S, PORT_DATA, SS_UINT8);
    ssSetInputPortVectorDimension(S, PORT_DATA, DYNAMICALLY_SIZED);    
    ssSetInputPortDimensionsMode(S, PORT_DATA, signal_type_variable ? VARIABLE_DIMS_MODE : FIXED_DIMS_MODE);
    ssSetInputPortRequiredContiguous(S, PORT_DATA, 1);
    ssSetInputPortDirectFeedThrough(S, PORT_DATA, 1);
    
    if(!signal_type_variable)
    {
        ssSetInputPortWidth(S, PORT_SIZE, 1);
        ssSetInputPortDataType(S, PORT_SIZE, SS_UINT32);
        ssSetInputPortRequiredContiguous(S, PORT_SIZE, 1);
        ssSetInputPortDirectFeedThrough(S, PORT_SIZE, 1);
    }
     
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 1);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    /* Specify the operating point save/restore compliance to be same as a
     * built-in block */
    ssSetOperatingPointCompliance(S, USE_DEFAULT_OPERATING_POINT);
    
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
    ssSetRuntimeThreadSafetyCompliance(S, RUNTIME_THREAD_SAFETY_COMPLIANCE_TRUE);
}

/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, get_param<double>(S, PARAM_SAMPLE_TIME_IDX));
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
/* Function: mdlStart =======================================================
 * Abstract:
 *    This function is called once at start of model execution. If you
 *    have states that should be initialized once, this is the place
 *    to do it.
 */
static void mdlStart(SimStruct *S)
{
    if(!ssRTWGenIsCodeGen(S) && !ssIsExternalSim(S)) {
        s_eCAL::Initialize(S);
        
        const std::string block_path(ssGetPath(S));
    
        ssGetPWork(S)[0] = new PWorkStruct;
        auto pwork_struct = static_cast<PWorkStruct *>(ssGetPWork(S)[0]);
        
        pwork_struct->signal_type_variable = get_param<uint32_T>(S, PARAM_SIGNAL_TYPE_IDX) == 1 ? true : false;
        if(!pwork_struct->publisher.Create(get_param<std::string>(S, PARAM_TOPIC_NAME_IDX), get_param<std::string>(S, PARAM_TOPIC_TYPE_IDX))) {
                #ifdef SIMULINK_REAL_TIME
                LOG(error,0) << "Error creating eCAL publisher for block " << block_path;
                exit(EXIT_FAILURE);
                #else
                ssSetLocalErrorStatus(S, "Error creating eCAL publisher for block %s", block_path);
                #endif
            }
        }
    }
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{       
    auto pwork_struct = static_cast<PWorkStruct *>(ssGetPWork(S)[0]);
    const auto max_buffer_size = static_cast<size_t>(ssGetInputPortWidth(S, PORT_DATA));
    
    size_t buffer_size = pwork_struct->signal_type_variable ?   static_cast<uint32_T>(ssGetCurrentInputPortDimensions(S, PORT_DATA, 0))
                                                            :   reinterpret_cast<const uint32_T*>(ssGetInputPortSignal(S, PORT_SIZE))[0];
    
    buffer_size = buffer_size > max_buffer_size ? max_buffer_size : buffer_size;
    
    std::string data(reinterpret_cast<const char*>(ssGetInputPortSignal(S, PORT_DATA)), buffer_size);
    pwork_struct->publisher.Send(data);
}


/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was
 *    allocated in mdlStart, this is the place to free it.
 */
static void mdlTerminate(SimStruct *S)
{
    auto pwork_struct = static_cast<PWorkStruct *>(ssGetPWork(S)[0]);
    delete pwork_struct;

    s_eCAL::Finalize(S);
}


/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
