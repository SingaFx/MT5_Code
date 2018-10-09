//+------------------------------------------------------------------+
//|                                         EA_Grid_ThreeSymbols.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridThreeSymbols.mqh>
input string Inp_cross_s="EURGBP";
input string Inp_x_s="EURUSD";
input string Inp_y_s="GBPUSD";
input int Inp_grid_cross=300;
input int Inp_grid_x=300;
input int Inp_grid_y=300;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridThreeSymbols *strategy=new CGridThreeSymbols();
   strategy.ExpertName("CGridThreeSymbols");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_cross_s,Inp_x_s,Inp_y_s,Inp_grid_cross,Inp_grid_x,Inp_grid_y);
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
