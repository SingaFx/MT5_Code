//+------------------------------------------------------------------+
//|                                              EA_Grid_Simples.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimple.mqh>

input string Inp_symbols="AUDCHF,AUDNZD,EURJPY,NZDCAD,NZDCHF";
input string Inp_points_add="300,300,300,300,300";
input string Inp_points_win="600,600,600,600,600";
input double Inp_base_lots=0.01;
input GridLotsCalType  Inp_lots_type=ENUM_GRID_LOTS_EXP;
input GridWinType Inp_win_type=ENUM_GRID_WIN_LAST;
input uint Inp_magic=20181010;


CStrategyList Manager;
string str_symbols[];
string str_add_points[];
string str_win_points[];
int num1=StringSplit(Inp_symbols,StringGetCharacter(",",0),str_symbols);
int num2=StringSplit(Inp_points_add,StringGetCharacter(",",0),str_add_points);
int num3=StringSplit(Inp_points_win,StringGetCharacter(",",0),str_win_points);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i=0;i<num1;i++)
     {
      CGridSimple *strategy=new CGridSimple();
      strategy.ExpertName("CGridSimple-"+string(i));
      strategy.ExpertMagic(Inp_magic+i);
      strategy.Timeframe(_Period);
      strategy.ExpertSymbol(str_symbols[i]);
      strategy.Init(StringToInteger(str_add_points[i]),StringToInteger(str_win_points[i]),Inp_base_lots,Inp_lots_type,Inp_win_type);
      Manager.AddStrategy(strategy);
     }
   
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
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
