//+------------------------------------------------------------------+
//|                                                gambling_test.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyGambling\Gambling.mqh>
#include <Strategy\StrategiesList.mqh>
input int InpPointsAdd=500;
input int InpPointsWin=200;
input double InpBaseLots=0.01;
input WIN_POINTS_TYPE InpWinType=ENUM_WIN_PER_LOTS;
input ADD_LOTS_TYPE InpAddType=ENUM_LOTS_ADD_FIBONACCI;
input int InpEaMagic=3333;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

CStrategyList Manager;

int OnInit()
  {
//---
   AddPositionStrategy *strategy=new AddPositionStrategy();
   strategy.ExpertMagic(InpEaMagic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.ExpertName("Gambling Position Add"+string(InpEaMagic));
   strategy.InitStrategy(InpPointsAdd,InpPointsWin,InpWinType,InpAddType);
   strategy.SetEventDetect(_Symbol,_Period);
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
