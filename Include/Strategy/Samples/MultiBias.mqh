//+------------------------------------------------------------------+
//|                                                    MultiBias.mqh |
//|                                      Copyright 2017,Daixiaorong. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017,Daixiaorong."
#property link      "https://www.mql5.com"

#include <Indicators\Oscilators.mqh>
#include <Indicators\Trend.mqh>
#include "..\Strategy.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultiBias:public CStrategy
  {
private:
   int               m_ma_period;
   ENUM_APPLIED_PRICE m_applied_price;
   double            m_current_lots;
   double            m_invest_level;
   double            buy_in_level;
   double            buy_out_level;
   double            sell_in_level;
   double            sell_out_level;
   double            best_out_time;
   double            m_profit_out;
   int               time_unit;
   bool              every_tick;
   CiBIAS            m_bias;
   CiMA              m_ma;
   bool              IsTrackEvents(const MarketEvent &event);
protected:
   virtual void      InitBuy(const MarketEvent &event);
   virtual void      InitSell(const MarketEvent &event);
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      SupportBuy(const MarketEvent &event,CPosition *pos);
   virtual void      SupportSell(const MarketEvent &event,CPosition *pos);
   double            SecondsConvert(long seconds,int mode=0);
   int               StartIndex(void) {return every_tick?0:1;}
public:
                     CMultiBias(void);
                    ~CMultiBias(void);
   bool              CheckOutTime(CPosition *pos);
   void              Lots(double value)         { m_current_lots=value;}
   double            Lots(void)                 {return m_current_lots;}
   void              InvestLevel(double value);
   double            InvestLevel(void) {return m_invest_level;}
   void              SetParams(int ma_period,double BuyInLevel,double BuyOutLevel,double SellInLevel,double SellOutLevel,
                               double BestOutTime=0.0,int TimeUnit=0,double profit_out=0.0,bool EveryTick=false);
  };
//+------------------------------------------------------------------+
//| 初始化                                                                 |
//+------------------------------------------------------------------+
CMultiBias::CMultiBias(void)
  {
   m_ma_period=24;
   m_applied_price=PRICE_CLOSE;
   buy_in_level=-0.35;
   buy_out_level=0.19;
   sell_in_level=0.50;
   sell_out_level=-0.03;
   best_out_time=0.0;
   time_unit=0;
   every_tick=true;
   m_current_lots=1.00;
   m_invest_level=0.0;
   m_profit_out=0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMultiBias::~CMultiBias(void)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiBias::OnEvent(const MarketEvent &event)
  {
   m_bias.Refresh();
   m_ma.Refresh();
  }
//+------------------------------------------------------------------+
//|  买单入场条件                                                                |
//+------------------------------------------------------------------+
void CMultiBias::InitBuy(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;
   if(positions.open_buy>0) return;
   int idx=StartIndex();
   if(m_bias.Main(idx)<=buy_in_level)
      Trade.Buy(m_current_lots,event.symbol,(string)ExpertMagic());
   
  }
//+------------------------------------------------------------------+
//| 买单出场条件                                                                 |
//+------------------------------------------------------------------+
void CMultiBias::SupportBuy(const MarketEvent &event,CPosition *pos)
  {
   int idx=StartIndex();
   if((m_bias.Main(idx)>=buy_out_level && m_ma.Main(idx)-m_ma.Main(idx+m_ma_period)<0) || CheckOutTime(pos))
      pos.CloseAtMarket((string)ExpertMagic());
  }
//+------------------------------------------------------------------+
//|卖单入场条件                                                                  |
//+------------------------------------------------------------------+
void CMultiBias::InitSell(const MarketEvent &event)
  {
   if(!IsTrackEvents(event)) return;
   if(positions.open_sell>0) return;
   int idx=StartIndex();
   if(m_bias.Main(idx)>=sell_in_level)
      Trade.Sell(m_current_lots,event.symbol,(string)ExpertMagic());
  }
//+------------------------------------------------------------------+
//|卖单出场条件                                                                 |
//+------------------------------------------------------------------+
void CMultiBias::SupportSell(const MarketEvent &event,CPosition *pos)
  {
   int idx=StartIndex();
   if((m_bias.Main(idx)<=sell_out_level && m_ma.Main(idx)-m_ma.Main(idx+m_ma_period)>0) || CheckOutTime(pos))
      pos.CloseAtMarket((string)ExpertMagic());
  }
//+------------------------------------------------------------------+
//| 设置参数                                                                 |
//+------------------------------------------------------------------+
void CMultiBias::SetParams(int ma_period,double BuyInLevel,double BuyOutLevel,double SellInLevel,double SellOutLevel,
                           double BestOutTime=0.0,int TimeUnit=0,double profit_out=0.0,bool EveryTick=false)
  {
   m_ma_period=ma_period;
   buy_in_level=BuyInLevel;
   buy_out_level=BuyOutLevel;
   sell_in_level=SellInLevel;
   sell_out_level=SellOutLevel;
   best_out_time=BestOutTime;
   time_unit=TimeUnit;
   m_profit_out=profit_out;
   every_tick=EveryTick;
   m_bias.Create(ExpertSymbol(),Timeframe(),m_ma_period,m_applied_price);
   m_ma.Create(ExpertSymbol(),Timeframe(),m_ma_period,0,MODE_SMA,m_applied_price);
  }
//+------------------------------------------------------------------+
//|  将秒数化为分钟或者小时，或者天数,分别为mode= 0,1,2默认为0                                                              |
//+------------------------------------------------------------------+
double CMultiBias::SecondsConvert(long seconds,int mode=0)
  {
   double res=0.0;
   switch(mode)
     {
      case 0 :
         res=double(seconds)/60.00000000;
         break;
      case 1:
         res=double(seconds)/(60.00000000*60.00000000);
         break;
      default:
         res=double(seconds)/(60.00000000*60.00000000*24.00000000);
         break;
     }
   return res;
  }
//+------------------------------------------------------------------+
//| 检查是否需要固定时间出场                                                                 |
//+------------------------------------------------------------------+
bool CMultiBias::CheckOutTime(CPosition *pos)
  {
   if(best_out_time>0)
     {
      if(m_profit_out>0.0)
        {
         return (SecondsConvert((long)(TimeCurrent()-pos.TimeOpen()),time_unit)>=best_out_time) && (pos.Profit()>=m_profit_out);
        }
      else
         return SecondsConvert((long)(TimeCurrent()-pos.TimeOpen()),time_unit)>=best_out_time;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//| 固定比例投资                                                                |
//+------------------------------------------------------------------+
void CMultiBias::InvestLevel(double value)
  {
   m_invest_level=value;
   if(m_invest_level>0)
      m_current_lots=AccountInfoDouble(ACCOUNT_MARGIN_FREE)*m_invest_level;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMultiBias::IsTrackEvents(const MarketEvent &event)
  {
   if(event.type!=MARKET_EVENT_BAR_OPEN) return false;
   if(event.symbol!=ExpertSymbol() || event.period!=Timeframe()) return false;
   return true;
  }
//+------------------------------------------------------------------+
