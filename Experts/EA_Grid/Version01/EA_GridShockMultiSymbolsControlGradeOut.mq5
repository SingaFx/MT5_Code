//+------------------------------------------------------------------+
//|                      EA_GridShockMultiSymbolsControlGradeOut.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "震荡网格策略--分级出场,多个品种,风险控制"
#property description "检测仓位较重的方向:"
#property description "    仓位小于三级,检测所有仓位的每手止盈和总止盈是否满足条件出场"
#property description "    仓位大于等于三级,检测最后两个仓位和最早仓位的每手止盈和总止盈是否满足条件出场"
#property description "参数设置1--品种组合"
#property description "参数设置2--手数序列:基础手数,序列类型,指数仓位控制数"
#property description "参数设置3--网格参数:网格间距,每手止盈,总止盈"
#property description "参数设置4--风险参数:TBD"
#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyMultiSymbolsControlGradeOut.mqh>
#include <Strategy\StrategiesList.mqh>

//input string Inp_syms="EURUSD,GBPUSD,EURGBP,AUDUSD,AUDJPY,EURJPY,USDJPY";  // 品种组合
input string Inp_syms="EURAUD,EURGBP,EURJPY,GBPAUD,GBPJPY,AUDJPY";  // 品种组合

input double Inp_base_lots=0.01; // 基础手数
input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_LINEAR;  // 手数类型
input int Inp_exp_num=12;  // 设置指数类型手数控制的仓位数

input int Inp_grid_gap=150; // 网格间距
input double Inp_grid_tp_per_lots=600; // 每手止盈
input double Inp_grid_tp_total=6;    // 总止盈

input uint Inp_magic=20181204;  // Magic

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string arr_sym[];
   int num=StringSplit(Inp_syms,StringGetCharacter(",",0),arr_sym);
   
   CGridShockStrategyMultiSymbolsControlGradeOut *s=new CGridShockStrategyMultiSymbolsControlGradeOut();
   s.ExpertName("CGridShockStrategyMultiSymbolsControlGradeOut");
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetSymbols(arr_sym);
   s.SetLotsParameter(Inp_base_lots,Inp_lots_type,Inp_exp_num);
   s.SetGridParameter(Inp_grid_gap,Inp_grid_tp_per_lots,Inp_grid_tp_total);
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