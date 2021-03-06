//+------------------------------------------------------------------+
//|                                                   CustomMACD.mqh |
//|                                      Copyright 2017,Daixiaorong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,Daixiaorong."
#property link      "https://www.mql5.com"
#include "..\Strategy.mqh"
#include "MacdCondition.mqh"
//+------------------------------------------------------------------+
//| 自定义的MACD背离策略                                                                 |
//+------------------------------------------------------------------+
class CustomMACD:public CStrategy
  {
private:
   int               m_take_profit;
   int               m_stop_loss;
   CMacdCondition    m_cond;
   double            current_lots;
   string            m_comment;
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CustomMACD(void);
                    ~CustomMACD(void);
   bool              IsDeviation(void);
   void              TakeProfit(int value) {m_take_profit=value;}
   void              StopLoss(int value)   {m_stop_loss=value;}
   void              Lots(double value)    {current_lots=value;}
   void              SetPattern(const int LongInPattern,const int LongOutPattern,
                               const int ShortInPattern,const int ShortOutPattern);
   void              EveryTick(bool every_tick)     {m_cond.m_every_tick=every_tick;}
   void              PriceDiverge(double value)     {m_cond.m_pr_prencet=value;}
   void              IndicatorDiverge(double value) {m_cond.m_ind_precent=value;}
   void              OrdersCommment(string comment) {m_comment=comment;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CustomMACD::CustomMACD(void)
  {
   m_stop_loss=100;
   m_take_profit=100;
   current_lots=1.00;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CustomMACD::~CustomMACD(void)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomMACD::SetPattern(const int LongInPattern,const int LongOutPattern,
                           const int ShortInPattern,const int ShortOutPattern)
  {
   m_cond.SetPattern(LongInPattern,LongOutPattern,ShortInPattern,ShortOutPattern);
   m_cond.CreateIndicator(ExpertSymbol(),Timeframe());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CustomMACD::OnEvent(const MarketEvent &event)
  {
   m_cond.RefreshState();
  }
//+------------------------------------------------------------------+
//| 多单进场条件                                                                 |
//+------------------------------------------------------------------+
void CustomMACD::InitBuy(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN) return;
   if(m_cond.LongInCondition())
     {
      Trade.Buy(current_lots,ExpertSymbol(),StringFormat("BUY-%s-%d",m_comment,ExpertMagic()));
      double tp=(m_take_profit==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_ASK)+m_take_profit*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      double sl=(m_stop_loss==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_ASK)-m_stop_loss*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      if(tp==0.0 && sl==0.0) return;
      Trade.PositionModify(Trade.ResultOrder(),sl,tp);
     }

  }
//+------------------------------------------------------------------+
//|多单出场条件                                                                 |
//+------------------------------------------------------------------+
void CustomMACD::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   if(m_cond.LongOutCondition(pos))
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
//|空单进场条件                                                                 |
//+------------------------------------------------------------------+
void CustomMACD::InitSell(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN) return;
   if(m_cond.ShortInCondition())
     {
      Trade.Sell(current_lots,ExpertSymbol(),StringFormat("SELL-%s-%d",m_comment,ExpertMagic()));
      double tp=(m_take_profit==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_BID)-m_take_profit*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      double sl=(m_stop_loss==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_BID)+m_stop_loss*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      if(tp==0.0 && sl==0.0) return;
      Trade.PositionModify(Trade.ResultOrder(),sl,tp);
     }

  }
//+------------------------------------------------------------------+
//| 空单出场条件                                                                  |
//+------------------------------------------------------------------+
void CustomMACD::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   if(m_cond.ShortOutCondition(pos))
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
