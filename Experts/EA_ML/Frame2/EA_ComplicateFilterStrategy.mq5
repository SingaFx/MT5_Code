//+------------------------------------------------------------------+
//|                                  EA_ComplicateFilterStrategy.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRobot\Frame2\RandFilterStrategy.mqh>
#include <strategy_czj\strategyRobot\Frame2\ReverseLastMaxMinFilterStrategy.mqh>
#include <strategy_czj\strategyRobot\Frame2\RetraceFilterStrategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|              EA运行模式枚举                                      |
//+------------------------------------------------------------------+
enum EaRunType
  {
   ENUM_EA_RUN_TYPE_OPT,// 单一模式优化
   ENUM_EA_RUN_TYPE_TEST,// 组合模式测试
   ENUM_EA_RUN_WITHOUT_FILTER // 不使用过滤器
  };
//+------------------------------------------------------------------+
//|             品种组合类型                                         |
//+------------------------------------------------------------------+
enum SymbolCombineType
  {
   ENUM_SYMBOL_COMBINE_1,// 当前品种
   ENUM_SYMBOL_COMBINE_28,// 28个品种
   ENUM_SYMBOL_COMBINE_7  // 7个直盘品种
  };
//+------------------------------------------------------------------+
//|                基础策略类型                                      |
//+------------------------------------------------------------------+
enum BaseStrategyType
  {
   ENUM_BASE_STRATEGY_RAND,// 随机策略
   ENUM_BASE_STRATEGY_REVERSE_LMM,   // 基于支撑阻力(极值)的反转策略
   ENUM_BASE_STRATEGY_RETRACE // 基于回调点的开仓策略
  };

sinput string InpMID="******EA Magic******"; // 标题 ——————>
input uint InpID=201906;   // EA标识:x*100+i
sinput string InpStr3="*****EA运行方式*****"; // 标题  ——————>
input EaRunType InpRunType=ENUM_EA_RUN_TYPE_OPT;

sinput string InpStr1="*****品种选择*****"; // 标题  ——————>
input SymbolCombineType InpSym=ENUM_SYMBOL_COMBINE_1;     // 品种组合类型

sinput string InpStr2="*****基本策略选择*****"; // 标题  ——————>
input BaseStrategyType InpBaseStrategy=ENUM_BASE_STRATEGY_RAND;
input int InpTpPoints=500; // 止盈点数
input int InpSlPoints=500; // 止损点数
input int InpSepTime=4; // 相邻两单隔开的时间(小时)

sinput string InpStr4="*****构造分类器的方式*****"; // 标题  ——————>
input bool InpUseDoubleMa=true;  // 是否使用双均线
input bool InpUseRsi=true; // 是否使用RSI
input bool InpUseCandle=true; // 是否使用蜡烛图
input CandleCombineType InpCandelType=ENUM_CANDLE_TYPE_ONE; // 蜡烛图类型

sinput string InpStr5="*****模式优化选项*****"; // ##(仅在EA运行方式为优化时有效)
input int InpPatternIndex=0;  // 当前优化的模式索引
input ENUM_MAPPING_TYPE InpMapType=MAPPING_NULL;   // 当前模式索引映射方式

sinput string InpStr6="*****模式测试选项*****"; // ##(仅在EA运行方式为组合测试时有效)
input string InpLongPatternIndex="0";  // 做多模式索引序列
input string InpShortPatternIndex="1";  // 做空模式索引序列

CStrategyList Manager;
int num_strategy; // 策略总数
string syms[]; // 品种数组
               //CBaseFilterStrategy *filter_s[]; // 策略数组
CArrayObj strategy_arr;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   num_strategy=SetSymbols();  // 设置品种
   SetStrategyInfor();  // 设置策略的基本信息
   SetFilterInfor(); // 设置策略过滤器信息
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
//|                                                                  |
//+------------------------------------------------------------------+
int SetSymbols()
  {
   switch(InpSym)
     {
      case ENUM_SYMBOL_COMBINE_1 :
         ArrayResize(syms,1);
         syms[0]=_Symbol;
         break;
      case ENUM_SYMBOL_COMBINE_7:
         ArrayCopy(syms,SYMBOLS_7);
         break;
      case ENUM_SYMBOL_COMBINE_28:
         ArrayCopy(syms,SYMBOLS_28);
         break;
      default:
         break;
     }
   return ArraySize(syms);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetStrategyInfor()
  {

   for(int i=0;i<num_strategy;i++)
     {
      switch(InpBaseStrategy)
        {
         case ENUM_BASE_STRATEGY_RAND :
           {
            CRandFilterStrategy *s=new CRandFilterStrategy();
            strategy_arr.Add(s);
           }
         break;
         case ENUM_BASE_STRATEGY_REVERSE_LMM:
           {
            CReverseLastMaxMinFilterStrategy *s=new CReverseLastMaxMinFilterStrategy();
            s.SetPatternParameter(200,20,50);
            strategy_arr.Add(s);
           }
         break;
         case ENUM_BASE_STRATEGY_RETRACE:
            {
             CRetraceFilterStrategy *s = new CRetraceFilterStrategy();
             s.SetPatternParameter(30,1,300);
             strategy_arr.Add(s);
            }
            break;
         default:
            break;
        }
     }
   for(int i=0;i<strategy_arr.Total();i++)
     {
      CBaseFilterStrategy *s=strategy_arr.At(i);
      s.ExpertMagic(InpID*100+i);
      s.ExpertName("模式过滤策略"+IntegerToString(i));
      s.ExpertSymbol(syms[i]);
      s.Timeframe(_Period);
      s.SetTpAndSl(InpTpPoints,InpSlPoints);
      s.SetOpenTimeDist(InpSepTime);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetFilterInfor()
  {
   for(int i=0;i<strategy_arr.Total();i++)
     {
      CBaseFilterStrategy *s=strategy_arr.At(i);
      s.filter.SetSymbol(syms[i]); // 设置过滤器品种
      if(InpUseDoubleMa) s.filter.CreateDoubleMaClassify();   // 在filter中创建双均线特征分类器
      if(InpUseRsi) s.filter.CreateRsiClassify();  // 在filter中创建RSI特征分类器 
      if(InpUseCandle) s.filter.CreateCandleClassify(InpCandelType);

      s.filter.InitFilterState();  // 初始化filter
      s.filter.InitTypeValue(MAPPING_NO_OPERATE); // 将所有的filter分类对应操作设置为禁止(买卖)操作
      switch(InpRunType) // 根据EA的运行情况，对filter进行个性化设置
        {
         case ENUM_EA_RUN_TYPE_OPT :
            s.filter.SetMappingTypeAt(InpPatternIndex,InpMapType);  // 将指定的filter分类索引设置为指定的mapping操作类型
            break;
         case ENUM_EA_RUN_TYPE_TEST:
           {
            string i_long_str[],i_short_str[];
            int index_long[],index_short[];
            int num_long=StringSplit(InpLongPatternIndex,StringGetCharacter(",",0),i_long_str);
            int num_short=StringSplit(InpShortPatternIndex,StringGetCharacter(",",0),i_short_str);
            ArrayResize(index_long,num_long);
            ArrayResize(index_short,num_short);
            for(int j=0;j<num_long;j++)
              {
               index_long[j]=int(i_long_str[j]);
               if(index_long[j]>=s.filter.GetTotalFilterNum()) continue;
               s.filter.SetMappingTypeAt(index_long[j],MAPPING_LONG_OPERATE);
              }
            for(int j=0;j<num_short;j++)
              {
               index_short[j]=int(i_short_str[j]);
               if(index_short[j]>=s.filter.GetTotalFilterNum()) continue;
               s.filter.SetMappingTypeAt(index_short[j],MAPPING_SHORT_OPERATE);
              }
           }
         break;
         case ENUM_EA_RUN_WITHOUT_FILTER:
            s.filter.InitTypeValue(MAPPING_NULL);  // 设置为不需要映射，即过滤器失效
            break;
         default:
            break;
        }
      Manager.AddStrategy(s);
     }

  }
//+------------------------------------------------------------------+
