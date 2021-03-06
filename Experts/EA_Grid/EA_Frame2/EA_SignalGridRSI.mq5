//+------------------------------------------------------------------+
//|                                             EA_SignalGridRSI.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "基于RSI信号的网格策略"

#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridFrame2\SignalRsiGridStrategy.mqh>

input double Inp_base_lots=0.01;
input GridLotsCalType Inp_l_type=ENUM_GRID_LOTS_LINEAR;
input int  Inp_num_pos=15;
input int Inp_gap=300;
input int Inp_tp_per=200;
input int Inp_tp_total=200;
input RsiGridType Inp_rg_type=ENUM_RG_MODE_1;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CSignalRsiGridStrategy *strategy=new CSignalRsiGridStrategy();
   strategy.ExpertName("CSignalRsiGridStrategy");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init();
   strategy.SetLotsParameter(Inp_base_lots,Inp_l_type,Inp_num_pos);
   strategy.SetParameters(Inp_gap,Inp_tp_total,Inp_tp_per);
   strategy.SetRGType(Inp_rg_type);
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
