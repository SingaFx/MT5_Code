//+------------------------------------------------------------------+
//|                                                  ArbPosition.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CArbPosition
  {
private:
   CArrayLong        long_pos_arr;
   CArrayLong        short_pos_arr;
public:
                     CArbPosition(void);
                    ~CArbPosition(void);
   double            GetLongProfits();
   double            GetShortProfits();
   double            GetLongLots();
   double            GetShortLots();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CArbPosition::GetLongProfits(void)
  {
   double sum_p=0;
   for(int i=0;i<long_pos_arr.Total();i++)
     {
      PositionSelectByTicket(long_pos_arr.At(i));
      sum_p+=PositionGetDouble(POSITION_PROFIT);
     }
   return sum_p;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CArbPosition::GetShortProfits(void)
  {
   double sum_p=0;
   for(int i=0;i<short_pos_arr.Total();i++)
     {
      PositionSelectByTicket(short_pos_arr.At(i));
      sum_p+=PositionGetDouble(POSITION_PROFIT);
     }
   return sum_p;
  }
//+------------------------------------------------------------------+
