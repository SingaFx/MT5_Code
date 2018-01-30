//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\BreakPointRSI.mqh>
input RSI_type type_RSI=ENUM_RSI_TYPE_5;
CStrategyList Manager;
string symbols[]={"AUDCAD","NZDUSD","EURGBP","EURUSD"};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CBreakPointRSIStrategy *rsi_s[];
   ArrayResize(rsi_s,ArraySize(symbols));
   for(int i=0;i<ArraySize(symbols);i++)
     {
      rsi_s[i]=new CBreakPointRSIStrategy();
      rsi_s[i].ExpertName("RSI BreakPoint Strategy"+string(i));
      rsi_s[i].ExpertMagic(2018012601+i);
      rsi_s[i].Timeframe(_Period);
      rsi_s[i].ExpertSymbol(symbols[i]);
      rsi_s[i].SetEventDetect(symbols[i],_Period);
      rsi_s[i].InitStrategy(type_RSI);
      Manager.AddStrategy(rsi_s[i]);
     }
   
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
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
