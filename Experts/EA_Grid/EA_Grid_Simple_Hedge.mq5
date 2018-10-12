//+------------------------------------------------------------------+
//|                                         EA_Grid_Simple_Hedge.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimpleHedge.mqh>
input int Inp_points_add=300;
input int Inp_points_win=600;
input double Inp_base_lots=0.01;
input GridLotsCalType  Inp_lots_type=ENUM_GRID_LOTS_EXP;
input GridWinType Inp_win_type=ENUM_GRID_WIN_LAST;
input uint Inp_magic=20181010;
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridSimpleHedge *strategy=new CGridSimpleHedge();
   strategy.ExpertName("CGridSimpleHedge");
   strategy.ExpertMagic(Inp_magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init();
   //strategy.Init(Inp_points_add,Inp_points_win,Inp_base_lots,Inp_lots_type,Inp_win_type);
   
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
