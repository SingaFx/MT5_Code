//+------------------------------------------------------------------+
//|                                                EA_PipeClient.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Files\FilePipe.mqh>
#include <Trade\Trade.mqh>
input string pipe_name="pipe1";
//CFilePipe  ExtPipeServeSend;
CFilePipe  ExtPipeServeReceive;
CTrade trade;
MqlTick latest_price;
int pos_state;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //EventSetTimer(1);
   //string serve_send_name=pipe_name+"_send";
   string serve_receive_name=pipe_name+"_receive";
   //bool pipe_server_send_opened=false;
   bool pipe_server_receive_opened=false;
   
   //if(ExtPipeServeSend.Open("\\\\REN\\pipe\\"+serve_send_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE) 
   //   {
   //      if(!ExtPipeServeSend.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
   //         Print("Client: 发送消息至服务器失败！");
   //      pipe_server_send_opened=true; 
   //   }
   //else if(ExtPipeServeSend.Open("\\\\.\\pipe\\"+serve_send_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
   //   {
   //      if(!ExtPipeServeSend.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
   //         Print("Client: 发送消息至服务器失败！");
   //      pipe_server_send_opened=true;   
   //   }

   if(ExtPipeServeReceive.Open("\\\\REN\\pipe\\"+serve_receive_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE) 
      {
         if(!ExtPipeServeReceive.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
            Print("Client: 发送消息至服务器失败！");
         pipe_server_receive_opened=true; 
      }
   else if(ExtPipeServeReceive.Open("\\\\.\\pipe\\"+serve_receive_name,FILE_READ|FILE_WRITE|FILE_BIN)!=INVALID_HANDLE)
      {
         if(!ExtPipeServeReceive.WriteString(__FILE__+" on MQL5 build "+IntegerToString(__MQ5BUILD__)))
            Print("Client: 发送消息至服务器失败！");
         pipe_server_receive_opened=true;   
      }
   //if(!pipe_server_send_opened)
   //  {
   //   Print("服务器发送数据管道打开失败！"+serve_send_name);
   //   return(INIT_FAILED);
   //  }
   if(!pipe_server_receive_opened)
     {
      Print("服务器接受数据管道打开失败！"+serve_receive_name);
      return(INIT_FAILED);
     }

   Print("服务器接收和发送数据两个管道打开成功！");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer(); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   event_data();  
  }
void OnTimer()
    {
     //event_position();
    }
void event_data()
   {
   SymbolInfoTick(_Symbol,latest_price);
   double price_send[2];
   string        str;
   int           ask_value=0;
   int           bid_value=0;
   ask_value=latest_price.ask/SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   bid_value=latest_price.bid/SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   
   //--- send data to server
   if(!ExtPipeServeReceive.WriteString(_Symbol+" Ask Price at "+TimeToString(TimeCurrent())))
     {
      Print("Client: sending string failed");
      return;
     }
   if(!ExtPipeServeReceive.WriteInteger(ask_value))
     {
      Print("Client: sending integer failed");
      return;
     }
   if(!ExtPipeServeReceive.WriteInteger(bid_value))
     {
      Print("Client: sending integer failed");
      return;
     }
   //if(!ExtPipeServeReceive.WriteArray(price_send))
   //   {
   //    Print("Client: sending price failed");
   //    return;
   //   }
   //Print(_Symbol+"成功发送报价,ask:"+string(ask_value)+",bid:"+string(bid_value));
  
   }
//void event_position()
//   {
//      int ea_operator=0;
//      if(!ExtPipeServeSend.ReadInteger(ea_operator))
//         {
//          Print("Client: Read EA operator from Server failed!");
//          return;
//         }
//      if(ea_operator==0)
//         {
//          ExtPipeServeSend.WriteInteger(0);
//          return;
//         }
//      Print("接受到套利信号，进行开平仓判断");
//      switch(pos_state)
//        {
//         case 0://空仓的情况
//           if(ea_operator==1)
//             {
//              //trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,0.01,latest_price.ask,0,0);
//              pos_state=1;
//              Print("EA Operator: Open buy position!");
//             }
//           else if(ea_operator==2)
//             {
//              //trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,0.01,latest_price.bid,0,0);
//              pos_state=1;
//              Print("EA Operator: Open sell position!");
//             }
//           break;
//         case 1://多头仓位
//            if(ea_operator==1)
//             {
//              Print("EA Operator: buy position has exist!");
//             }
//           else if(ea_operator==2)
//             {
//              //trade.PositionClose(_Symbol);
//              pos_state=0;
//              Print("EA Operator: Close buy position!");
//             }
//            break;
//         case 2://空头仓位
//            if(ea_operator==1)
//             {
//              //trade.PositionClose(_Symbol);
//              pos_state=0;
//              Print("EA Operator: Close sell position!");
//             }
//           else if(ea_operator==2)
//             {
//              Print("EA Operator: sell position has exist!");
//             }
//            break;   
//         default:
//           break;
//        }
//       ExtPipeServeSend.WriteInteger(1);
//   }
//+------------------------------------------------------------------+
