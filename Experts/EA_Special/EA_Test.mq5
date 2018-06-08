//+------------------------------------------------------------------+
//|                                                      EA_Test.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
MqlTick tick;
int counter=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(counter<5)
     {
     Print(counter);
   SymbolInfoTick(_Symbol,tick);
   Print("time:", tick.time," ",int(tick.time)," ",tick.bid," ", tick.ask, " ",tick.last, " ", tick.volume, " ", tick.time_msc, " ", tick.flags);
   //SymbolInfoTick(_Symbol,tick);
   //Print("time:",tick.time," ",tick.bid," ", tick.ask, " ",tick.last, " ", tick.volume, " ", tick.time_msc, " ", tick.flags);
     counter++;
     }

  }
//+------------------------------------------------------------------+
