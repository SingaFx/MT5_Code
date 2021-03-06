//+------------------------------------------------------------------+
//|                                                  FibonacciML.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "FibonacciBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFibonacciBaseZZ:public CFibonacciBase
  {
private:
   int               handle_zigzag;
   int               num_zz;
   double value_zz[];
protected:
   virtual void      PatternRecognizedOnBar(); // 在bar事件上进行模式识别
public:
                     CFibonacciBaseZZ(void);
                    ~CFibonacciBaseZZ(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFibonacciBaseZZ::CFibonacciBaseZZ(void)
  {
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag",12,5,3);
   open_ratio=0.236;
   tp_ratio=0.618;
   sl_ratio=-1.0;
   lots_base=0.01;
   num_zz=5;
   ArrayResize(value_zz,num_zz);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciBaseZZ::PatternRecognizedOnBar(void)
  {

//复制zigzag指标数值--并取得极值点
   double zigzag_value[];
   CopyBuffer(handle_zigzag,0,0,100,zigzag_value);
   int counter=0;
   max_price=DBL_MIN;
   min_price=DBL_MAX;
   int imax=0;
   int imin=0;
   for(int i=ArraySize(zigzag_value)-2;i>=0;i--)
     {
      if(zigzag_value[i]==0) continue;//过滤为0的值
      if(counter==num_zz) break;//极值数量达到给定的值不再取值
      if(zigzag_value[i]>max_price) 
         {
          max_price=zigzag_value[i];
          imax=i;
         }
      if(zigzag_value[i]<min_price)
         {
           min_price=zigzag_value[i];
           imin=i;
         }
      counter++;
      value_zz[counter-1]=zigzag_value[i];
     }
       
   if(counter<num_zz)
      {
       signal=OPEN_SIGNAL_NULL;
       return;
      }
   if(imax>imin)
      {
       signal=OPEN_SIGNAL_BUY;
      }
   else if(imax<imin) 
      {
       signal=OPEN_SIGNAL_SELL; 
      }
    open_lots=lots_base;
  }
//+------------------------------------------------------------------+
