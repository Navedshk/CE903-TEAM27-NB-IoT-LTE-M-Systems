/* Include files */

#include "OTDOA_Positioning_Model20x2810x29_cgxe.h"
#include "m_mQdRlvDo7DWz304OnmLIeF.h"

unsigned int cgxe_OTDOA_Positioning_Model20x2810x29_method_dispatcher(SimStruct*
  S, int_T method, void* data)
{
  if (ssGetChecksum0(S) == 2143951628 &&
      ssGetChecksum1(S) == 602898981 &&
      ssGetChecksum2(S) == 980749863 &&
      ssGetChecksum3(S) == 1642240043) {
    method_dispatcher_mQdRlvDo7DWz304OnmLIeF(S, method, data);
    return 1;
  }

  return 0;
}
