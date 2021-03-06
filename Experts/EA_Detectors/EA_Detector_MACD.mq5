//+------------------------------------------------------------------+
//|                                             EA_Detector_MACD.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyDetectors\DetectorMACD.mqh>
input string InpPipeName="dmacd";
input int InpMacdFastMa=12;
input int InpMacdSlowMa=26;
input int InpMacdSignalSma=9;
input ENUM_APPLIED_PRICE InpMacdApplyPrice=PRICE_CLOSE;
input int InpDetectorSearchBar=100;
input int InpDetectorExtremeBar=2;
input double InpDetectorRangePricePoints=10;
input double InpDetectorRangeMacd=0.0002;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CDetectorMACD *s=new CDetectorMACD();
   s.ExpertName("MACD Detectors");
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertMagic(111);
   s.SetSymbols();
   s.SetPeriods();
   s.ConnectPipeServer(InpPipeName);
   s.InitHandles(InpMacdFastMa,InpMacdSlowMa,InpMacdSignalSma,InpMacdApplyPrice,InpDetectorSearchBar,InpDetectorExtremeBar,InpDetectorRangePricePoints,InpDetectorRangeMacd,false);
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
