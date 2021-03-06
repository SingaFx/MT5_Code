//+------------------------------------------------------------------+
//|                                      GridShockStrategyWithTP.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "震荡网格策略--带止盈线出场"
#property description "增加的参数设置：网格间距，止盈位置，止盈方式"
#include <strategy_czj\strategyGrid\GridFrame\GridShockBaseOperateWithTP.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridShockStrategyWithTP:public CGridShockBaseOperateWithTP
  {
protected:
   int               tp_points; // 止盈点位
   GridWinType       win_type;   // 止盈方式
public:
                     CGridShockStrategyWithTP(void){SetGridParameters();};
                    ~CGridShockStrategyWithTP(void){};
   void              SetGridParameters(int gap_grid,int points_tp,GridWinType type_win);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              BuildLongCaseOperate();
   void              BuildShortCaseOperate();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyWithTP::SetGridParameters(int gap_grid=300,int points_tp=600,GridWinType type_win=ENUM_GRID_WIN_LAST)
  {
   grid_gap_buy=gap_grid;
   grid_gap_sell=gap_grid;
   tp_points=points_tp;
   win_type=type_win;
  }
void CGridShockStrategyWithTP::OnEvent(const MarketEvent &event)
   {
    if(event.symbol==ExpertSymbol()&& event.type==MARKET_EVENT_BAR_OPEN)
      {
       RefreshTickPrice();
       RefreshPositionState();
       if(pos_state.num_buy==0) BuildLongCaseOperate();
       else if(DistanceAtLastLongPositionPrice()>grid_gap_buy) BuildLongCaseOperate();
       
       if(pos_state.num_sell==0) BuildShortCaseOperate();
       else if(DistanceAtLastShortPositionPrice()>grid_gap_sell) BuildShortCaseOperate();
      }
   }
void CGridShockStrategyWithTP::BuildLongCaseOperate(void)
   {
    switch(win_type)
      {
       case ENUM_GRID_WIN_COST :
         BuildLongPositionWithCostTP(tp_points);
         break;
       case ENUM_GRID_WIN_LAST:
          BuildLongPositionWithTP(tp_points);
          break;
       default:
         break;
      }
   }
void CGridShockStrategyWithTP::BuildShortCaseOperate(void)
   {
     switch(win_type)
      {
       case ENUM_GRID_WIN_COST :
         BuildShortPositionWithCostTP(tp_points);
         break;
       case ENUM_GRID_WIN_LAST:
          BuildShortPositionWithTP(tp_points);
          break;
       default:
         break;
      }
   }
//+------------------------------------------------------------------+
