//+------------------------------------------------------------------+
//|                                                  DownloadBar.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategySpecial\CDownload.mqh>
#include <Strategy\StrategiesList.mqh>
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CBarData *b=new CBarData();
   b.ExpertName("DataDownload");
   b.ExpertMagic(2018090401);
   b.Timeframe(_Period);
   b.ExpertSymbol(_Symbol);
   Manager.AddStrategy(b);
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
