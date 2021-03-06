//+------------------------------------------------------------------+
//|                                                 EA_From_Pipe.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Files\FilePipe.mqh>
#include <Trade\Trade.mqh>

input string pipe_name="pipe1";
input double lots_base=0.1;
CFilePipe  PipeOperator;
CTrade trade;

string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};

int symbol_index;//品种对应的索引
int symbol_operator;//品种对应的操作(对应于服务器的定义) 0:不操作(服务器端不发送数据过来),1:做多 2:做空 3:平多 4:平空
MqlTick latest_price;
int open_price;
int close_price;
int operate_failed=0;
int operate_succeed=1;
int failed_price=0;
int total_pos;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
// 打开管道
   bool pipe_open=false;
   if(PipeOperator.Open("\\\\REN\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeOperator.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      pipe_open=true;
     }
   else if(PipeOperator.Open("\\\\.\\pipe\\"+pipe_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
     {
      if(!PipeOperator.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
         Print("Client: 发送消息至服务器失败！");
      pipe_open=true;
     }

// 判断管道是否成功打开    
   if(!pipe_open)
     {
      Print("服务器发送数据管道打开失败！"+pipe_name);
      return;
     }
   Print("服务器发送数据管道打开成功！"+pipe_name);

// 管道成功打开后，不断从管道中读取信息并进行相应操作
   while(true)
     {
      operator_from_server();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void operator_from_server()
  {
//   读取需要操作的品种index
   if(!PipeOperator.ReadInteger(symbol_index))
     {
      Print("Client: Read EA operator (symbol-index) from Server failed!");
      return;
     }
//   读取操作的类型
   if(!PipeOperator.ReadInteger(symbol_operator))
     {
      Print("Client: Read EA operator (symbol-operator) from Server failed!");
      return;
     }
//    根据操作类型对应相应操作
   SymbolInfoTick(symbols[symbol_index],latest_price);
   switch(symbol_operator)
     {
      case 1://开多
         if(trade.PositionOpen(symbols[symbol_index],ORDER_TYPE_BUY,lots_base,latest_price.ask,0,0))//成功开仓
           {
            open_price=trade.ResultPrice()/SymbolInfoDouble(symbols[symbol_index],SYMBOL_POINT);
            Print("Success to open Buy ",symbols[symbol_index]," at ",string(open_price), " operator:", symbol_operator);
            PipeOperator.WriteInteger(operate_succeed);
            PipeOperator.WriteInteger(open_price);
           }
         else
           {
            Print("Failed to open Buy ",symbols[symbol_index], " operator:", symbol_operator);
            PipeOperator.WriteInteger(operate_failed);
            PipeOperator.WriteInteger(failed_price);
           }
         break;
      case 2://开空
         if(trade.PositionOpen(symbols[symbol_index],ORDER_TYPE_SELL,lots_base,latest_price.bid,0,0))//成功开仓
           {
            open_price=trade.ResultPrice()/SymbolInfoDouble(symbols[symbol_index],SYMBOL_POINT);
            Print("Success to open Sell ",symbols[symbol_index]," at ",string(open_price), " operator:", symbol_operator);
            PipeOperator.WriteInteger(operate_succeed);
            PipeOperator.WriteInteger(open_price);
           }
         else
           {
            Print("Failed to open Sell ",symbols[symbol_index], " operator:", symbol_operator);
            PipeOperator.WriteInteger(operate_failed);
            PipeOperator.WriteInteger(failed_price);
           }
         break;
      case 3:// 平多
         total_pos = PositionsTotal();
         for(int i=total_pos-1;i>=0;i--)
           {
            ulong ticket = PositionGetTicket(i);
            PositionSelectByTicket(ticket);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY&&PositionGetSymbol(i)==symbols[symbol_index])
              {
               if(trade.PositionClose(symbols[symbol_index]))
                 {
                  close_price=trade.ResultPrice()/SymbolInfoDouble(symbols[symbol_index],SYMBOL_POINT);
                  Print("Success to close Buy ",symbols[symbol_index]," at ",string(close_price), " operator:", symbol_operator);
                  PipeOperator.WriteInteger(operate_succeed);
                  PipeOperator.WriteInteger(close_price);
                 }
               else
                 {
                  Print("Failed to close Buy ",symbols[symbol_index], " operator:", symbol_operator);
                  PipeOperator.WriteInteger(operate_failed);
                  PipeOperator.WriteInteger(failed_price);
                 }
              }
           }
         break;
      case 4://平空
        total_pos = PositionsTotal();
         for(int i=total_pos-1;i>=0;i--)
           {
            ulong ticket = PositionGetTicket(i);
            PositionSelectByTicket(ticket);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL&&PositionGetString(POSITION_SYMBOL)==symbols[symbol_index])
              {
               if(trade.PositionClose(symbols[symbol_index]))
                 {
                  close_price=trade.ResultPrice()/SymbolInfoDouble(symbols[symbol_index],SYMBOL_POINT);
                  Print("Success to close Sell ",symbols[symbol_index]," at ",string(close_price), " operator:", symbol_operator);
                  PipeOperator.WriteInteger(operate_succeed);
                  PipeOperator.WriteInteger(close_price);
                 }
               else
                 {
                  Print("Failed to close Sell ",symbols[symbol_index], " operator:", symbol_operator);
                  PipeOperator.WriteInteger(operate_failed);
                  PipeOperator.WriteInteger(failed_price);
                 }
              }
           }
         break;
      default:
            PipeOperator.WriteInteger(operate_failed);
            PipeOperator.WriteInteger(failed_price);
         break;
     }
  }
//+------------------------------------------------------------------+
