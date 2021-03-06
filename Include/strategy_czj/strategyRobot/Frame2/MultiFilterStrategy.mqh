//+------------------------------------------------------------------+
//|                                          MultiFilterStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseFilterStrategy.mqh"
#include <strategy_czj\common\czj_function.mqh>
#include <Arrays\ArrayDouble.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SignalType
  {
   ENUM_SIGNAL_TYPE_FIBO,// Fibo回调信号
   ENUM_SIGNAL_TYPE_SR_LEVEL, // 水平支撑阻力信号
   ENUM_SIGNAL_TYPE_RETRACE,  // 回调固定点位信号
  };
//+------------------------------------------------------------------+
//|       多触发条件+模式过滤器的策略                                |
//+------------------------------------------------------------------+
class CMultiFilterStrategy:public CBaseFilterStrategy
  {
private:
   double            high_price[];
   double            low_price[];
public:
                     CMultiFilterStrategy(void){};
                    ~CMultiFilterStrategy(void){};
protected:
   virtual void      CheckLongPositionOpenOnTick();
   virtual void      CheckShortPositionOpenOnTick();
   virtual void      PatternCalOnBar();  // bar事件上的模式计算 
   void              CheckLongOnSignalSrLevel();
   void              CheckShortOnSignalSrLevel();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiFilterStrategy::CheckLongPositionOpenOnTick(void)
  {
   CheckLongOnSignalSrLevel();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiFilterStrategy::CheckShortPositionOpenOnTick(void)
  {
   CheckShortOnSignalSrLevel();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiFilterStrategy::PatternCalOnBar(void)
  {
   CopyHigh(ExpertSymbol(),PERIOD_H1,0,1000,high_price);
   CopyLow(ExpertSymbol(),PERIOD_H1,0,1000,low_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiFilterStrategy::CheckLongOnSignalSrLevel(void)
  {
   if(positions.open_buy>0 && DistHoursToLastLong()<time_dist_hour) return; // 当前持空仓且距离最后一次开仓时间小于给定值，不进行开仓
   if(MathAbs(DistPointsToLastLong())<300) return;
   int num_control=40;
   CArrayDouble support;
   for(int i=num_control;i<1000-num_control;i++)
     {
      if(IsMinLeftRight(low_price,i,num_control,num_control))
        {
         support.Add(low_price[i]);
         if(latest_tick.ask<low_price[i] && latest_tick.bid>low_price[i]-200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) OpenLongPosition(0.01);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiFilterStrategy::CheckShortOnSignalSrLevel(void)
  {
   if(positions.open_sell>0 && DistHoursToLastShort()<time_dist_hour) return; // 当前持空仓且距离最后一次开仓时间小于给定值，不进行开仓
   if(MathAbs(DistPointsToLastShort())<300) return;
   int num_control=40;

   CArrayDouble resistance;
   for(int i=num_control;i<1000-num_control;i++)
     {
      if(IsMaxLeftRight(high_price,i,num_control,num_control))
        {
         resistance.Add(high_price[i]);
         if(latest_tick.bid>high_price[i] && latest_tick.ask<high_price[i]+200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) OpenShortPosition(0.01);
        }
     }

  }
//+------------------------------------------------------------------+
