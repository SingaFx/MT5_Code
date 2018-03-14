//+------------------------------------------------------------------+
//|                                            ArbitrageStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include <Trade\Trade.mqh>

enum TypeCurrency
  {
   ENUM_TYPE_CURRENCY_XUSD_XUSD,
   ENUM_TYPE_CURRENCY_XUSD_USDX,
   ENUM_TYPE_CURRENCY_USDX_USDX
  };
//+------------------------------------------------------------------+
//|       套利仓位信息                                               |
//+------------------------------------------------------------------+
struct ArbitragePosition
  {
   int               pair_open_buy;
   int               pair_open_sell;
   int               pair_open_total;
   double            pair_buy_profit;
   double            pair_sell_profit;
   void              Init();
  };
//+------------------------------------------------------------------+
//|         初始化套利仓位信息                                       |
//+------------------------------------------------------------------+
void ArbitragePosition::Init(void)
  {
   pair_open_buy=0;
   pair_open_sell=0;
   pair_open_total=0;
   pair_buy_profit=0.0;
   pair_sell_profit=0.0;
  }
//+------------------------------------------------------------------+
//|               套利策略类                                         |
//+------------------------------------------------------------------+
class CTriangularArbCurrency:public CStrategy
  {
private:
   MqlTick           latest_price_x; //最新的x-usd tick报价
   MqlTick           latest_price_y; //最新的y-usd tick报价
   MqlTick           latest_price_xy;//最新的交叉货币对x-y
   TypeCurrency      cross_type;
   ArbitragePosition arb_position_states; // 套利仓位信息
   int dev_points;
   double per_lots_win;
protected:
   string            symbol_x;   // 品种x
   string            symbol_y; // 品种y
   string            symbol_xy;
   ENUM_TIMEFRAMES   period; // 周期
   int               num; // 序列的长度
   double            lots_base; // 品种x的手数  
public:
                     CTriangularArbCurrency(void);
                    ~CTriangularArbCurrency(void){};
   //---参数设置
   void              SetSymbolsInfor(string currency_1="EUR", string currency_2="GBP",double open_lots=0.1,int points_dev=50,double win_per_lots=50);//设置品种基本信息
   virtual void      OnEvent(const MarketEvent &event);//事件处理
   void              RefreshPosition(void);//刷新仓位信息
   void              RefreshPositionXUSDXUSD(void);
   void              RefreshPositionXUSDUSDX(void);
   void              RefreshPositionUSDXUSDX(void);
   void CloseArbitrageBuyPosition(void);
   void CloseArbitrageBuyPositionXUSDXUSD(void);
   void CloseArbitrageBuyPositionXUSDUSDX(void);
   void CloseArbitrageBuyPositionUSDXUSDX(void);
   void CloseArbitrageSellPosition(void);
   void CloseArbitrageSellPositionXUSDXUSD(void);
   void CloseArbitrageSellPositionXUSDUSDX(void);
   void CloseArbitrageSellPositionUSDXUSDX(void);
  };
//+------------------------------------------------------------------+
//|               默认构造函数                                       |
//+------------------------------------------------------------------+
CTriangularArbCurrency::CTriangularArbCurrency(void)
  {
   //symbol_x="EURUSD";
   //symbol_y="GBPUSD";
   //symbol_xy="EURGBP";
   //AddTickEvent(symbol_x);
   //AddTickEvent(symbol_y);
   //AddTickEvent(symbol_xy);
   //lots_base=0.1;
   //dev_points=50;
   //per_lots_win=50;
  }
//+------------------------------------------------------------------+
//|              设置品种对的基本信息                                |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::SetSymbolsInfor(string currency_1="EUR", string currency_2="GBP",double open_lots=0.1,int points_dev=50,double win_per_lots=50)
  {
   int index_currency_1=-1;
   int index_currency_2=-1;
   string currency_arr[]={"EUR","GBP","AUD","NZD","CAD","CHF","JPY"};
   for(int i=0;i<ArraySize(currency_arr);i++)
     {
      if(currency_1==currency_arr[i])
         index_currency_1=i;
      if(currency_2==currency_arr[i])
         index_currency_2=i;
     }
   if(index_currency_1==-1 ||index_currency_2==-1) return;
   if(index_currency_1<index_currency_2)
      {
         if(index_currency_1>=4)
            {
             cross_type=ENUM_TYPE_CURRENCY_USDX_USDX;
             symbol_x="USD"+currency_1;
             symbol_y="USD"+currency_2;
             symbol_xy=currency_1+currency_2;
            }
         else if(index_currency_2<4)
            {
             cross_type=ENUM_TYPE_CURRENCY_XUSD_XUSD;
             symbol_x=currency_1+"USD";
             symbol_y=currency_2+"USD";
             symbol_xy=currency_1+currency_2;
            }
         else
            {
             cross_type=ENUM_TYPE_CURRENCY_XUSD_USDX;
             symbol_x=currency_1+"USD";
             symbol_y="USD"+currency_2;
             symbol_xy=currency_1+currency_2;
            }
      }
   else
     {
      if(index_currency_2>=4) 
         {
          cross_type=ENUM_TYPE_CURRENCY_USDX_USDX;
          symbol_x="USD"+currency_2;
          symbol_y="USD"+currency_1;
          symbol_xy=currency_2+currency_1;
         }
      else if(index_currency_1<4) 
         {
          cross_type=ENUM_TYPE_CURRENCY_XUSD_XUSD;
          symbol_x=currency_2+"USD";
          symbol_y=currency_1+"USD";
          symbol_xy=currency_2+currency_1;
         }
      else 
         {
          cross_type=ENUM_TYPE_CURRENCY_XUSD_USDX;
          symbol_x=currency_2+"USD";
          symbol_y="USD"+currency_1;
          symbol_xy=currency_2+currency_1;
         }
     }
   lots_base=open_lots;
   dev_points=points_dev;
   per_lots_win=win_per_lots;
   ExpertName(symbol_xy);
  }
//+------------------------------------------------------------------+
//|               事件处理                                           |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::OnEvent(const MarketEvent &event)
  {
   if((event.symbol==symbol_x || event.symbol==symbol_y||event.symbol==symbol_xy) && event.type==MARKET_EVENT_TICK)
     {

      SymbolInfoTick(symbol_x,latest_price_x);
      SymbolInfoTick(symbol_y,latest_price_y);
      SymbolInfoTick(symbol_xy,latest_price_xy);
      RefreshPosition();
      if(arb_position_states.pair_buy_profit>per_lots_win*lots_base)
        {
         CloseArbitrageBuyPosition();
        }
      if(arb_position_states.pair_sell_profit>per_lots_win*lots_base)
        {
         CloseArbitrageSellPosition();
        }
      RefreshPosition();
      double delta=SymbolInfoDouble(symbol_xy,SYMBOL_POINT)*dev_points;
      switch(cross_type)
        {
         case ENUM_TYPE_CURRENCY_XUSD_XUSD :
           if(arb_position_states.pair_open_buy==0&&latest_price_xy.ask+delta<latest_price_x.bid/latest_price_y.ask)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
               
              }
           if(arb_position_states.pair_open_sell==0&&latest_price_xy.bid-delta>latest_price_x.ask/latest_price_y.bid)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
              }
           break;
         case ENUM_TYPE_CURRENCY_USDX_USDX:
           if(arb_position_states.pair_open_buy==0&&latest_price_xy.ask+delta<latest_price_y.ask/latest_price_x.bid)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
               
              }
           if(arb_position_states.pair_open_sell==0&&latest_price_xy.bid-delta>latest_price_y.bid/latest_price_y.ask)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
              } 
           break;
         case ENUM_TYPE_CURRENCY_XUSD_USDX:
            if(arb_position_states.pair_open_buy==0&&latest_price_xy.ask+delta<latest_price_x.bid*latest_price_y.bid)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_BUY,lots_base,latest_price_xy.ask,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_SELL,lots_base,latest_price_x.bid,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_SELL,lots_base,latest_price_y.bid,0,0);
               
              }
           if(arb_position_states.pair_open_sell==0&&latest_price_xy.bid-delta>latest_price_x.ask*latest_price_y.ask)
              {
               Trade.PositionOpen(symbol_xy,ORDER_TYPE_SELL,lots_base,latest_price_xy.bid,0,0);
               Trade.PositionOpen(symbol_x,ORDER_TYPE_BUY,lots_base,latest_price_x.ask,0,0);
               Trade.PositionOpen(symbol_y,ORDER_TYPE_BUY,lots_base,latest_price_y.ask,0,0);
              }
            break;
         default:
           break;
        }
      
     }
  }
//+------------------------------------------------------------------+
//|         刷新套利仓位信息                                         |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::RefreshPosition(void)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD :
        RefreshPositionXUSDXUSD();
        break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         RefreshPositionXUSDUSDX();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         RefreshPositionUSDXUSDX();
         break;   
      default:
        break;
     }
  }
void CTriangularArbCurrency::RefreshPositionXUSDXUSD(void)
  {
   arb_position_states.Init();// 初始化仓位信息
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()==symbol_xy)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }

        }
      if(cpos.Symbol()==symbol_x)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
      if(cpos.Symbol()==symbol_y)
        {
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
     }
  }
void CTriangularArbCurrency::RefreshPositionXUSDUSDX(void)
  {
   arb_position_states.Init();// 初始化仓位信息
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()==symbol_xy)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }

        }
      if(cpos.Symbol()==symbol_x)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
      if(cpos.Symbol()==symbol_y)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
     }
  }
 void CTriangularArbCurrency::RefreshPositionUSDXUSDX(void)
  {
   arb_position_states.Init();// 初始化仓位信息
   for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic())continue;
      if(cpos.Symbol()==symbol_xy)
        {
         arb_position_states.pair_open_total++;
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }

        }
      if(cpos.Symbol()==symbol_x)
        {
         if(cpos.Direction()==POSITION_TYPE_BUY)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
      if(cpos.Symbol()==symbol_y)
        {
         if(cpos.Direction()==POSITION_TYPE_SELL)
           {
            arb_position_states.pair_open_buy++;
            arb_position_states.pair_buy_profit+=cpos.Profit();
           }
         else
           {
            arb_position_states.pair_open_sell++;
            arb_position_states.pair_sell_profit+=cpos.Profit();
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|            平买仓操作                                            |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::CloseArbitrageBuyPosition(void)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD :
        CloseArbitrageBuyPositionXUSDXUSD();
        break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         CloseArbitrageBuyPositionXUSDUSDX();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         CloseArbitrageBuyPositionUSDXUSDX();
         break;   
      default:
        break;
     }
  }
void CTriangularArbCurrency::CloseArbitrageBuyPositionXUSDXUSD(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageBuyPositionXUSDUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageBuyPositionUSDXUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());   
     }
   }
//+------------------------------------------------------------------+
//|                  平卖仓操作                                      |
//+------------------------------------------------------------------+
void CTriangularArbCurrency::CloseArbitrageSellPosition(void)
  {
   switch(cross_type)
     {
      case ENUM_TYPE_CURRENCY_XUSD_XUSD :
        CloseArbitrageSellPositionXUSDXUSD();
        break;
      case ENUM_TYPE_CURRENCY_XUSD_USDX:
         CloseArbitrageSellPositionXUSDUSDX();
         break;
      case ENUM_TYPE_CURRENCY_USDX_USDX:
         CloseArbitrageSellPositionUSDXUSDX();
         break;   
      default:
        break;
     }
  }
void CTriangularArbCurrency::CloseArbitrageSellPositionXUSDXUSD(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageSellPositionXUSDUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());   
     }
   }
void CTriangularArbCurrency::CloseArbitrageSellPositionUSDXUSDX(void)
   {
    for(int i=0;i<ActivePositions.Total();i++)
     {
      CPosition *cpos=ActivePositions.At(i);
      if(cpos.ExpertMagic()!=ExpertMagic()) continue;
      if(cpos.Symbol()==symbol_xy && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_x && cpos.Direction()==POSITION_TYPE_BUY) Trade.PositionClose(cpos.ID());
      if(cpos.Symbol()==symbol_y && cpos.Direction()==POSITION_TYPE_SELL) Trade.PositionClose(cpos.ID());   
     }
   }
//+------------------------------------------------------------------+
