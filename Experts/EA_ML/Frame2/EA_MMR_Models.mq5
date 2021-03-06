//+------------------------------------------------------------------+
//|                                                EA_MMR_Models.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRobot\Frame2\MaxMinReverse.mqh>
#include <strategy_czj\common\strategy_common.mqh>

sinput string InpStr1="*****品种选择*****"; // 标题  ——————>
input int InpSym=1;     // 0->Symbol,1->Symbol7,2->Symbol28

sinput string InpStr2="*****基本参数设定*****"; // 标题  ——————>
input int InpTpPoints=500; // 止盈点数
input int InpSlPoints=500; // 止损点数
input int InpSearchBar=20; // 模式识别Bar数
input int InpAdjBar=5; // 相邻Bar数
input int InpSepTime=4; // 相邻两单隔开的时间(小时)
input int InpSlip=-80;  // 同支撑阻力的距离(负值还未触及,正值已经超过)

sinput string InpStr3="*****模式识别优化选项*****"; // 标题  ——————>
input bool InpUseFilter=true; // 是否使用模式过滤器

input string InpLongPatternIndex="0";  // 做多模式索引序列
input string InpShortPatternIndex="1";  // 做空模式索引序列

sinput string InpStr4="*****构造分类器的方式*****"; // 标题  ——————>
input bool InpUseDoubleMa=true;  // 是否使用双均线
input bool InpUseRsi=true; // 是否使用RSI
                           //input bool InpUseCandle=true; // 是否使用蜡烛图

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 品种组合设置
   string syms[];
   switch(InpSym)
     {
      case 0 :
         ArrayResize(syms,1);
         syms[0]=_Symbol;
         break;
      case 1:
         ArrayCopy(syms,SYMBOLS_7);
         break;
      case 2:
         ArrayCopy(syms,SYMBOLS_28);
         break;
      default:
         break;
     }
//--- 多空模式组合索引     
   string i_long_str[],i_short_str[];
   int index_long[],index_short[];
   int num_long=StringSplit(InpLongPatternIndex,StringGetCharacter(",",0),i_long_str);
   int num_short=StringSplit(InpShortPatternIndex,StringGetCharacter(",",0),i_short_str);
   ArrayResize(index_long,num_long);
   ArrayResize(index_short,num_short);
   for(int i=0;i<num_long;i++) index_long[i]=int(i_long_str[i]);
   for(int i=0;i<num_short;i++) index_short[i]=int(i_short_str[i]);

   for(int i=0;i<ArraySize(syms);i++)
     {
      CMaxMinReverse *s=new CMaxMinReverse();
      s.ExpertMagic(10+i);
      s.ExpertName("支撑阻力反转策略"+i);
      s.ExpertSymbol(syms[i]);
      s.Timeframe(_Period);
      s.SetTpAndSl(InpTpPoints,InpSlPoints);
      s.SetOpenTimeDist(InpSepTime);
      s.SetPatternParameter(InpSearchBar,InpAdjBar,InpSlip);

      if(InpUseFilter) // 使用过滤器的情况,对过滤器进行相应设置
        {
         s.filter.SetSymbol(syms[i]); // 设置过滤器品种
         if(InpUseDoubleMa) s.filter.CreateClassify(CLASSIFY_TYPE_DOUBLE_MA);   // 在filter中创建双均线特征分类器
         if(InpUseRsi) s.filter.CreateClassify(CLASSIFY_TYPE_RSI);  // 在filter中创建RSI特征分类器 
         s.filter.ResetTotalFilterNum();  // 重新设置filter的类别数(根据当前的特征分类器计算)
         s.filter.InitTypeValue(MAPPING_NO_OPERATE); // 将所有的filter分类对应操作设置为禁止(买卖)操作
         for(int j=0;j<num_long;j++)
           {
            if(index_long[j]>=s.filter.GetTotalFilterNum()) continue;
            s.filter.SetMappingTypeAt(index_long[j],MAPPING_LONG_OPERATE);
           }
         for(int j=0;j<num_short;j++)
           {
            if(index_short[j]>=s.filter.GetTotalFilterNum()) continue;
            s.filter.SetMappingTypeAt(index_short[j],MAPPING_SHORT_OPERATE);
           }
        }
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
