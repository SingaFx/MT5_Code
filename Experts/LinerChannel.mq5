//+------------------------------------------------------------------+
//|                                                 LinerChannel.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

input int min_period=30;
input int max_period=100;
input int EA_Magic=101;

double stop_loss, take_profit;

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
   
   check_for_open();
   check_for_close(0.5,500,-10000);
  }
//+------------------------------------------------------------------+
void manage_position()
   {
    int total_size=0, buy_size=0, sell_size=0;
    double total_profit_buy=0,total_profit_sell=0;
    double total_lots_buy=0,total_lots_sell=0;
    double lots_level[]={0.01,0.02,0.03,0.04};
    double loss_level[]={-100,-200,-300,-400};
    double new_buy_lots,new_sell_lots,new_tp;
    double target_win_points=200.0;
    static int last_buy_level=0;
    static int last_sell_level=0;
    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;

    total_size=PositionsTotal();
    //遍历当前所有仓位，分别计算买单和卖单的总盈利和，总仓位数，总手数
    for(int i=0;i<total_size;i++)
      {
       PositionGetSymbol(i);
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
          buy_size++;
          total_profit_buy+=PositionGetDouble(POSITION_PROFIT);
          total_lots_buy+=PositionGetDouble(POSITION_VOLUME);
         }
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
          sell_size++;
          total_profit_sell+=PositionGetDouble(POSITION_PROFIT);
          total_lots_sell+=PositionGetDouble(POSITION_VOLUME);
         }
      }
    //如果损失超过一定值进行加仓:新加仓手数，历史订单止盈点位调整
    int p_buy_level = postion_level(total_profit_buy/total_lots_buy,loss_level);
    if(p_buy_level>last_buy_level)
      {
         MqlTradeRequest mrequest;
         MqlTradeResult mresult;
         ZeroMemory(mrequest);
         ZeroMemory(mresult);
       new_buy_lots=lots_level[p_buy_level];
       new_tp=latest_price.ask+(target_win_points-total_profit_buy/total_lots_buy)*_Point;
       mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_BUY;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=new_buy_lots;
         mrequest.tp=NormalizeDouble(new_tp,_Digits);
         OrderSend(mrequest, mresult);
         last_buy_level=p_buy_level;
      }
      
    int p_sell_level = postion_level(total_profit_sell/total_lots_sell,loss_level);
    if(p_sell_level>last_sell_level)
      {
         MqlTradeRequest mrequest;
         MqlTradeResult mresult;
         ZeroMemory(mrequest);
         ZeroMemory(mresult);
       new_sell_lots=lots_level[p_sell_level];
       new_tp=latest_price.bid-(target_win_points-total_profit_sell/total_lots_sell)*_Point;
       mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.bid,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_SELL;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=new_sell_lots;
         mrequest.tp=NormalizeDouble(new_tp,_Digits);
         OrderSend(mrequest, mresult);
      }
   }
int postion_level(const double loss_point, const double& level_loss_points[])
   {
    for(int i=0;i<ArraySize(level_loss_points)-1;i++)
      {
       if(loss_point<level_loss_points[i]&&loss_point>level_loss_points[i+1])
         return i;
      }
    return ArraySize(level_loss_points)-1;   
   }

void check_for_open()
   {
    MqlTick latest_price;
    if(Bars(_Symbol,_Period)<min_period)
      return;
    if(!SymbolInfoTick(_Symbol,latest_price)) return;
    if(open_condition()==1)
      {
         MqlTradeRequest mrequest;
         MqlTradeResult mresult;
         ZeroMemory(mrequest);
         ZeroMemory(mresult);
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.ask,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_BUY;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=0.1;
         //mrequest.sl=stop_loss;
         OrderSend(mrequest, mresult);
      }
   if(open_condition()==0)
      {
         MqlTradeRequest mrequest;
         MqlTradeResult mresult;
         ZeroMemory(mrequest);
         ZeroMemory(mresult);
         mrequest.action=TRADE_ACTION_DEAL;
         mrequest.price=NormalizeDouble(latest_price.bid,_Digits);
         mrequest.symbol=_Symbol;
         mrequest.magic=EA_Magic;
         mrequest.type=ORDER_TYPE_SELL;
         mrequest.type_filling=ORDER_FILLING_FOK;
         mrequest.deviation=5;
         mrequest.volume=0.1;
         //mrequest.sl=stop_loss;
         OrderSend(mrequest, mresult);
      }   
   }

int open_condition()
   {
    int total_buy=0;
    int total_sell=0;
    int total=PositionsTotal();
    
   for(int i=0;i<total;i++)
      {  
      string position_symbol=PositionGetSymbol(i);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
         Print("buy************");
         total_buy++;
         }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         total_sell++; 
      }
    
    double close_price[];
    ArrayResize(close_price,min_period);
    CopyClose(_Symbol,_Period,0,min_period,close_price);
    double coff[], std;
    std=cal_linear_regression_std(close_price,coff);
    //if(coff[0]<0) Print(coff[0]," ", coff[1]," ", coff[2]," " ,coff[3],std);
    MqlTick latest_price;
    if(!SymbolInfoTick(_Symbol,latest_price)) return -1;
    if(coff[3]<0.95) return -1;
    if((coff[0]<0) && (latest_price.bid>coff[2]+2*std) && (total_buy<1))
      {  
         stop_loss=latest_price.ask<coff[2]-3*std;
         return 1;
      }
    //Print("buy condition:", (coff[0]<0)," ",(latest_price.bid>coff[2]+2*std) ," ",(total_buy<1), total_buy);
    if(coff[0]>0&&latest_price.ask<coff[2]-2*std&&total_sell<1)
      {
         stop_loss=latest_price.bid>coff[2]+3*std;
         return 0;
      }   
    return -1;
   }
   
double cal_linear_regression_std(const double& price[], double& res[])
   {
    ArrayResize(res,4);
    double sumX,sumY,sumXY,sumX2,sumY2,a,b,F,S,r2;
    int X, sample_size;
    //--- calculate coefficient a and b of equation linear regression 
    F=0.0;
    S=0.0;
    sumX=0.0;
    sumY=0.0;
    sumXY=0.0;
    sumX2=0.0;
    sumY2=0.0;
    X=0;
    sample_size=ArraySize(price);
    for(int i=0;i<sample_size;i++)
      {
       sumX+=X;
       sumY+=price[i];
       sumXY+=X*price[i];
       sumX2+=MathPow(X,2);
       sumY2+=MathPow(price[i],2);
       X++;
      }
    a=(sumX*sumY-sample_size*sumXY)/(MathPow(sumX,2)-sample_size*sumX2);
    b=(sumY-a*sumX)/sample_size;
    r2=(sample_size*sumXY-sumX*sumY)/(MathSqrt(sample_size*sumX2-MathPow(sumX,2))*MathSqrt(sample_size*sumY2-MathPow(sumY,2)));
//--- calculate values of main line and error F
    X=0;
    for(int i=0; i<sample_size;i++)
      {
       F+=MathPow(price[i]-(b+a*X),2);
       X++;
      }
//--- calculate deviation S       
    S=NormalizeDouble(MathSqrt(F/(sample_size+1))/MathCos(MathArctan(a*M_PI/180)*M_PI/180),_Digits);
    res[0]=a;
    res[1]=b;
    res[2]=(b+a*(X+1));
    res[3]=MathAbs(r2);
    return S;
   }   

void check_for_close(const double out_time_hours, const double win_out_profit, const double loss_out_profit)
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
         bool profit_out = PositionGetDouble(POSITION_PROFIT)>win_out_profit*PositionGetDouble(POSITION_VOLUME)||PositionGetDouble(POSITION_PROFIT)<loss_out_profit*PositionGetDouble(POSITION_VOLUME);
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