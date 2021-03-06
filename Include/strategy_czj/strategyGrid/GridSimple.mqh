//+------------------------------------------------------------------+
//|                                                   GridSimple.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridSimple:public CStrategy
  {
private:
   MqlDateTime       dt;
protected:
   CGridBaseOperate  grid_operator;
   int               points_add;
   int               points_win;
   GridWinType       win_out_type;
public:
                     CGridSimple(void){};
                    ~CGridSimple(void){};
   void              Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type,int max_pos);
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling=ORDER_FILLING_FOK) {grid_operator.SetTypeFilling(filling);};
   void              ReBuildPositionState(){grid_operator.ReBuildPositionState();}; // 重挂策略时，获取上次的加仓价格
   void              ReTP(int tp_p){grid_operator.ReModifyTP(tp_p);};
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimple::Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type,int max_pos)
  {
   grid_operator.ExpertMagic(ExpertMagic());
   grid_operator.ExpertSymbol(ExpertSymbol());
   grid_operator.Init(l_base,l_type,max_pos);
   grid_operator.ReBuildPositionState();
   points_add=add_points;
   points_win=win_points;
   win_out_type=w_type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimple::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_operator.RefreshPositionState();
      grid_operator.RefreshTickPrice();
      //TimeToStruct(TimeCurrent(),dt);
      //if(dt.hour*60+dt.min>23*60+50 || dt.hour*0+dt.min<10) // 前后日切换时候的20分钟不进行开仓交易
      //  {
      //   return;
      //  }
      switch(win_out_type)
        {
         case ENUM_GRID_WIN_COST :
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add) grid_operator.BuildShortPositionWithCostTP(points_win);
            break;
         case ENUM_GRID_WIN_LAST:
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithTP(points_win);
            else
              {
               if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add)
                 {
                  Print("多头加仓条件成立:",grid_operator.DistanceAtLastBuyPrice(),">",points_add);
                  grid_operator.BuildLongPositionWithTP(points_win);
                 }
              }
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithTP(points_win);
            else
              {
               if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add)
                 {
                  Print("空头加仓条件成立:",grid_operator.DistanceAtLastSellPrice(),">",points_add);
                  grid_operator.BuildShortPositionWithTP(points_win);
                 }
              }
            break;
         default:
            break;
        }
     }
  }
//+------------------------------------------------------------------+
