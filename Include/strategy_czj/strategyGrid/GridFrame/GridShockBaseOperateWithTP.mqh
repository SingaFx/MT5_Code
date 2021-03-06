//+------------------------------------------------------------------+
//|                                   GridShockBaseOperateWithTP.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "带止盈点位出场震荡网格的基本操作集成"
#property description "设置止盈位置的两种方式，根据最后的价格设置，根据成本价格设置"
#property description "重构RefreshPositionState,因为带TP的出场的订单，不会清空long_pos_id和short_pos_id"
#include "GridShockBaseOperate.mqh"
//+------------------------------------------------------------------+
//|           带止盈点位的震荡网格策略基本操作集成                   |
//+------------------------------------------------------------------+
class CGridShockBaseOperateWithTP:public CGridShockBaseOperate
  {
public:
                     CGridShockBaseOperateWithTP(void){};
                    ~CGridShockBaseOperateWithTP(void){};
   virtual void      RefreshPositionState();  // 刷新仓位信息 -- 重新获取仓位ID, 刷新pos_state的状态                         
   //--- 不同的开仓操作     
   bool              BuildLongPositionWithTP(int tp_points);  // 多头建仓带止盈点位(根据最后一次价格)
   bool              BuildShortPositionWithTP(int tp_points);  // 空头建仓带止盈点位(根据最后一次价格)
   bool              BuildLongPositionWithCostTP(int tp_points);  // 多头建仓带止盈点位(根据成本价格)
   bool              BuildShortPositionWithCostTP(int tp_points);  // 空头建仓带止盈点位(根据成本价格)
   bool              BuildLongPositionWithCostTP(int tp_points,double open_lots);  // 指定手数多头建仓带止盈点位(根据成本价格)
   bool              BuildShortPositionWithCostTP(int tp_points,double open_lots);  // 指定手数空头建仓带止盈点位(根据成本价格)
   bool              ReSetLongPositionTP(double tp); // 多头仓位重新设置止盈位
   bool              ReSetShortPositionTP(double tp); // 空头仓位重新设置止盈位
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockBaseOperateWithTP::RefreshPositionState(void)
  {
   ReGetPosID();
   CGridBaseOperate::RefreshPositionState();
  }
//+------------------------------------------------------------------+
//|             带止盈点位开多头仓位--根据最后开多头的价格设置       |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::BuildLongPositionWithTP(int tp_points)
  {
   double lots_current_buy=CalLotsDefault(pos_state.num_buy+1,base_lots_buy);
   bool operator_success=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,ExpertSymbol()+":long(lp)-"+string(pos_state.num_buy+1));
   if(operator_success)
     {
      Print("多头开仓成功--品种对:",ExpertSymbol()," 成交价格:",Trade.ResultPrice());
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      double tp_price=latest_price.ask+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Print("long modify tp:",tp_price," latest_price:",latest_price.ask," tp_points:",tp_points);
      operator_success=ReSetLongPositionTP(tp_price);
     }
   else
     {
      Print("多头开仓失败--品种对:",ExpertSymbol()," 失败代码:",Trade.ResultRetcode());
     }
   return operator_success;
  }
//+------------------------------------------------------------------+
//|            止盈点位开空头仓位--根据最后开空头的价格设置          |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::BuildShortPositionWithTP(int tp_points)
  {
   double lots_current_sell=CalLotsDefault(pos_state.num_sell+1,base_lots_sell);
   bool operator_success=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,ExpertSymbol()+":short(lp)-"+string(pos_state.num_sell+1));
   if(operator_success)
     {
      Print("空头开仓成功--品种对:",ExpertSymbol()," 成交价格:",Trade.ResultPrice());
      last_open_short_price=latest_price.bid;
      short_pos_id.Add(Trade.ResultOrder());
      double tp_price=latest_price.bid-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      Print("short modify tp:",tp_price," latest_price:",latest_price.ask," tp_points:",tp_points);
      operator_success=ReSetShortPositionTP(tp_price);
     }
   else
     {
      Print("空头开仓失败--品种对:",ExpertSymbol()," 失败代码:",Trade.ResultRetcode());
     }
   return operator_success;
  }
//+------------------------------------------------------------------+
//|                 开多头--根据成本价设置止盈位                     |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::BuildLongPositionWithCostTP(int tp_points)
  {
   double lots_current_buy=CalLotsDefault(pos_state.num_buy+1,base_lots_buy);
   bool operator_success=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,lots_current_buy,latest_price.ask,0,0,ExpertSymbol()+":long(cost_price)-"+string(pos_state.num_buy+1));
   if(operator_success)
     {
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_long_price+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      operator_success=ReSetLongPositionTP(tp_price);
     }
   return operator_success;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::BuildLongPositionWithCostTP(int tp_points,double open_lots)
  {
   bool operator_success=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,open_lots,latest_price.ask,0,0,ExpertSymbol()+":long(cost_price)-"+string(pos_state.num_buy+1));
   if(operator_success)
     {
      last_open_long_price=latest_price.ask;
      long_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_long_price+tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      operator_success=ReSetLongPositionTP(tp_price);
     }
   return operator_success;
  }
//+------------------------------------------------------------------+
//|                 开空头--根据成本价设置止盈位                     |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::BuildShortPositionWithCostTP(int tp_points)
  {
   double lots_current_sell=CalLotsDefault(pos_state.num_sell+1,base_lots_sell);
   bool operator_success=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,lots_current_sell,latest_price.bid,0,0,ExpertSymbol()+":short(cost_price)-"+string(pos_state.num_sell+1));
   if(operator_success)
     {
      last_open_short_price=latest_price.bid;
      short_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_short_price-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      operator_success=ReSetShortPositionTP(tp_price);
     }
   return operator_success;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::BuildShortPositionWithCostTP(int tp_points,double open_lots)
  {
   bool operator_success=Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,open_lots,latest_price.bid,0,0,ExpertSymbol()+":short(cost_price)-"+string(pos_state.num_sell+1));
   if(operator_success)
     {
      last_open_short_price=latest_price.bid;
      short_pos_id.Add(Trade.ResultOrder());
      CalCostPrice();
      double tp_price=cost_short_price-tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      operator_success=ReSetShortPositionTP(tp_price);
     }
   return operator_success;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::ReSetLongPositionTP(double tp)
  {
   bool op_result=true;
   for(int i=0;i<long_pos_id.Total();i++)
     {
      int counter=0;
      bool modify_success=Trade.PositionModify(long_pos_id.At(i),0,tp);
      while(!modify_success && counter<5)
        {
         modify_success=Trade.PositionModify(long_pos_id.At(i),0,tp);
         counter++;
         Sleep(500);
        }
      if(!modify_success)
        {
         op_result=false;
         Print("多头设置止盈失败,仓位号:",long_pos_id.At(i)," ,尝试的次数:",counter);
        }
     }
   return op_result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridShockBaseOperateWithTP::ReSetShortPositionTP(double tp)
  {
   bool op_result=true;
   for(int i=0;i<short_pos_id.Total();i++)
     {
      int counter=0;
      bool modify_success=Trade.PositionModify(short_pos_id.At(i),0,tp);
      while(!modify_success && counter<5)
        {
         modify_success=Trade.PositionModify(short_pos_id.At(i),0,tp);
         counter++;
         Sleep(500);
        }
      if(!modify_success)
        {
         op_result=false;
         Print("空头设置止盈失败, 仓位号:",short_pos_id.At(i)," ,尝试的次数:",counter);
        }
     }
   return op_result;
  }
//+------------------------------------------------------------------+
