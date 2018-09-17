//+------------------------------------------------------------------+
//|                                                      IndBias.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#include <RingBuffer\RiBias.mqh>
input int InpPeriodBias=24; // Period
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1
#property indicator_label1  "BIAS"

CRiBias rb_bias = new CRiBias();
double bias[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
   rb_bias.SetMaxTotal(InpPeriodBias);
   SetIndexBuffer(0,bias,INDICATOR_DATA);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int limit;
   if(prev_calculated<1) limit=1;
   else limit = prev_calculated-1;
   for(int i=limit;i<rates_total;i++)
     {
      rb_bias.AddValue(close[i]);
      if(i<InpPeriodBias) continue;
      bias[i]=rb_bias.Bias();
     }
    if(prev_calculated==rates_total)
      {
       rb_bias.ChangeValue(InpPeriodBias-1,close[rates_total-1]);
      }
    
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
