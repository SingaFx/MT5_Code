//+------------------------------------------------------------------+
//|                                                       czj_Fi.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//#include<Arrays\ArrayDouble.mqh>

input int period=50;
input int range_point=300;
input int range_period=20;
input int EA_Magic=8881;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      //检查bar数是否足够
      if(Bars(_Symbol,_Period)<period)
            return;
      int total_buy=0;
      //检查仓位，持仓则判断是否需要平仓
      if(PositionSelect(_Symbol)==true)
      {  
         total_buy=PositionsTotal();
      }
      double high_price[];
      double low_price[];
      double take_profit;
      double stop_loss;
      double size;
      int max_loc;
      int min_loc;
      double max_price;
      double min_price;
      MqlTick latest_price;
      MqlTradeRequest mrequest;
      MqlTradeResult mresult;
      ZeroMemory(mrequest);
      
      if(!SymbolInfoTick(_Symbol,latest_price))
         {
            Alert("获取最新报价错误：", GetLastError());
            return;
         }  
      CopyHigh(_Symbol,_Period,0,period,high_price);
      CopyLow(_Symbol,_Period,0,period,low_price);

      max_loc = ArrayMaximum(high_price);
      min_loc = ArrayMinimum(low_price);
      max_price = high_price[max_loc];
      min_price = high_price[min_loc];
      
      bool buy_condition_basic = (max_loc>min_loc)&&(max_loc-min_loc<range_period)&&(max_price-min_price>range_point*_Point);
      bool buy_condition_level1 = latest_price.ask<0.618*(max_price-min_price)+min_price;
      bool buy_condition_level2 = latest_price.ask<0.5*(max_price-min_price)+min_price;
      bool buy_condition_level3 = latest_price.ask<0.382*(max_price-min_price)+min_price;
      
      if(buy_condition_basic)
         {
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_BUY;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         bool order_need_send=false;
         if(buy_condition_level1&&total_buy<1)
            {
               take_profit=0.782*(max_price-min_price)+min_price;
               stop_loss=-1*(max_price-min_price)+min_price;
               size=0.1;
               order_need_send=true;
            }
         if(buy_condition_level2&&total_buy<2)
            {
               take_profit=0.782*(max_price-min_price)+min_price;
               stop_loss=-1.618*(max_price-min_price)+min_price;
               size=0.3;
               order_need_send=true;
            }
         if(buy_condition_level3&&total_buy<3)
            {
               take_profit=0.782*(max_price-min_price)+min_price;
               stop_loss=-1.618*(max_price-min_price)+min_price;
               size=0.5;
               order_need_send=true;
            }
         if(order_need_send)
            {
            mrequest.volume=size;
            mrequest.tp=NormalizeDouble(take_profit,_Digits);
            mrequest.sl=NormalizeDouble(stop_loss, _Digits);
            OrderSend(mrequest, mresult);
            if(mresult.retcode==10009||mresult.retcode==10008)
               {
                  Alert("买入订单已经成功下单，订单#:", mresult.order,"!!");
               }
            else
               {
                  Alert("买入订单请求无法完成,", GetLastError());
                  ResetLastError();
                  return;
               } 
            }
         }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
