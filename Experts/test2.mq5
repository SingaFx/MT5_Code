//+------------------------------------------------------------------+
//|                                              czj_Fi_Standard.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>

input int period=100;   //搜素模式的大周期
input int range_point=380; //模式的最小点数差
input int range_period=26; //模式的最大数据长度

input int EA_Magic=8881;
input double open_level1=0.618; //一级开仓点
input double profit_ratio_level1=0.882; //一级平仓点
input double loss_ratio=-0.618; //止损点位
input double lots_level1=0.1; //一级开仓手数


CTrade ExtTrade;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   check_for_close();
   check_for_open();
   
  }
//+------------------------------------------------------------------+

void check_for_open(void)
   {
   //检查bar数是否足够
   if(Bars(_Symbol,_Period)<period)
      return;
   //变量申明
   double high_price[];
   double low_price[];
   double take_profit=0;
   double stop_loss=0;
   double size=0;
   int max_loc;
   int min_loc;
   double max_price;
   double min_price;
   MqlTick latest_price;
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   ZeroMemory(mrequest);
   ZeroMemory(mresult);
   int total_buy=0;
   int total_sell=0;
   int total=0;
   //获取最新报价,历史最高，最低价
   if(!SymbolInfoTick(_Symbol,latest_price)) return;
   CopyHigh(_Symbol,_Period,0,period,high_price);
   CopyLow(_Symbol,_Period,0,period,low_price); 
   max_loc = ArrayMaximum(high_price);
   min_loc = ArrayMinimum(low_price);
   max_price = high_price[max_loc];
   min_price = high_price[min_loc];
   
   //if(max_price-min_price>1000*_Point)
   //   return;
        
   //计算开平仓条件
   bool buy_condition_basic = (max_loc>min_loc)&&(max_loc-min_loc<range_period)&&(max_price-min_price>range_point*_Point)&&(max_price-min_price<5*range_point*_Point);
   bool buy_condition_level1 = latest_price.ask<open_level1*(max_price-min_price)+min_price;
   bool buy_condition_level2 = latest_price.ask<open_level2*(max_price-min_price)+min_price;
   bool buy_condition_level3 = latest_price.ask<open_level3*(max_price-min_price)+min_price;
  
   bool sell_condition_basic=false; 
   //bool sell_condition_basic = (max_loc<min_loc)&&(min_loc-max_loc<range_period)&&(max_price-min_price>range_point*_Point)&&(max_price-min_price<5*range_point*_Point);
   bool sell_condition_level1 = latest_price.bid>max_price-open_level1*(max_price-min_price);
   bool sell_condition_level2 = latest_price.bid>max_price-open_level2*(max_price-min_price);
   bool sell_condition_level3 = latest_price.bid>max_price-open_level3*(max_price-min_price);
   // 当前仓位情况
   //if(PositionSelect(_Symbol)==true)
   //   {  
   //      total=PositionsTotal();
   //      for(int i=0;i<total;i++)
   //         {  
   //         string position_symbol=PositionGetSymbol(i);
   //         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
   //            total_buy++;
   //         else
   //            total_sell++;   
   //         }
   //   }
//   
   total=PositionsTotal();
   for(int i=0;i<total;i++)
      {  
      ulong ticket=PositionGetTicket(i);
      PositionSelectByTicket(ticket);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY&&PositionGetString(POSITION_SYMBOL)==_Symbol)
         total_buy++;
      else
         total_sell++;   
      }
   
   // 买单判断并操作
   if(buy_condition_basic)
      {
      bool order_need_send=false;
      if(buy_condition_level1&&total_buy<1)
         {
         take_profit=profit_ratio_level1*(max_price-min_price)+min_price;
         stop_loss=loss_ratio*(max_price-min_price)+min_price;
         size=lots_level1;
         order_need_send=true;
         }
      //if(buy_condition_level2&&total_buy<2)
      //   {
      //   take_profit=profit_ratio_level2*(max_price-min_price)+min_price;
      //   stop_loss=loss_ratio*(max_price-min_price)+min_price;
      //   size=lots_level2;
      //   order_need_send=true;
      //   }
      //if(buy_condition_level3&&total_buy<3)
      //   {
      //   take_profit=profit_ratio_level3*(max_price-min_price)+min_price;
      //   stop_loss=loss_ratio*(max_price-min_price)+min_price;
      //   size=lots_level3;
      //   order_need_send=true;
      //   }
      if(order_need_send)
         {
         //take_profit=MathMin(take_profit,latest_price.ask+200*_Point);
         //stop_loss=MathMax(stop_loss,latest_price.ask-500*_Point);
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_BUY;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=size;
         mrequest.tp=NormalizeDouble(take_profit,_Digits);
         mrequest.sl=NormalizeDouble(stop_loss, _Digits);
         OrderSend(mrequest, mresult);
         if(mresult.retcode==10009||mresult.retcode==10008)
            Alert("买入订单已经成功下单，订单#:", mresult.order,"!!");
         else
            {
               Alert("买入订单请求无法完成,", GetLastError(), latest_price.ask," ", take_profit," ", stop_loss);
               ResetLastError();
               return;
            } 
         }
      }
   // 卖单判断并操作   
   if(sell_condition_basic)
      {
      bool order_need_send=false;
      if(sell_condition_level1&&total_sell<1)
         {  
         take_profit=max_price-profit_ratio_level1*(max_price-min_price);
         stop_loss=max_price-(loss_ratio)*(max_price-min_price);
         size=lots_level1;
         order_need_send=true;
         }
      //if(sell_condition_level2&&total_sell<2)
      //   {
      //   take_profit=max_price-profit_ratio_level2*(max_price-min_price);
      //   stop_loss=max_price-(loss_ratio)*(max_price-min_price);
      //   size=lots_level2;
      //   order_need_send=true;
      //   }
      //if(sell_condition_level3&&total_sell<3)
      //   {
      //   take_profit=max_price-profit_ratio_level3*(max_price-min_price);
      //   stop_loss=max_price-(loss_ratio)*(max_price-min_price);
      //   size=lots_level3;
      //   order_need_send=true;
      //   }
      if(order_need_send)
         {
         //take_profit=MathMax(take_profit,latest_price.bid-200*_Point);
         //stop_loss=MathMin(stop_loss,latest_price.bid+500*_Point);
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.bid,_Digits);
         mrequest.type=ORDER_TYPE_SELL;
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=size;
         mrequest.tp=NormalizeDouble(take_profit,_Digits);
         mrequest.sl=NormalizeDouble(stop_loss, _Digits);
         OrderSend(mrequest, mresult);
         if(mresult.retcode==10009||mresult.retcode==10008)
            Alert("卖出订单已经成功下单，订单#:", mresult.order,"!!");
         else
            {
            Alert("卖出订单请求无法完成,", GetLastError());
            ResetLastError();
            return;
            } 
         }
      }
      
   }
void check_for_close(void)
   {
      int p_total = PositionsTotal();
      if(p_total==0) return;
      datetime time_now[];
      
      
      CopyTime(_Symbol,_Period,0,1,time_now);
      for(int i=0;i<p_total;i++)
         {
         PositionGetSymbol(i);
         datetime open_time = datetime(PositionGetInteger(POSITION_TIME));
         bool time_out = long(time_now[0]-open_time)>3600*out_time_hours;
         bool profit_out = PositionGetDouble(POSITION_PROFIT)>out_profit*PositionGetDouble(POSITION_VOLUME);
         if(time_out||profit_out)
            {
            MqlTradeRequest m_request;
            MqlTradeResult m_result;
            ZeroMemory(m_request);
            ZeroMemory(m_result);
            //bool close_position = ExtTrade.PositionClose(_Symbol,3);
            //Print("close position by out time condtion:", close_position);
            if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               //--- prepare request for close BUY position
               m_request.type =ORDER_TYPE_SELL;
               m_request.price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
              }
            else
              {
               //--- prepare request for close SELL position
               m_request.type =ORDER_TYPE_BUY;
               m_request.price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
              }
             
            m_request.action   =TRADE_ACTION_DEAL;
            m_request.symbol   =_Symbol;
            m_request.volume   =PositionGetDouble(POSITION_VOLUME);
            m_request.magic    =EA_Magic;
            m_request.deviation=5;
            m_request.position=PositionGetInteger(POSITION_TICKET);
            m_request.comment= time_out? "out time":"profit out";
            Print("--------------------------------------Type:", m_request.type); 
            Print("--------------------------------------volume:", PositionGetDouble(POSITION_VOLUME)); 
            OrderSend(m_request,m_result);
            continue;
            }
         //Print("profits:", PositionGetDouble(POSITION_PROFIT));   
         //Print("position-i:", i, "open_time:", open_time, "now time", time_now[0], "delta-t", long(time_now[0]-open_time)/3600);
         }
      
   }   