//+------------------------------------------------------------------+
//|                                                 BaseStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBaseStrategy:public CStrategy
  {
private:
   double            tp_price;  // 止盈价格
   double            sl_price;  // 止损价格  
   datetime          last_long_time;   // 最后一次做多的时间
   datetime          last_short_time;  // 最后一次做空的时间
   string            order_comment; // 订单注释
protected:
   MqlTick           latest_tick; // 最新的tick报价
   int               tp_points;  // 止盈点数
   int               sl_points;  // 止损点数
   int               time_dist_hour;  // 两次开仓的最小时间差
protected:
   void              OpenLongPosition(double l);   // 开多仓
   void              OpenShortPosition(double l);  // 开空仓
   int               DistHoursToLastLong();  // 距离上次开多头的小时
   int               DistHoursToLastShort(); // 距离上次开空头的小时
public:
                     CBaseStrategy(void){};
                    ~CBaseStrategy(void){};
   void              SetTpAndSl(int tp=500,int sl=500); // 设置止盈和止损位
   void              SetOpenTimeDist(int hours=4); // 设置两次开仓最小相隔时间(小时)
   void              SetOrderComment(string comment_order=NULL);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseStrategy::SetTpAndSl(int tp=500,int sl=500)
  {
   tp_points=tp;
   sl_points=sl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBaseStrategy::SetOpenTimeDist(int hours=4)
  {
   time_dist_hour=hours;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBaseStrategy::DistHoursToLastLong(void)
  {
   return (int)((latest_tick.time-last_long_time)/60/60);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBaseStrategy::DistHoursToLastShort(void)
  {
   return (int)((latest_tick.time-last_short_time)/60/60);
  }
void CBaseStrategy::SetOrderComment(string comment_order=NULL)
   {
    order_comment=comment_order;
   }  
//+------------------------------------------------------------------+
//|                开多仓操作                                        |
//+------------------------------------------------------------------+
void CBaseStrategy::OpenLongPosition(double l)
  {
   tp_price=latest_tick.ask+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   sl_price=latest_tick.ask-sl_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_tick.ask,sl_price,tp_price,order_comment)) last_long_time=latest_tick.time;
  }
//+------------------------------------------------------------------+
//|               开空仓操作                                         |
//+------------------------------------------------------------------+
void CBaseStrategy::OpenShortPosition(double l)
  {
   tp_price=latest_tick.bid-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   sl_price=latest_tick.bid+sl_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_tick.bid,sl_price,tp_price,order_comment)) last_short_time=latest_tick.time;
  }
//+------------------------------------------------------------------+
