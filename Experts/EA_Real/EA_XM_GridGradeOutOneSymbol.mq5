//+------------------------------------------------------------------+
//|                                  EA_XM_GridGradeOutOneSymbol.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridOneSymbolGradeOut.mqh>
input double Inp_base_lots=0.1; // 基础手数
input int Inp_grid_add=150; // 加仓点数
input int Inp_tp_per_lots=5; // 每手止盈
input int Inp_tp_total=2; // 总盈利
input int Inp_pos_num=30;  // 仓位数控制
input LotsType Inp_lots_type=ENUM_LOTS_EXP_NUM; // 手数序列类型
CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridOneSymbolGradeOut *strategy=new CGridOneSymbolGradeOut();
   strategy.ExpertName("CGridOneSymbolGradeOut");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_base_lots,Inp_pos_num,Inp_grid_add,Inp_tp_per_lots,Inp_tp_total);
   strategy.SetLotsType(Inp_lots_type);
   strategy.SetTypeFilling(ORDER_FILLING_IOC);
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

