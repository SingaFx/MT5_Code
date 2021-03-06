//+------------------------------------------------------------------+
//|                                            GridTrendStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "趋势网格--设定上下趋势突破边界"
#property description "当价格运动的方向突破的边界与上次突破的边界相反时，进行该方向的趋势单"
#property description "检测多空所有仓位的盈利情况，如果满足止盈条件就全部平仓"

#include <strategy_czj\strategyGrid\GridFrame\GridTrendBaseOperate.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridTrendStrategy:public CGridTrendBaseOperate
  {
protected:
   int               boundary_width;
   double            tp_per_lots;
   double            tp_total;
public:
                     CGridTrendStrategy(void){SetGridParameters();};
                    ~CGridTrendStrategy(void){};
   void              SetGridParameters(int b_width,double per_lots_tp,double total_tp);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose();
   virtual void      CheckPositionOpen();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::SetGridParameters(int b_width=100,double per_lots_tp=100,double total_tp=20)
  {
   boundary_width=b_width;
   tp_per_lots=per_lots_tp;
   tp_total=total_tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickPrice();
      RefreshPositionState();
      CheckPositionClose();
      RefreshPositionState();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::CheckPositionClose(void)
  {
   if(pos_state.GetTotalNum()==0) return;
   if(pos_state.GetProfitsPerLots()>tp_per_lots||pos_state.GetProfitsTotal()>tp_total)
     {
      CloseAllLongPosition();
      CloseAllShortPosition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategy::CheckPositionOpen(void)
  {
   if(pos_state.GetTotalNum()==0)
     {
      BuildLongPosition();
      return;
     }
   if(last_pos_type==POSITION_TYPE_BUY)
     {
      if(DistanceAtLastLongPositionPrice()>boundary_width) BuildShortPosition();
     }
   else
     {
      if(DistanceAtLastShortPositionPrice()>boundary_width) BuildLongPosition();
     }
  }
//+------------------------------------------------------------------+
