//+------------------------------------------------------------------+
//|                                         EA_MultiSymbols_LSRE.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\common\strategy_common.mqh>
#include <strategy_czj\strategyGrid\LongShortRotation\LSRotationElasticStrategy.mqh>
#include <Strategy\StrategiesList.mqh>
enum SymbolPair
  {
   ENUM_SP_USD,
   ENUM_SP_28,
   ENUM_SP_4_1
  };

input double Inp_base_lots=0.01; // 基础手数
input int Inp_rotation_pos_num=5;   // 开启轮转的仓位数
input int Inp_max_pos_num=20; // 最大的持仓数
input int Inp_gap_small=150;  // 小网格
input int Inp_gap_big=1500;   // 大网格
input double Inp_tp_total=500;   // 总盈利
input double Inp_tp_per_lots=200;   // 每手盈利
input SymbolPair Inp_Symbols=ENUM_SP_USD;  // 品种组合
input uint Inp_magic=20181204;  // Magic
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string s_combine[];
   string s_usd[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   string s_4_1[]={"EURGBP","AUDNZD","USDCAD","CHFJPY"};
   switch(Inp_Symbols)
     {
      case ENUM_SP_USD :
        ArrayCopy(s_combine,s_usd);
        break;
      case ENUM_SP_4_1:
         ArrayCopy(s_combine,s_4_1);
         break;
      default:
        ArrayCopy(s_combine,SYMBOLS_28);
        break;
     }
   
   for(int i=0;i<ArraySize(s_combine);i++)
     {
      CLSRotationElasticStrategy *s=new CLSRotationElasticStrategy();
      s.ExpertName("CLSRotationElasticStrategy-"+s_combine[i]);
      s.ExpertMagic(Inp_magic+i);
      s.ExpertSymbol(s_combine[i]);
      s.Timeframe(_Period);
      s.SetParameters(Inp_rotation_pos_num,Inp_max_pos_num,Inp_gap_small,Inp_gap_big,Inp_base_lots,Inp_tp_total,Inp_tp_per_lots);
      Manager.AddStrategy(s);
     }
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

