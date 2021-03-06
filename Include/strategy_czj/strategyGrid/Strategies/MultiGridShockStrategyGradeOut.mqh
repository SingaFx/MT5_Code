//+------------------------------------------------------------------+
//|                               MultiGridShockStrategyGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "震荡网格:多网格+分级出场"
#property description "品种出现多空不均衡时，开启对冲网格,降低不均衡度"
#property description "优先出场风险大的网格"

#include "GridShockStrategyGradeOut.mqh"
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultiGridShockStrategyGradeOut:public CGridShockStrategyGradeOut
  {
protected:
   CArrayObj         grid_operator_long;   // 多头子网格
   CArrayObj         grid_operator_short;  // 空头子网格
   int               id;
   double            last_grid_long_open; // 最后一次多头网格开仓价
   double            last_grid_short_open; // 最后一次空头网格开仓价
   bool              new_add_long_no_hedge;
   bool              new_add_short_no_hedge;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      ShortPositionCloseCheck();
   virtual void      LongPositionCloseCheck();
   void              AddNewLongGridStrategy(double b_lots=0.01);
   void              AddNewShortGridStrategy(double b_lots=0.01);
   void              RiskControl();
public:
                     CMultiGridShockStrategyGradeOut(void){};
                    ~CMultiGridShockStrategyGradeOut(void){};
   virtual void      CheckPositionClose();
   virtual void      CheckPositionOpen();
   virtual void      RefreshPositionState();  // 刷新仓位信息 --刷新子策略的tick报价，仓位信息，计算总仓位信息

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RiskControl();
      CheckPositionClose();
      RiskControl();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::RefreshPositionState(void)
  {
   RefreshTickPrice();
   pos_state.Init();
   for(int i=0;i<grid_operator_long.Total();i++)
     {
      CGridShockStrategyGradeOut *grid_opt=grid_operator_long.At(i);
      grid_opt.RefreshTickPrice();
      grid_opt.RefreshPositionState();
      pos_state.lots_buy+=grid_opt.pos_state.lots_buy;
      pos_state.num_buy++;
      pos_state.profits_buy+=grid_opt.pos_state.profits_buy;
     }
   for(int i=0;i<grid_operator_short.Total();i++)
     {
      CGridShockStrategyGradeOut *grid_opt=grid_operator_short.At(i);
      grid_opt.RefreshTickPrice();
      pos_state.lots_sell+=grid_opt.pos_state.lots_sell;
      pos_state.num_sell++;
      pos_state.profits_sell+=grid_opt.pos_state.profits_sell;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::CheckPositionClose(void)
  {
   LongPositionCloseCheck();
   ShortPositionCloseCheck();
   
   //if(pos_state.GetLotsBuyToSell()>-0.05) LongPositionCloseCheck();
   //if(pos_state.GetLotsBuyToSell()<0.05) ShortPositionCloseCheck();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::LongPositionCloseCheck(void)
  {
   for(int i=0;i<grid_operator_long.Total();i++) // 遍历多头网格
     {
      CGridShockStrategyGradeOut *grid_opt=grid_operator_long.At(i);
      grid_opt.CheckPositionClose();
      grid_opt.RefreshPositionState();
      if(grid_opt.pos_state.num_buy==0) grid_operator_long.Delete(i);
      RefreshPositionState();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::ShortPositionCloseCheck(void)
  {
   for(int i=0;i<grid_operator_short.Total();i++)
     {
      CGridShockStrategyGradeOut *grid_opt=grid_operator_short.At(i);
      grid_opt.CheckPositionClose();
      grid_opt.RefreshPositionState();
      if(grid_opt.pos_state.num_sell==0) grid_operator_short.Delete(i);
      RefreshPositionState();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::RiskControl(void)
  {
   RefreshPositionState();
   //if(pos_state.GetLotsBuyToSell()>0.1)
   //  {
   //   for(int i=0;i<grid_operator_long.Total();i++)
   //     {
   //      CGridShockStrategyGradeOut *grid_opt=grid_operator_long.At(i);
   //      grid_opt.SetBuyTP(tp_total_buy/2,tp_per_lots_buy/2);
   //     }
   //  }
   //else if(pos_state.GetLotsBuyToSell()<-0.1)
   //  {
   //   for(int i=0;i<grid_operator_short.Total();i++)
   //     {
   //      CGridShockStrategyGradeOut *grid_opt=grid_operator_short.At(i);
   //      grid_opt.SetBuyTP(tp_total_sell/2,tp_per_lots_sell/2);
   //     }
   //  }
   if(pos_state.GetLotsBuyToSell()>0.1)
     {
      if(grid_operator_short.Total()<3&&new_add_long_no_hedge&&latest_price.bid-last_grid_long_open>200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
        {
         AddNewShortGridStrategy();
         new_add_long_no_hedge=false;
        }
     }
   else if(pos_state.GetLotsBuyToSell()<-0.1)
          {
           if(grid_operator_long.Total()<3&&new_add_short_no_hedge&&last_grid_short_open-latest_price.ask>200*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
             {
              AddNewLongGridStrategy();
              new_add_short_no_hedge=false;
             }
          }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::CheckPositionOpen(void)
  {
   if(pos_state.num_buy==0) AddNewLongGridStrategy();
   if(pos_state.num_sell==0) AddNewShortGridStrategy();
// 进行多头仓位加仓操作
   int counter=0;
   for(int i=0;i<grid_operator_long.Total();i++)
     {
      if(pos_state.GetLotsBuyToSell()>0&& last_grid_long_open-latest_price.ask<100*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) break;
      CGridShockStrategyGradeOut *grid_opt=grid_operator_long.At(i);
      grid_opt.RefreshTickPrice();
      if(grid_opt.DistanceAtLastLongPositionPrice()>grid_opt.GetGridGapBuy())
        {
         grid_opt.BuildLongPosition();
         last_grid_long_open=latest_price.ask;
         new_add_long_no_hedge=true;
         counter++;
        }
      if(pos_state.GetLotsBuyToSell()>0 && counter>0) break;
     }
// 进行空头仓位加仓操作
   counter=0;
   for(int i=0;i<grid_operator_short.Total();i++)
     {
      if(pos_state.GetLotsBuyToSell()<0 && latest_price.bid-last_grid_short_open<100*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT)) break;
      CGridShockStrategyGradeOut *grid_opt=grid_operator_short.At(i);
      grid_opt.RefreshTickPrice();
      if(grid_opt.DistanceAtLastShortPositionPrice()>grid_opt.GetGridGapSell())
        {
         grid_opt.BuildShortPosition();
         last_grid_short_open=latest_price.bid;
         new_add_short_no_hedge=true;
         counter++;
        }
      if(pos_state.GetLotsBuyToSell()<0 && counter>0) break;
     }
//   根据多空风险情况，增开对冲网格
//if(pos_state.GetLotsBuyToSell()>0.1 && grid_operator_short.Total()<2)
//  {
//   AddNewShortGridStrategy(0.02);
//  }
//else if(pos_state.GetLotsBuyToSell()<-0.1 && grid_operator_long.Total()<2)
//  {
//   AddNewLongGridStrategy(0.02);
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::AddNewLongGridStrategy(double b_lots=0.01)
  {
   id++;
   CGridShockStrategyGradeOut *grid_opt=new CGridShockStrategyGradeOut();
   grid_opt.ExpertMagic(ExpertMagic()+id);
   grid_opt.ExpertName(ExpertName()+"-"+string(id));
   grid_opt.ExpertSymbol(ExpertSymbol());
   grid_opt.SetLotsParameter(b_lots,lots_type,num_pos_1);
   grid_opt.SetGridParameter(grid_gap_buy,tp_per_lots_buy,tp_total_buy);
   grid_opt.BuildLongPosition();
   grid_operator_long.Add(grid_opt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiGridShockStrategyGradeOut::AddNewShortGridStrategy(double b_lots=0.01)
  {
   id++;
   CGridShockStrategyGradeOut *grid_opt=new CGridShockStrategyGradeOut();
   grid_opt.ExpertMagic(ExpertMagic()+id);
   grid_opt.ExpertName(ExpertName()+"-"+string(id));
   grid_opt.ExpertSymbol(ExpertSymbol());
   grid_opt.SetLotsParameter(b_lots,lots_type,num_pos_1);
   grid_opt.SetGridParameter(grid_gap_sell,tp_per_lots_sell,tp_total_sell);
   grid_opt.BuildShortPosition();
   grid_operator_short.Add(grid_opt);
  }
//+------------------------------------------------------------------+
