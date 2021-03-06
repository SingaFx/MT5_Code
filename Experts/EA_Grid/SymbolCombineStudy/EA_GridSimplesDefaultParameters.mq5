//+------------------------------------------------------------------+
//|                              EA_GridSymbolsDefaultParameters.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimple.mqh>
#include <strategy_czj\strategyGrid\GridParametersDefault.mqh>

input string Inp_symbols="EURUSD,EURGBP,GBPUSD";
//input GridLotsCalType  Inp_lots_type=ENUM_GRID_LOTS_EXP_NUM;
//input GridWinType Inp_win_type=ENUM_GRID_WIN_LAST;
input double Inp_base_lots=0.01;
input uint Inp_magic=20181010;
input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)


CStrategyList Manager;
string str_symbols[];
int num1=StringSplit(Inp_symbols,StringGetCharacter(",",0),str_symbols);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridParametersDefault parameter= new CGridParametersDefault();
   
   for(int i=0;i<num1;i++)
     {
      CGridSimple *strategy=new CGridSimple();
      strategy.ExpertName("CGridSimple-"+string(i));
      strategy.ExpertMagic(Inp_magic+i);
      strategy.Timeframe(_Period);
      strategy.ExpertSymbol(str_symbols[i]);
      GridParameters p;
      parameter.GetDefaultParameter(str_symbols[i],p);
      Print("symbols:", str_symbols[i], " p-add:", p.points_add, " p-win:", p.points_win, " p-pos_num:", p.pos_max);
      strategy.Init(p.points_add,p.points_win,Inp_base_lots,ENUM_GRID_LOTS_EXP_NUM,ENUM_GRID_WIN_LAST,p.pos_max);
      strategy.SetTypeFilling(Inp_order_type);
      strategy.ReInitPositions();
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