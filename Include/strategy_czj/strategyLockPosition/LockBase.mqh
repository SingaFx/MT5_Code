//+------------------------------------------------------------------+
//|                                                     LockBase.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "LockPosition.mqh"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                锁仓类型策略                                      |
//+------------------------------------------------------------------+
class CLockBase:public CStrategy
  {
protected:
   CArrayObj         pos_buy;  // 仓位信息
   CArrayObj         pos_sell;  // 仓位信息
   MqlTick           latest_price;
protected:
   virtual void      OnEvent(const MarketEvent &event);  // 事件处理
   virtual bool      BuySignal();   // 买信号
   virtual bool      SellSignal();  // 卖信号
   virtual bool      BaseBuy();
   virtual bool      BaseSell();
   virtual bool      HedgeBuySignal(); // 对冲买信号--卖信号
   virtual bool      HedgeSellSignal(); // 对冲买信号--卖信号
   virtual void      CheckPositionClose();
public:
                     CLockBase(void){};
                    ~CLockBase(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLockBase::BaseBuy(void)
  {
   //if(Close[1]>Open[1]&&latest_price.ask<Close[1]-(Close[1]-Open[1])*0.618) return true;
   //return false;
   double value[];
   CopyLow(ExpertSymbol(),Timeframe(),1,30,value);
   int index=ArrayMinimum(value);
   if(index<9&&latest_price.bid<value[index]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLockBase::BaseSell(void)
  {
   //if(Close[1]<Open[1]&&latest_price.bid>Close[1]+(Open[1]-Close[1])*0.618) return true;
   //return false;
   double value[];
   CopyHigh(ExpertSymbol(),Timeframe(),1,30,value);
   int index=ArrayMaximum(value);
   if(index<9&&latest_price.ask>value[index]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLockBase::BuySignal(void)
  {
   if(pos_buy.Total()==0) return BaseBuy();
   else
     {
      CLockPosition *pos=pos_buy.At(pos_buy.Total()-1);
      if(pos.IsHedge()&&BaseBuy()) return true;
      return false;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLockBase::SellSignal(void)
  {
   if(pos_sell.Total()==0) return BaseSell();
   else
     {
      CLockPosition *pos=pos_sell.At(pos_sell.Total()-1);
      if(pos.IsHedge()&&BaseSell()) return true;
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLockBase::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionClose();

      if(BuySignal())
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.02,latest_price.ask,0,0);
         CLockPosition *pos=new CLockPosition(Trade.ResultOrder());
         pos_buy.Add(pos);
        }
      if(SellSignal())
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.02,latest_price.bid,0,0);
         CLockPosition *pos=new CLockPosition(Trade.ResultOrder());
         pos_sell.Add(pos);
        }

      //if(pos_buy.Total()>0)
      //  {
      //   CLockPosition *pos1=pos_buy.At(pos_buy.Total()-1);
      //   if(!pos1.IsHedge() && pos1.MainPositionWinPoints()>300)
      //     {
      //      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,0,0);
      //      pos1.AddHedgePosition(Trade.ResultOrder());
      //     }
      //  }
      //if(pos_sell.Total()>0)
      //  {
      //   CLockPosition *pos2=pos_sell.At(pos_sell.Total()-1);
      //   if(!pos2.IsHedge() && pos2.MainPositionWinPoints()>300)
      //     {
      //      Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,0,0);
      //      pos2.AddHedgePosition(Trade.ResultOrder());
      //     }
      //  }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLockBase::CheckPositionClose(void)
  {
   int total;
   total=pos_buy.Total();
   for(int i=total-1;i>=0;i--)
     {
      CLockPosition *pos=pos_buy.At(i);
      if(!pos.IsMainClose() && MathAbs(pos.MainPositionWinPoints())>500)
        {
         Trade.PositionClose(pos.MainPosID());
         pos.SetMainClose();
        }
      if(pos.IsHedge() && !pos.IsHedgeClose() && MathAbs(pos.HedgePositionWinPoints())>500)
        {
         Trade.PositionClose(pos.HedgePosID());
         pos.SetHedgeClose();
        }
      if(pos.PostionIsClose()) pos_buy.Delete(i);
     }

   total=pos_sell.Total();
   for(int i=total-1;i>=0;i--)
     {
      CLockPosition *pos=pos_sell.At(i);
      if(!pos.IsMainClose() && MathAbs(pos.MainPositionWinPoints())>500)
        {
         Trade.PositionClose(pos.MainPosID());
         pos.SetMainClose();
        }
      if(pos.IsHedge() && !pos.IsHedgeClose() && MathAbs(pos.HedgePositionWinPoints())>500)
        {
         Trade.PositionClose(pos.HedgePosID());
         pos.SetHedgeClose();
        }
      if(pos.PostionIsClose()) pos_sell.Delete(i);
     }
  }
//+------------------------------------------------------------------+
