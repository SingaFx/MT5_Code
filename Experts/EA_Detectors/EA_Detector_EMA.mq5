//+------------------------------------------------------------------+
//|                                              EA_Detector_EMA.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyDetectors\DetectorEMA.mqh>

input string InpPipeName="dema"; // 管道名称
input int InpEmaHigh=150;
input int InpEmaLow=150;
input int InpEmaClose=50;
input int InpWilliamLong=100;
input int InpWilliamShort=10;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CDetectorEMA *s=new CDetectorEMA();
   s.ExpertName("CDetectorEMA");
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertMagic(111);
   
   s.SetSymbols();
   ENUM_TIMEFRAMES tfs[]={PERIOD_M15,PERIOD_M30,PERIOD_H1};
   s.SetPeriods(tfs);
   
   s.ConnectPipeServer(InpPipeName);
   
   s.InitHandles(InpEmaClose,InpEmaHigh,InpEmaLow,InpWilliamLong,InpWilliamShort);
   Manager.AddStrategy(s);
   
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

