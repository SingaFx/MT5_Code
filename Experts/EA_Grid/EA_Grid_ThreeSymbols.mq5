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
input int Inp_grid_cross=200;
input int Inp_grid_x=350;
input int Inp_grid_y=300;
input int Inp_pos_num_cross=11;
input int Inp_pos_num_x=10;
input int Inp_pos_num_y=12;
input int Inp_tp_cross=790;
input int Inp_tp_x=790;
input int Inp_tp_y=600;


CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridThreeSymbols *strategy=new CGridThreeSymbols();
   strategy.ExpertName("CGridThreeSymbols");
   strategy.ExpertMagic(20181113);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.SetThreeSymbols(Inp_cross_s,Inp_x_s,Inp_y_s);
   strategy.SetThreePosNums(Inp_pos_num_cross,Inp_pos_num_x,Inp_pos_num_y);
   strategy.SetThreeGrids(Inp_grid_cross,Inp_grid_x,Inp_grid_y);
   strategy.SetThreeTPs(Inp_tp_cross,Inp_tp_x,Inp_tp_y);
   
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
