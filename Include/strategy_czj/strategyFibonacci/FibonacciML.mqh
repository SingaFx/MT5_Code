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
class CFibonacciML:public CFibonacciBase
  {
private:
   int               handle_zigzag;
   double            alpha_zz[];
   double            value_zz[];
   int               num_zz;
   double            net_value;
protected:
   virtual void      PatternRecognizedOnBar(); // 在bar事件上进行模式识别
   void              CalNetValue(); //计算网络的值
                                               //virtual void      TickEventHandle();
public:
                     CFibonacciML(void);
                    ~CFibonacciML(void){};
   void              SetAlpha(const double &alpha_arr[]);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFibonacciML::CFibonacciML(void)
  {
   handle_zigzag=iCustom(ExpertSymbol(),Timeframe(),"Examples\\ZigZag");
   open_ratio=0.382;
   tp_ratio=0.618;
   sl_ratio=-1.0;
   lots_base=0.1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciML::SetAlpha(const double &alpha_arr[])
  {
   ArrayCopy(alpha_zz,alpha_arr);
   num_zz=ArraySize(alpha_zz);
   ArrayResize(value_zz,num_zz);
  }
void CFibonacciML::CalNetValue(void)
   {
    net_value=0;
    for(int i=0;i<num_zz;i++)
      {
       net_value+=alpha_zz[i]*(value_zz[i]/value_zz[0]);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFibonacciML::PatternRecognizedOnBar(void)
  {

//复制zigzag指标数值--并取得极值点
   double zigzag_value[];
   CopyBuffer(handle_zigzag,0,0,100,zigzag_value);
   int counter=0;
   max_price=DBL_MIN;
   min_price=DBL_MAX;
   for(int i=ArraySize(zigzag_value)-2;i>=0;i--)
     {
      if(zigzag_value[i]==0) continue;//过滤为0的值
      if(counter==num_zz) break;//极值数量达到给定的值不再取值
      if(zigzag_value[i]>max_price) max_price=zigzag_value[i];
      if(zigzag_value[i]<min_price) min_price=zigzag_value[i];
      counter++;
      value_zz[counter-1]=zigzag_value[i];
     }
     
   if(counter<num_zz)
      {
       signal=OPEN_SIGNAL_NULL;
       return;
      }
   CalNetValue();
   if(net_value>0)
      {
       signal=OPEN_SIGNAL_BUY;
      }
   else if(net_value<0) 
      {
       signal=OPEN_SIGNAL_SELL;
      }
    open_lots=lots_base;
  }
//+------------------------------------------------------------------+
