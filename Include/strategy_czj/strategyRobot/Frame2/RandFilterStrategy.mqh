//+------------------------------------------------------------------+
//|                                                 RandStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "BaseFilterStrategy.mqh"
//+------------------------------------------------------------------+
//|             固定时间间隔随机产生交易信号的策略                   |
//+------------------------------------------------------------------+
class CRandFilterStrategy:public CBaseFilterStrategy
  {
private:
   int               rand_signal;
public:
                     CRandFilterStrategy(void){};
                    ~CRandFilterStrategy(void){};
protected:
   virtual void      CheckLongPositionOpenOnTick();
   virtual void      CheckShortPositionOpenOnTick();
   virtual void      PatternCalOnTick();  // tick事件上的模式计算              
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRandFilterStrategy::PatternCalOnTick(void)
  {
   rand_signal=MathRand()%3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CRandFilterStrategy::CheckLongPositionOpenOnTick(void)
  {
   //if(positions.open_buy>0&&DistHoursToLastLong()<time_dist_hour) return;
   if(DistHoursToLastLong()<time_dist_hour||DistHoursToLastShort()<time_dist_hour) return;
   if(rand_signal==1) OpenLongPosition(0.01);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRandFilterStrategy::CheckShortPositionOpenOnTick(void)
  {
   //if(positions.open_sell>0&&DistHoursToLastShort()<time_dist_hour) return;
   if(DistHoursToLastLong()<time_dist_hour||DistHoursToLastShort()<time_dist_hour) return;
   if(rand_signal==2) OpenShortPosition(0.01);
  }
//+------------------------------------------------------------------+
