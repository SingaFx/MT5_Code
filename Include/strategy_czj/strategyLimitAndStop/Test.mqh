//+------------------------------------------------------------------+
//|                                                         Test.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "LimitStopBase.mqh"

class CTest:public CLimitAndStopBase
  {
public:
                     CTest(void);
                    ~CTest(void){};
protected:
   virtual void      PatternRecognize();  
  };
CTest::CTest(void)
   {
    open_signal=ENUM_OPEN_SIGNAL_NULL;
    open_lots=0.01;
   }
void CTest::PatternRecognize(void)
   {
    open_signal=ENUM_OPEN_SIGNAL_NULL;
    if((High[1]-Low[1])*MathPow(10,Digits())<300)
      {
       return;
      }
    if(Open[1]<Close[1])
      {
       open_signal=ENUM_OPEN_SIGNAL_LIMIT_BUY;
       open_price=Low[1]+0.382*(High[1]-Low[1]);
       tp_price=Low[1]+0.618*(High[1]-Low[1]);
       sl_price=Low[1];
      }
     else
       {
       open_signal=ENUM_OPEN_SIGNAL_LIMIT_SELL;
       open_price=High[0]-0.382*(High[0]-Low[0]);
       tp_price=High[0]-0.618*(High[0]-Low[0]);
       sl_price=High[0];
       }
   }