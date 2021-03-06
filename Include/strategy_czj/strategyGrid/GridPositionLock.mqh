//+------------------------------------------------------------------+
//|                                             GridPositionLock.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <strategy_czj\common\strategy_common.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridPositionLock:public CStrategy
  {
private:
   double            coef;
   double            init_lots;
   double            last_buy_lots;
   double            last_sell_lots;
   double            last_buy_price;
   double            last_sell_price;
   int handle_rsi;
   int handle_ma;
   double rsi_value[];
   double ma_value[];

   int               grid_points;
   MqlTick           latest_price;
   PositionInfor     pos_state;
   CArrayLong        pos_id_buy;
   CArrayLong        pos_id_sell;

protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              RefreshPositionState();
   void              CheckPositionClose();
   void              CheckPositionOpen();
public:
                     CGridPositionLock(void);
                    ~CGridPositionLock(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGridPositionLock::CGridPositionLock(void)
  {
   coef=1.2;
   init_lots=0.01;
   grid_points=300;
   handle_rsi=iRSI(ExpertSymbol(),Timeframe(),20,PRICE_CLOSE);
   handle_ma=iMA(ExpertSymbol(),Timeframe(),800,0,MODE_SMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionLock::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      CopyBuffer(handle_rsi,0,0,1,rsi_value);
      CopyBuffer(handle_ma,0,0,1,ma_value);
      SymbolInfoTick(ExpertSymbol(),latest_price);
      RefreshPositionState();
      CheckPositionClose();
      RefreshPositionState();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionLock::RefreshPositionState(void)
  {
   pos_state.Init();
   for(int i=0;i<pos_id_buy.Total();i++)
     {
      PositionSelectByTicket(pos_id_buy.At(i));
      pos_state.num_buy++;
      pos_state.lots_buy+=PositionGetDouble(POSITION_VOLUME);
      pos_state.profits_buy+=PositionGetDouble(POSITION_PROFIT);
     }
   for(int i=0;i<pos_id_sell.Total();i++)
     {
      PositionSelectByTicket(pos_id_sell.At(i));
      pos_state.num_sell++;
      pos_state.lots_sell+=PositionGetDouble(POSITION_VOLUME);
      pos_state.profits_sell+=PositionGetDouble(POSITION_PROFIT);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionLock::CheckPositionClose(void)
  {
   if(pos_state.num_buy>0 && pos_state.profits_buy/pos_state.lots_buy>300)
     {
      for(int i=0;i<pos_id_buy.Total();i++)
        {
         Trade.PositionClose(pos_id_buy.At(i),"buy_close");
        }
      pos_id_buy.Clear();
     }
   if(pos_state.num_sell>0 && pos_state.profits_sell/pos_state.lots_sell>300)
     {
      for(int i=0;i<pos_id_sell.Total();i++)
        {
         Trade.PositionClose(pos_id_sell.At(i),"sell_close");
        }
      pos_id_sell.Clear();
     }
//if((pos_state.lots_buy+pos_state.lots_sell)>0)
//  {
//      Print("*****Profits:",(pos_state.profits_buy+pos_state.profits_sell)/(pos_state.lots_buy+pos_state.lots_sell));   
//  }

//if(pos_state.num_buy+pos_state.num_sell>0 && (pos_state.profits_buy+pos_state.profits_sell)/(pos_state.lots_buy+pos_state.lots_sell)>30)
//  {
//   for(int i=0;i<pos_id_buy.Total();i++)
//     {
//      Trade.PositionClose(pos_id_buy.At(i),"buy_close");
//     }
//   pos_id_buy.Clear();
//   for(int i=0;i<pos_id_sell.Total();i++)
//     {
//      Trade.PositionClose(pos_id_sell.At(i),"sell_close");
//     }
//   pos_id_sell.Clear();
//  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridPositionLock::CheckPositionOpen(void)
  {
//// 初始开仓
//if(pos_state.num_buy==0&&pos_state.num_sell==0)
//  {
//   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots,latest_price.ask,0,0,"first_buy");
//   last_buy_price=latest_price.ask;
//   pos_id_buy.Add(Trade.ResultOrder());
//   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots,latest_price.bid,0,0,"first_sell");
//   last_sell_price=latest_price.bid;
//   pos_id_sell.Add(Trade.ResultOrder());
//   return;
//  }
//// 卖仓逆势
//if(pos_state.num_sell!=0&&(latest_price.bid-last_sell_price)*MathPow(10,Digits())>300)
//  {
//   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,NormalizeDouble(pos_state.lots_sell/coef,2),latest_price.ask,0,0,"first_buy");
//   pos_id_buy.Add(Trade.ResultOrder());
//   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots,latest_price.bid,0,0,"sell-add"+string(pos_state.num_sell));
//   pos_id_sell.Add(Trade.ResultOrder());
//   return;
//  }
//if(pos_state.num_buy!=0&&pos_state.num_sell==0)
//  {
//   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots,latest_price.ask,0,0,"buy-add"+string(pos_state.num_buy));
//   pos_id_buy.Add(Trade.ResultOrder());
//   Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,NormalizeDouble(pos_state.lots_buy/coef,2),latest_price.bid,0,0,"first_sell");
//   pos_id_sell.Add(Trade.ResultOrder());
//   return;
//  }
   if(latest_price.ask<ma_value[0]-1000/MathPow(10,Digits())||latest_price.ask>ma_value[0]+1000/MathPow(10,Digits())) return;
   if(pos_state.num_buy==0)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots,latest_price.ask,0,0,"first_buy");
      last_buy_price=latest_price.ask;
      pos_id_buy.Add(Trade.ResultOrder());
     }
   else if(pos_state.num_buy>0 && latest_price.ask>last_buy_price+300/MathPow(10,Digits()))
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,init_lots,latest_price.ask,0,0,"buy_add_positive");
      last_buy_price=latest_price.ask;
      pos_id_buy.Add(Trade.ResultOrder());
     }
   else if(pos_state.num_buy>0 && latest_price.ask<last_buy_price-300/MathPow(10,Digits())&&rsi_value[0]<30)
     {
      Print("lots:****",init_lots*MathPow(coef,pos_state.num_buy));
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,NormalizeDouble(init_lots*MathPow(coef,pos_state.num_buy),2),latest_price.ask,0,0,"buy_add_negative");
      last_buy_price=latest_price.ask;
      pos_id_buy.Add(Trade.ResultOrder());
     }

   if(pos_state.num_sell==0)
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots,latest_price.bid,0,0,"first_sell");
      last_sell_price=latest_price.bid;
      pos_id_sell.Add(Trade.ResultOrder());
     }
   else if(pos_state.num_sell>0 && latest_price.bid<last_sell_price-300/MathPow(10,Digits()))
     {
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,init_lots,latest_price.bid,0,0,"sell_add_positive");
      last_sell_price=latest_price.bid;
      pos_id_sell.Add(Trade.ResultOrder());
     }
   else if(pos_state.num_sell>0 && latest_price.bid>last_sell_price+300/MathPow(10,Digits())&&rsi_value[0]>70)
     {
      Print("lots:****",init_lots*MathPow(coef,pos_state.num_sell));
      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,NormalizeDouble(init_lots*MathPow(coef,pos_state.num_sell),2),latest_price.bid,0,0,"sell_add_negative");
      last_sell_price=latest_price.bid;
      pos_id_sell.Add(Trade.ResultOrder());
     }
  }
//+------------------------------------------------------------------+
