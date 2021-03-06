//+------------------------------------------------------------------+
//|                              ReverseLastMaxMinFilterStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseFilterStrategy.mqh"
#include <strategy_czj\common\czj_function.mqh>
//+------------------------------------------------------------------+
//|              基于过去极值点的支撑阻力反转策略                    |
//+------------------------------------------------------------------+
class CReverseLastMaxMinFilterStrategy:public CBaseFilterStrategy
  {
protected:
   int               adj_bar; // 判断极值的相邻bar数
   int               search_bar; // 搜寻模式的bar数
   int               slip_points;   // 同极值点的距离
   double            high_price[];  // High序列
   double            low_price[];   // low序列
   int               max_index;
   int               min_index;
   double            max_price;  // 模式中的最大值
   double            min_price;  // 模式中的最小值  
public:
                     CReverseLastMaxMinFilterStrategy(void){};
                    ~CReverseLastMaxMinFilterStrategy(void){};
   void              SetPatternParameter(int bar_search=30,int bar_adj=5,int points_slip=50);
protected:
   virtual void      CheckLongPositionOpenOnTick();
   virtual void      CheckShortPositionOpenOnTick();
   virtual void      PatternCalOnBar();  // bar事件上的模式计算                      
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseLastMaxMinFilterStrategy::SetPatternParameter(int bar_search=30,int bar_adj=5,int points_slip=50)
  {
   search_bar=bar_search;
   adj_bar=bar_adj;
   slip_points=points_slip;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseLastMaxMinFilterStrategy::PatternCalOnBar(void)
  {
   CopyHigh(ExpertSymbol(),Timeframe(),1,search_bar,high_price);
   CopyLow(ExpertSymbol(),Timeframe(),1,search_bar,low_price);
   bool find_max=false,find_min=false;
   max_price=DBL_MAX;
   min_price=DBL_MIN;
   max_index=0;
   min_index=0;
   for(int i=search_bar-adj_bar;i>adj_bar;i--)
     {
      if(!find_max && IsMaxLeftRight(high_price,i,adj_bar,adj_bar))
        {
         max_price=high_price[i];
         max_index=i;
         find_max=true;
        }
      if(!find_min && IsMinLeftRight(low_price,i,adj_bar,adj_bar))
        {
         min_price=low_price[i];
         min_index=i;
         find_min=true;
        }
      if(find_max && find_min) break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseLastMaxMinFilterStrategy::CheckLongPositionOpenOnTick(void)
  {
   if(max_price-min_price<300*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return;
   if(positions.open_buy>0 && DistHoursToLastLong()<time_dist_hour) return; // 当前持多仓且距离最后一次开仓时间小于给定值，不进行开仓
   if(latest_tick.ask<min_price-200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return;
   if(latest_tick.ask<min_price-slip_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) OpenLongPosition(0.01);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CReverseLastMaxMinFilterStrategy::CheckShortPositionOpenOnTick(void)
  {
   if(max_price-min_price<300*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return;
   if(positions.open_sell>0 && DistHoursToLastShort()<time_dist_hour) return; // 当前持空仓且距离最后一次开仓时间小于给定值，不进行开仓
   if(latest_tick.bid>max_price+200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) return;
   if(latest_tick.bid>max_price+slip_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) OpenShortPosition(0.01);
  }
//+------------------------------------------------------------------+
