//+------------------------------------------------------------------+
//|                                             HedgeBaseOperate.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "对冲网格的基本操作"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayLong.mqh>
#include <strategy_czj\common\strategy_common.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedgeBaseOperate:public CStrategy
  {
protected:
   int               ind_handle;   // 指标句柄
   double            ind_value[];   // 指标数值
   CArrayLong        long_pos_id;   // 多头仓位列表
   CArrayLong        short_pos_id;  // 空头仓位列表
   MqlTick           latest_price;  // 最新报价
public:
   PositionInfor     pos_state;
public:
                     CHedgeBaseOperate(void){};
                    ~CHedgeBaseOperate(void){};
   virtual bool      IsUpSignal();  // 上涨信号
   virtual bool      IsDownSignal();   // 下跌信号
   virtual void      RefreshIndValues();  // 刷新指标值
   void              RefreshTickPrice(){SymbolInfoTick(ExpertSymbol(),latest_price);};   // 刷新最新报价
   void              RefreshPositionState(); // 刷新仓位信息
   void              BuildLongPositionToHedgeShortRisk(double l); // 开多头对冲空头风险
   void              BuildShortPositionToHedgeLongRisk(double l); // 开空头对冲多头风险
   void              CloseLongPosition();  // 多头平仓
   void              CloseShortPosition();   // 空头平仓 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::BuildLongPositionToHedgeShortRisk(double l)
  {
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,l,latest_price.ask,0,0))
     {
      long_pos_id.Add(Trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::BuildShortPositionToHedgeLongRisk(double l)
  {
   if(Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,l,latest_price.bid,0,0))
     {
      short_pos_id.Add(Trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::CloseLongPosition(void)
  {
   for(int i=0;i<long_pos_id.Total();i++)
     {
      Trade.PositionClose(long_pos_id.At(i));
     }
   long_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::CloseShortPosition(void)
  {
   for(int i=0;i<short_pos_id.Total();i++)
     {
      Trade.PositionClose(short_pos_id.At(i));
     }
   short_pos_id.Clear();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedgeBaseOperate::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<long_pos_id.Total();i++)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_buy+=1;
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
     }
   for(int i=0;i<short_pos_id.Total();i++)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.num_sell+=1;
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
     }
  }
//+------------------------------------------------------------------+
