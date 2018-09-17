//+------------------------------------------------------------------+
//|                                           EA_ZigZagLightning.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyZigZag\LightningReverse.mqh>
#include <Strategy\StrategiesList.mqh>

input double InpRatioReverse=0.4;
input double InpRatioTrend=0.8;
input double InpRatioOpen=0.2;
input double InpLots=0.1;
input int Inp_EA_Magic = 118062101;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CLightingReverse *strategy= new CLightingReverse();
   strategy.ExpertName("CLightingReverse");
   strategy.ExpertMagic(Inp_EA_Magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.SetParameter(InpRatioReverse,InpRatioTrend,InpRatioOpen,InpLots);
   Manager.AddStrategy(strategy);
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
