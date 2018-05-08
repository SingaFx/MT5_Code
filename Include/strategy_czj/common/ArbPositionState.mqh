//+------------------------------------------------------------------+
//|                                             ArbPositionState.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
class CArbPositionState
  {
private:
   ENUM_POSITION_TYPE pos_type;
   double pos_profits;
   double pos_holdtime;
   
public:
                     CArbPositionState(void);
                    ~CArbPositionState(void);
  };
