//+------------------------------------------------------------------+
//|                                                           R1.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CR1:public CStrategy
  {
private:
   int               h_band;
   int               h_rsi;
   MqlTick           latest_price;
   int               pr;
   double            band_base[];
   double            band_up[];
   double            band_down[];
   double            rsi[];
   double            high_price[];
   double            low_price[];
   double            open_price[];
   double            close_price[];
   CArrayLong        pos_long;
   CArrayLong        pos_short;
   int               tp_points;
   int               sl_points;
   int               rsi_up;
   int               rsi_down;
   int               band_range;
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              CheckPositionOpen();
   void              CheckPositionClose();
   void              PatternRecognition();
   bool              IsSellCandle();
   bool              IsBuyCandle();
public:
                     CR1(void){};
                    ~CR1(void){};
   void              SetBandParameter(int ma_period,double deviation,int range=300);
   void              SetRsiParameter(int ma_period, int up_rsi=70, int down_rsi=30);
   void              SetTpAndSl(int tp=500,int sl=500);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::SetBandParameter(int ma_period,double deviation,int range=300)
  {
   h_band=iBands(ExpertSymbol(),Timeframe(),ma_period,0,deviation,PRICE_CLOSE);
   band_range=range;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::SetRsiParameter(int ma_period,int up_rsi=70, int down_rsi=30)
  {
   h_rsi=iRSI(ExpertSymbol(),Timeframe(),ma_period,PRICE_CLOSE);
   rsi_up=up_rsi;
   rsi_down=down_rsi;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::SetTpAndSl(int tp=500,int sl=500)
  {
   tp_points=tp;
   sl_points=sl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      SymbolInfoTick(ExpertSymbol(),latest_price);
      CheckPositionClose();
      CheckPositionOpen();
     }
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {

      CopyBuffer(h_band,0,0,2,band_base);
      CopyBuffer(h_band,1,0,2,band_up);
      CopyBuffer(h_band,2,0,2,band_down);
      CopyBuffer(h_rsi,0,0,2,rsi);

      CopyHigh(ExpertSymbol(),Timeframe(),0,4,high_price);
      CopyLow(ExpertSymbol(),Timeframe(),0,4,low_price);
      CopyOpen(ExpertSymbol(),Timeframe(),0,4,open_price);
      CopyClose(ExpertSymbol(),Timeframe(),0,4,close_price);
      PatternRecognition();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::PatternRecognition(void)
  {
   pr=0;
   if(band_up[0]-band_base[0]>band_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      if(rsi[0]>rsi_up)
        {
         if(IsSellCandle())
           {
            pr=-1;
            return;
           }
        }
     }
   if(band_base[0]-band_down[0]>band_range*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT))
     {
      if(rsi[0]<rsi_down)
        {
         if(IsBuyCandle())
           {
            pr=1;
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::CheckPositionClose(void)
  {
   int total=pos_long.Total();
   for(int i=total-1;i>=0;i--)
     {
      PositionSelectByTicket(pos_long.At(i));
      bool is_tp=PositionGetDouble(POSITION_PRICE_CURRENT)-PositionGetDouble(POSITION_PRICE_OPEN)>tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      bool is_sl=PositionGetDouble(POSITION_PRICE_CURRENT)-PositionGetDouble(POSITION_PRICE_OPEN)<-sl_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      if(is_tp || is_sl)
        {
         Trade.PositionClose(pos_long.At(i));
         pos_long.Delete(i);
        }
     }
   total=pos_short.Total();
   for(int i=total-1;i>=0;i--)
     {
      PositionSelectByTicket(pos_short.At(i));
      bool is_tp=PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_PRICE_CURRENT)>tp_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      bool is_sl=PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_PRICE_CURRENT)<-sl_points*SymbolInfoDouble(ExpertSymbol(),SYMBOL_POINT);
      if(is_tp || is_sl)
        {
         Trade.PositionClose(pos_short.At(i));
         pos_short.Delete(i);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CR1::CheckPositionOpen(void)
  {
   if(pr==1)
     {
      if(pos_long.Total()==0)
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_BUY,0.01,latest_price.ask,0,0);
         pos_long.Add(Trade.ResultOrder());
        }
      return;
     }
   if(pr==-1)
     {
      if(pos_short.Total()==0)
        {
         Trade.PositionOpen(ExpertSymbol(),ORDER_TYPE_SELL,0.01,latest_price.bid,0,0);
         pos_short.Add(Trade.ResultOrder());
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CR1::IsBuyCandle(void)
  {
   if(low_price[0]<low_price[1]&&low_price[1]<low_price[2]&&low_price[2]<low_price[3]) return true;
   if(high_price[0]<high_price[1]&&high_price[1]<high_price[2]&&high_price[2]<high_price[3]) return true;
   if(high_price[3]>high_price[2]&&high_price[1]>high_price[2]&&low_price[3]>low_price[2]) return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CR1::IsSellCandle(void)
  {
   if(high_price[0]>high_price[1]&&high_price[1]>high_price[2]&&high_price[2]>high_price[3]) return true;
   if(low_price[0]>low_price[1]&&low_price[1]>low_price[2]&&low_price[2]>low_price[3]) return true;
   if(low_price[3]<low_price[2]&&low_price[1]<low_price[2]&&high_price[3]<high_price[2]) return true;
   return false;
  }
//+------------------------------------------------------------------+
