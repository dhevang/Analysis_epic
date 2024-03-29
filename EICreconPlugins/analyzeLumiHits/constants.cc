#ifndef CONSTANTS_CC
#define CONSTANTS_CC

#include "constants.h"

namespace constants {
 
  double speedLight = 0.29979; // speed of light in m / nsec
  double BH_prefactor = 2.3179; // 4 alpha r_e^2 (mb)
  double mass_proton = 0.938272;
  double mass_electron = 0.51099895e-3;
  double mass_muon = 0.1056583745;
  double mass_pionZero = 0.1349768;
  double mass_pion = 0.13957039;

  double Cal_Single_AcceptanceTol = 0.1;
  double Cal_Coin_AcceptanceTol = 0.1;
  double Tracker_Single_AcceptanceTol = 0.05;
  double Tracker_Coin_AcceptanceTol = 0.05;

}
#endif
