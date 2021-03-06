//+------------------------------------------------------------------+
//|                                                  MaExtremum1.mqh |
//|                                      Copyright 2017,Daixiaorong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,Daixiaorong."
#property link      "https://www.mql5.com"
#include "..\Strategy.mqh"
#include "MaCondition.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMaExtremum:public CStrategy
  {
private:
   int               m_take_profit;
   int               m_stop_loss;
   CMaCondition      m_cond;
   double            current_lots;
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CMaExtremum(void);
                    ~CMaExtremum(void);
   void              TakeProfit(int value) {m_take_profit=value;}
   void              StopLoss(int value)   {m_stop_loss=value;}
   void              Lots(double value)    {current_lots=value;}
   void              SetParams(int short_ma,int long_ma,int max_orders=1);
   void              SetPattern(const int LongInPattern,const int LongOutPattern,
                                const int ShortInPattern,const int ShortOutPattern);
   void              EveryTick(bool every_tick) {m_cond.m_every_tick=every_tick;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMaExtremum::CMaExtremum(void)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMaExtremum::~CMaExtremum(void)
  {

  }
//+------------------------------------------------------------------+
//| 设置指标参数并创建相应的指标对象                                                                 |
//+------------------------------------------------------------------+
void CMaExtremum::SetParams(int short_ma,int long_ma,int max_orders=1)
  {
   short_period=short_ma;
   long_period=long_ma;
   m_max_orders=max_orders-1;
   ArrayResize(m_high,short_ma);
   ArrayResize(m_low,short_ma);
   m_short_ma.Create(ExpertSymbol(),Timeframe(),short_period,0,MODE_SMA,PRICE_CLOSE);
   m_long_ma.Create(ExpertSymbol(),Timeframe(),long_period,0,MODE_SMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| 设置策略模式                                                                 |
//+------------------------------------------------------------------+
void CMaExtremum::SetPattern(const int LongInPattern,const int LongOutPattern,
                           const int ShortInPattern,const int ShortOutPattern)
  {
   m_cond.SetPattern(LongInPattern,LongOutPattern,ShortInPattern,ShortOutPattern);
   m_cond.CreateIndicator(ExpertSymbol(),Timeframe());
  }
//+------------------------------------------------------------------+
//|更新指标值和其他数据预计算                                                                 |
//+------------------------------------------------------------------+
void CMaExtremum ::OnEvent(const MarketEvent &event)
  {
   m_cond.RefreshState();
  }
//+------------------------------------------------------------------+
//| 多单进场条件                                                                 |
//+------------------------------------------------------------------+
void CMaExtremum ::InitBuy(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN) return;
   if(m_cond.LongInCondition())
     {
      Trade.Buy(current_lots,ExpertSymbol(),"多单进场模式");
      double tp=(m_take_profit==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_ASK)+m_take_profit*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      double sl=(m_stop_loss==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_ASK)-m_stop_loss*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      Trade.PositionModify(Trade.ResultOrder(),sl,tp);
     }

  }
//+------------------------------------------------------------------+
//|多单出场条件                                                                 |
//+------------------------------------------------------------------+
void CMaExtremum ::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   if(m_cond.LongOutCondition(pos))
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
//|空单进场条件                                                                 |
//+------------------------------------------------------------------+
void CMaExtremum ::InitSell(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN) return;
   if(m_cond.ShortInCondition())
     {
      Trade.Sell(current_lots,ExpertSymbol(),"空单进场模式");
      double tp=(m_take_profit==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_BID)-m_take_profit*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      double sl=(m_stop_loss==0.0)?0.0:SymbolInfoDouble(event.symbol,SYMBOL_BID)+m_stop_loss*SymbolInfoDouble(event.symbol,SYMBOL_POINT);
      Trade.PositionModify(Trade.ResultOrder(),sl,tp);
     }

  }
//+------------------------------------------------------------------+
//| 空单出场条件                                                                  |
//+------------------------------------------------------------------+
void CMaExtremum ::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   if(m_cond.ShortOutCondition(pos))
      pos.CloseAtMarket();
  }
//+------------------------------------------------------------------+
