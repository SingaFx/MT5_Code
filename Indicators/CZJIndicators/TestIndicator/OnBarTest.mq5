//+------------------------------------------------------------------+
//|                                                    OnBarTest.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

datetime last_time=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
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
   
//--- return value of prev_calculated for next call
   ArraySetAsSeries(time,true);

   bool is_new_bar=!(last_time==time[0]);
   Print("TickPrint",last_time, " ",time[0], is_new_bar);
   if(is_new_bar)
      {
       last_time=time[0];  
       Print("Bar");
      }
   return(rates_total);
  }
//+------------------------------------------------------------------+
